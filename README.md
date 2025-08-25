# green_wave_app

A minimal Flutter client for the "Green Wave" project. The app displays a map
and allows adding traffic lights and personal road marks.

## Environment variables

Sensitive keys are provided via compile-time environment variables using
`--dart-define` when running or building:

```
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=ORS_API_KEY=YOUR_ORS_KEY
```

Configure these values as secrets in CI and pass them to `flutter build` with
the same flags.

## Features

- Map screen with centering on user location
- Adding traffic lights saved to `public.lights`
- Adding custom marks saved to `public.record_marks`

## Building

```
flutter analyze
flutter build apk --debug
```

Ensure a recent Flutter SDK is installed.
