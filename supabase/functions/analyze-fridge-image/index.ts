const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

type RequestBody = {
  imageBase64?: string;
  mimeType?: string;
  fileName?: string;
};

function fallbackResponse() {
  return {
    candidates: [],
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

    const body = await req.json() as RequestBody;
    if (!body.imageBase64) {
      return new Response(JSON.stringify({ error: 'Missing imageBase64.' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const mimeType = body.mimeType ?? 'image/jpeg';
    const today = new Date().toISOString().slice(0, 10);
    const model = Deno.env.get('AI_VISION_MODEL') ?? Deno.env.get('AI_MODEL') ?? 'gpt-4o-mini';

    const prompt = `
You are KotKok AI, a careful fridge inventory assistant.
Today is ${today}.

Analyze this fridge or food photo. Identify visible food products one by one.
For each product:
- Guess the product name in Dutch.
- Choose one category from: Groenten, Fruit, Zuivel, Vlees, Vis, Brood, Granen, Snacks, Saus, Overig.
- Estimate quantity in Dutch.
- Choose storage_location from: fridge, freezer, pantry.
- Estimate whether the package/product is opened.
- Suggest an expiration date as ISO yyyy-mm-dd. If a label date is visible, use that date. Otherwise estimate conservatively from common shelf life, visible freshness, and whether it is opened.
- Set could_be_expired true only when a visible date is past, there are spoilage signs, or the item looks unsafe.
- Add a short note in Dutch.

Important safety rule: visual analysis cannot guarantee food safety. If unsure, use a conservative date and lower confidence.
Return JSON only, with this exact shape:
{
  "candidates": [
    {
      "name": "...",
      "category": "...",
      "quantity": "...",
      "storage_location": "fridge",
      "suggested_expiration_date": "yyyy-mm-dd",
      "is_opened": false,
      "could_be_expired": false,
      "confidence": 0.0,
      "notes": "..."
    }
  ]
}
Limit to the 12 clearest food products.
`;

    const completionResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        temperature: 0.2,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: prompt },
              {
                type: 'image_url',
                image_url: {
                  url: `data:${mimeType};base64,${body.imageBase64}`,
                  detail: 'high',
                },
              },
            ],
          },
        ],
        response_format: { type: 'json_object' },
      }),
    });

    if (!completionResponse.ok) {
      return new Response(JSON.stringify(fallbackResponse()), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const completionJson = await completionResponse.json();
    const content = completionJson?.choices?.[0]?.message?.content;

    if (typeof content !== 'string') {
      return new Response(JSON.stringify(fallbackResponse()), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    let parsed;
    try {
      parsed = JSON.parse(content);
    } catch {
      parsed = fallbackResponse();
    }

    return new Response(JSON.stringify(parsed), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({
      error: 'analyze-fridge-image failed',
      message: error instanceof Error ? error.message : 'Unknown error',
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
