# google_maps_polyline

[![pub package](https://img.shields.io/pub/v/google_maps_polyline.svg)](https://pub.dev/packages/google_maps_polyline)

Google Directions API ile iki nokta arasındaki rotayı alır ve Google
[kodlanmış polyline](https://developers.google.com/maps/documentation/utilities/polylinealgorithm)
dizelerini çözer/kodlar. Saf Dart'tır: Flutter (Android, iOS, web, masaüstü) ve sunucu tarafında çalışır.

*English summary below.*

## Kurulum

```yaml
dependencies:
  google_maps_polyline: ^2.0.0
```

## Rota alma

```dart
import 'package:google_maps_polyline/google_maps_polyline.dart';

final polyline = GoogleMapsPolyline();

final result = await polyline.getRouteBetweenCoordinates(
  apiKey,
  const MyPointLatLng(41.0082, 28.9784), // İstanbul
  const MyPointLatLng(39.9334, 32.8597), // Ankara
  travelMode: MyTravelMode.driving,
  wayPoints: [
    WayPointPolyline(location: 'Bolu, Türkiye'),
    WayPointPolyline(location: '40.7,31.6', stopOver: false), // via:
  ],
  avoidTolls: true,
);

if (result.isSuccess) {
  // google_maps_flutter ile:
  final points = [for (final p in result.points) LatLng(p.latitude, p.longitude)];
} else {
  print('${result.status}: ${result.errorMessage}');
}
```

`getRouteBetweenCoordinates` istisna fırlatmaz. `result.status` Directions API'nin döndürdüğü değerdir
(`OK`, `ZERO_RESULTS`, `NOT_FOUND`, `OVER_QUERY_LIMIT`, `REQUEST_DENIED`, `INVALID_REQUEST`, …);
ağ hatası, zaman aşımı veya okunamayan yanıtta `ResultPolyline.statusError` (`"error"`) olur.
Hata mesajlarında API anahtarı maskelenir.

İsteğe bağlı ayarlar:

```dart
GoogleMapsPolyline(
  client: myHttpClient,                 // kendi http.Client'ınız (test, proxy vb.)
  timeout: const Duration(seconds: 10), // varsayılan 15 sn
);
```

## Polyline çözme ve kodlama

```dart
final points = PolylineCodec.decode(r'_p~iF~ps|U_ulLnnqC_mqNvxq`@');
// [(38.5, -120.2), (40.7, -120.95), (43.252, -126.453)]

final encoded = PolylineCodec.encode(points); // '_p~iF~ps|U_ulLnnqC_mqNvxq`@'

// 6 basamak hassasiyetli dizeler (ör. OSRM polyline6):
PolylineCodec.decode(encoded6, precision: 6);
```

Geçersiz veya yarım kalmış dizelerde `FormatException` fırlatılır.

## API anahtarı güvenliği

Directions API web servisidir; anahtarı uygulamaya gömmek, uygulamayı açan herkesin onu okuyabilmesi demektir.
Anahtarı Google Cloud Console'da **yalnızca Directions API** ile sınırlayın ve kota koyun. Mümkünse isteği kendi
sunucunuz üzerinden yapın; paket saf Dart olduğundan sunucuda da kullanılabilir.

## Directions API ve Routes API

Google, Directions API'yi **Legacy** (eski) olarak işaretledi ve yeni projeler için
[Routes API](https://developers.google.com/maps/documentation/routes)'yi öneriyor. 1 Mart 2025'ten sonra
oluşturulan Google Cloud projelerinde Directions API etkinleştirilemeyebilir. Bu paket Directions API'yi kullanır;
Routes API yanıtındaki `polyline.encodedPolyline` alanı da aynı biçimde olduğundan `PolylineCodec.decode` ile
çözülebilir.

## 2.0.0'a geçiş

- `MyPointLatLng.latitude`/`longitude` artık `double?` değil `double` (`!` gerekmiyor).
- Başarı kontrolü için `result.status == "ok"` yerine `result.isSuccess` kullanın
  (API `"OK"` döndürdüğünden eski karşılaştırma hiçbir zaman doğru olmuyordu).
- Tüm sınıflar `package:google_maps_polyline/google_maps_polyline.dart` üzerinden dışa aktarılıyor;
  `src/...` içe aktarmalarını kaldırın.
- Paket artık Flutter'a bağımlı değil.

---

## English

Fetches a route between two coordinates from the Google Directions API and decodes/encodes Google encoded
polylines. Pure Dart — works in Flutter apps and on the server.

- `GoogleMapsPolyline().getRouteBetweenCoordinates(apiKey, origin, destination, ...)` returns a `ResultPolyline`
  and never throws; check `result.isSuccess`, `result.status` (the raw API status, or `"error"` for network,
  timeout and parse failures) and `result.errorMessage` (the API key is redacted).
- `PolylineCodec.decode(encoded, precision: 5)` / `PolylineCodec.encode(points, precision: 5)`; invalid input
  throws `FormatException`.
- Pass your own `http.Client` and `timeout` to the `GoogleMapsPolyline` constructor if needed.
- The Directions API is a **legacy** Google product; new projects should consider the
  [Routes API](https://developers.google.com/maps/documentation/routes). Its `encodedPolyline` can be decoded
  with `PolylineCodec.decode`.
- Restrict your API key to the Directions API, or call it from your own backend.

See [`example/`](example) for a complete Flutter app.

## Lisans / License

MIT — bkz. [LICENSE](LICENSE).
