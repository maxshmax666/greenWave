# greenwave-rn

Minimal React Native (Expo) client showing a map with a car marker and driving HUD.

## Recent changes

- Added traffic light management forms for lights and cycles.
- Introduced camera screen with traffic light detection.
- Integrated premium subscription flow and analytics tracking.
- Switched traffic light detector to TFLite model inference.
- Implemented fetch helper with timeout and error handling.

## Environment

Set the following environment variables for API access:

```
EXPO_PUBLIC_SUPABASE_URL
EXPO_PUBLIC_SUPABASE_ANON_KEY
EXPO_PUBLIC_ORS_API_KEY
```

## Running

Install dependencies and start Expo:

```
npm install
npx expo start
```

Run unit tests:

```
npm test
```

### Debug APK build

To create a debug Android APK:

```
npx expo run:android --variant debug
```
