const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

type IngredientInput = {
  name: string;
  expiration_date?: string | null;
  quantity?: string | null;
  category?: string | null;
  is_opened?: boolean;
  storage_location?: string | null;
};

type RequestBody = {
  ingredients?: IngredientInput[];
  budget?: number;
  allergies?: string[];
  dietaryPreferences?: string[];
  cookingTimeMinutes?: number;
  mood?: string;
  effortLevel?: string;
  dishCountPreference?: string;
  maxExtraCost?: number;
};

function sanitizeArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map((item) => String(item)).filter((item) => item.trim().length > 0);
}

function buildPrompt(body: Required<Pick<RequestBody, 'ingredients' | 'budget' | 'allergies' | 'dietaryPreferences' | 'cookingTimeMinutes' | 'mood' | 'effortLevel' | 'dishCountPreference' | 'maxExtraCost'>>) {
  const ingredientLines = body.ingredients
    .map((ingredient) => {
      const expiry = ingredient.expiration_date ?? 'unknown';
      return `- ${ingredient.name} | expires: ${expiry} | quantity: ${ingredient.quantity ?? '-'} | category: ${ingredient.category ?? '-'} | opened: ${ingredient.is_opened ? 'yes' : 'no'} | storage: ${ingredient.storage_location ?? '-'}`;
    })
    .join('\n');

  return `
You are KotKok AI, an expert student cooking assistant. Your goal is to help users save money and prevent food waste. You always prioritize ingredients that expire soon, respect allergies strictly, avoid unsafe food, keep meals simple, and minimize extra shopping.

Rules:
- Use expiring ingredients first.
- Never recommend expired ingredients. If any ingredient is expired, mention it should be checked or thrown away if unsafe.
- Keep recipes simple and realistic for students.
- Prefer low dish count and low effort.
- Avoid expensive missing ingredients.
- Respect allergies strictly.
- Respect dietary preferences strictly.
- Keep instructions short and clear.
- Return JSON only. No markdown. No code fences. No extra text.

User context:
- Mood: ${body.mood}
- Effort level: ${body.effortLevel}
- Dish count preference: ${body.dishCountPreference}
- Cooking time limit: ${body.cookingTimeMinutes} minutes
- Budget: €${body.budget.toFixed(2)}
- Max extra cost: €${body.maxExtraCost.toFixed(2)}
- Dietary preferences: ${body.dietaryPreferences.join(', ') || 'none'}
- Allergies: ${body.allergies.join(', ') || 'none'}

Ingredients:
${ingredientLines || '- none'}

Return valid JSON with exactly these keys:
{
  "title": "...",
  "description": "...",
  "reason": "...",
  "ingredientsUsed": ["..."],
  "missingIngredients": ["..."],
  "steps": ["..."],
  "estimatedCost": 0.0,
  "cookingTimeMinutes": 0,
  "dishCount": 0,
  "wasteSavingScore": 0,
  "studentScore": 0,
  "tags": ["..."]
}
`;
}

function fallbackJson(body: RequestBody) {
  return {
    title: 'Slim studentrecept',
    description: 'Een eenvoudige fallback op basis van je koelkast.',
    reason: 'AI fallback gebruikt omdat de externe provider niet beschikbaar was.',
    ingredientsUsed: (body.ingredients ?? []).slice(0, 4).map((ingredient) => ingredient.name),
    missingIngredients: ['olijfolie'],
    steps: ['Pak je verse ingrediënten.', 'Bak of meng ze kort samen.', 'Serveer direct.'],
    estimatedCost: 1.0,
    cookingTimeMinutes: Math.min(body.cookingTimeMinutes ?? 15, 20),
    dishCount: 1,
    wasteSavingScore: 72,
    studentScore: 80,
    tags: ['fallback', 'budget', 'student'],
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get('AI_API_KEY');
    if (!apiKey) {
      return new Response(JSON.stringify({ error: 'Missing AI_API_KEY secret.' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const rawBody = await req.json() as RequestBody;
    const body: Required<Pick<RequestBody, 'ingredients' | 'budget' | 'allergies' | 'dietaryPreferences' | 'cookingTimeMinutes' | 'mood' | 'effortLevel' | 'dishCountPreference' | 'maxExtraCost'>> = {
      ingredients: Array.isArray(rawBody.ingredients) ? rawBody.ingredients : [],
      budget: typeof rawBody.budget === 'number' ? rawBody.budget : 0,
      allergies: sanitizeArray(rawBody.allergies),
      dietaryPreferences: sanitizeArray(rawBody.dietaryPreferences),
      cookingTimeMinutes: typeof rawBody.cookingTimeMinutes === 'number' ? rawBody.cookingTimeMinutes : 15,
      mood: typeof rawBody.mood === 'string' ? rawBody.mood : 'Ik heb honger',
      effortLevel: typeof rawBody.effortLevel === 'string' ? rawBody.effortLevel : 'bijna niks',
      dishCountPreference: typeof rawBody.dishCountPreference === 'string' ? rawBody.dishCountPreference : 'geen afwas',
      maxExtraCost: typeof rawBody.maxExtraCost === 'number' ? rawBody.maxExtraCost : 5,
    };

    if (!body.ingredients.length) {
      return new Response(JSON.stringify(fallbackJson(rawBody)), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const prompt = buildPrompt(body);
    const model = Deno.env.get('AI_MODEL') ?? 'gpt-4o-mini';

    const completionResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        temperature: 0.5,
        messages: [
          { role: 'system', content: 'You are KotKok AI, an expert student cooking assistant. Your goal is to help users save money and prevent food waste. You always prioritize ingredients that expire soon, respect allergies strictly, avoid unsafe food, keep meals simple, and minimize extra shopping.' },
          { role: 'user', content: prompt },
        ],
        response_format: { type: 'json_object' },
      }),
    });

    if (!completionResponse.ok) {
      return new Response(JSON.stringify(fallbackJson(rawBody)), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const completionJson = await completionResponse.json();
    const content = completionJson?.choices?.[0]?.message?.content;

    if (typeof content !== 'string') {
      return new Response(JSON.stringify(fallbackJson(rawBody)), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    let parsed;
    try {
      parsed = JSON.parse(content);
    } catch {
      parsed = fallbackJson(rawBody);
    }

    return new Response(JSON.stringify(parsed), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'generate-recipe failed',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
