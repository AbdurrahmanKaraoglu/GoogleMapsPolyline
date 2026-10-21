# google_maps_polyline example

Fetches a route from the Directions API with `google_maps_polyline` and draws it on a `google_maps_flutter` map.
The app follows the device language (English or Turkish) and passes it to the package, so error messages are
localized too.

1. Add a Maps SDK key so the map renders. The Android build reads it from `MAPS_API_KEY` in
   `android/local.properties` (not committed) or from the `MAPS_API_KEY` environment variable:

   ```properties
   MAPS_API_KEY=YOUR_KEY
   ```

   On iOS add it in `ios/Runner/AppDelegate.swift`
   ([google_maps_flutter setup](https://pub.dev/packages/google_maps_flutter#getting-started)).
2. Pass the Directions API key at build time; do not hard-code it:

```bash
flutter run --dart-define=DIRECTIONS_API_KEY=YOUR_KEY
```

The key needs access to both **Directions API** and **Maps SDK for Android/iOS**.

---

İstanbul–Ankara gibi hazır rotaları Directions API'den alıp haritada çizer; uygulama cihaz diline göre Türkçe veya
İngilizce açılır. Maps SDK anahtarını `android/local.properties` içine `MAPS_API_KEY=...` olarak yazın,
Directions anahtarını `--dart-define=DIRECTIONS_API_KEY=...` ile verin.
