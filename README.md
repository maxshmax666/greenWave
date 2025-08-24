# green_wave_app

A new Flutter project.

## Environment variables

The application reads sensitive keys from compile-time environment variables.
Provide these via `--dart-define` when running or building:

```
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=ORS_API_KEY=YOUR_ORS_KEY
```

Optional OAuth client IDs can also be supplied using
`SUPABASE_GOOGLE_CLIENT_ID` and `SUPABASE_APPLE_CLIENT_ID`.

In CI or deployment scripts, configure these values as environment secrets and
pass them to `flutter build` with the same `--dart-define` flags.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
