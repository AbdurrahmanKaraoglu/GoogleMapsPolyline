# google_maps_polyline örneği

İstanbul–Ankara arasındaki sürüş rotasını Directions API'den alıp `google_maps_flutter` haritasında çizer.

1. Haritanın görünmesi için Maps SDK anahtarını platforma ekleyin
   ([google_maps_flutter kurulumu](https://pub.dev/packages/google_maps_flutter#getting-started)):
   Android'de `android/app/src/main/AndroidManifest.xml`, iOS'ta `ios/Runner/AppDelegate.swift`.
2. Directions API anahtarını derleme sırasında verin; anahtarı koda yazmayın:

```bash
flutter run --dart-define=DIRECTIONS_API_KEY=ANAHTARINIZ
```
