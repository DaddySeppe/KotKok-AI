# KotKok AI

KotKok AI is an anti-food-waste cooking assistant for students, young workers, and families. It prioritizes ingredients that expire soon, generates cheap and simple meals, tracks savings, and supports a secure Supabase + edge-function AI flow.

## What’s included

- Flutter + Dart app with Material 3 UI
- Provider state management
- Supabase-ready authentication and data layer
- Secure AI recipe generation through Supabase Edge Functions
- SQL schema and RLS policies
- Mock/local fallback when Supabase is not configured

## Setup

1. Install Flutter and the Android Studio Flutter/Dart plugins.
2. Install the Supabase CLI if you want to deploy the edge function from your own machine.
3. Copy [.env.example](.env.example) to `.env` or use `.env.local` for your private values.
4. Paste your values in `.env` or `.env.local`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
5. Run `flutter pub get`.
6. Apply the SQL in [supabase/migrations/001_init.sql](supabase/migrations/001_init.sql) in your Supabase SQL editor.
7. Deploy the edge function:

```bash
supabase functions deploy generate-recipe
```

8. Set your AI secret in Supabase:

```bash
supabase secrets set AI_API_KEY=your_ai_api_key_here
```

## What still has to be linked

The app is already wired to Supabase in code. The only thing left is to point it at your own Supabase project:

- Create or open a Supabase project.
- Paste that project's URL and anon key into `.env` or `.env.local`.
- Run the SQL migration so the tables and RLS policies exist.
- Deploy the `generate-recipe` edge function.
- Add `AI_API_KEY` as a Supabase secret.

Once those pieces are in place, the app talks to your database automatically.

## Where to paste keys

- Paste the Supabase URL and anon key into `.env` or `.env.local`.
- The Flutter app reads them through `lib/config/supabase_config.dart` after `flutter_dotenv` loads `.env`.
- Paste the AI API key into Supabase Edge Function secrets, not into Flutter.

## Run the app

### In Android Studio

1. Open the `KotKok-AI` folder in Android Studio.
2. Let Android Studio fetch Flutter dependencies if prompted, or run `flutter pub get` first.
3. Select an Android emulator or a connected device.
4. Press Run, or use the terminal command below.

### From terminal

```bash
flutter run
```

If Supabase is not configured, KotKok AI still runs with mock/local data so you can demo the MVP without backend setup.

## Notes

- The secure recipe generation flow goes through the `generate-recipe` Supabase Edge Function.
- The Flutter app never contains the AI API key.
- The app uses a warm, friendly startup-style Material 3 design.
