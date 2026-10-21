# google_maps_polyline

[![pub package](https://img.shields.io/pub/v/google_maps_polyline.svg)](https://pub.dev/packages/google_maps_polyline)

Fetches the route between two coordinates from the Google Directions API and decodes/encodes Google
[encoded polylines](https://developers.google.com/maps/documentation/utilities/polylinealgorithm).
Pure Dart: works in Flutter apps (Android, iOS, desktop) and on the server. Polyline decoding/encoding also works
on the web; for route requests see [Flutter web and CORS](#flutter-web-and-cors).

*[Türkçe açıklama aşağıda.](#türkçe)*

## Installation

```yaml
dependencies:
  google_maps_polyline: ^2.2.0
```

## Fetching a route

```dart
import 'package:google_maps_polyline/google_maps_polyline.dart';

final polyline = GoogleMapsPolyline();

final result = await polyline.getRouteBetweenCoordinates(
  apiKey,
  const MyPointLatLng(41.0082, 28.9784), // Istanbul
  const MyPointLatLng(39.9334, 32.8597), // Ankara
  travelMode: MyTravelMode.driving,
  wayPoints: [
    WayPointPolyline(location: 'Bolu, Türkiye'),
    WayPointPolyline(location: '40.7,31.6', stopOver: false), // via:
  ],
  avoidTolls: true,
  detailedPolyline: true, // step-by-step route
);

if (result.isSuccess) {
  // With google_maps_flutter:
  final points = [for (final p in result.points) LatLng(p.latitude, p.longitude)];
} else {
  print('${result.status}: ${result.errorMessage}');
}
```

`getRouteBetweenCoordinates` never throws. `result.status` is the value returned by the Directions API
(`OK`, `ZERO_RESULTS`, `NOT_FOUND`, `OVER_QUERY_LIMIT`, `REQUEST_DENIED`, `INVALID_REQUEST`, …), or
`ResultPolyline.statusError` (`"error"`) for network failures, timeouts and unreadable responses. Base your app
logic on `status`, which does not depend on the language; `errorMessage` is meant for display. The API key is
redacted from error messages. If the origin or destination is `NaN`/infinite, an error is returned without sending
a request.

By default Google's simplified `overview_polyline` is used, which can drift from the road at high zoom. With
`detailedPolyline: true` the route is built by joining every step polyline (more points, follows the road
closely). If the response has no steps, it falls back to `overview_polyline`.

Optional settings:

```dart
GoogleMapsPolyline(
  client: myHttpClient,                 // your own http.Client (tests, proxy, …)
  timeout: const Duration(seconds: 10), // default 15 s
  language: 'tr',                       // default 'en'
);
```

### Language

`language` is sent to the Directions API, so the API's own `error_message` comes back in that language. It also
selects the language of the messages produced by the package (timeouts, network errors, status descriptions):
`tr` gives Turkish, any other code English. The default is `en`.

## Decoding and encoding polylines

```dart
final points = PolylineCodec.decode(r'_p~iF~ps|U_ulLnnqC_mqNvxq`@');
// [(38.5, -120.2), (40.7, -120.95), (43.252, -126.453)]

final encoded = PolylineCodec.encode(points); // '_p~iF~ps|U_ulLnnqC_mqNvxq`@'

// Strings with 6-digit precision (e.g. OSRM polyline6):
PolylineCodec.decode(encoded6, precision: 6);
```

Invalid or truncated strings throw `FormatException`.

## Flutter web and CORS

Google's Directions web service does not allow CORS requests from browsers, so on Flutter web
`getRouteBetweenCoordinates` always returns a network error (`status == "error"`). On the web, fetch the route on
your own server (for example a Dart server or Cloud Function using this package), send the encoded polyline to the
app and decode it in the browser with `PolylineCodec.decode`. The Maps JavaScript API's `DirectionsService` is
another option for drawing routes on the web.

## API key security

The Directions API is a web service; a key embedded in an app can be read by anyone who has the app. Restrict the
key to **the Directions API only** in the Google Cloud Console and set a quota. If possible, call the API from your
own server; the package is pure Dart, so it runs there too.

## Directions API and Routes API

Google has marked the Directions API as **Legacy** and recommends the
[Routes API](https://developers.google.com/maps/documentation/routes) for new projects. The Directions API may not
be available in Google Cloud projects created after 1 March 2025. This package uses the Directions API; the Routes
API's `polyline.encodedPolyline` uses the same format and can be decoded with `PolylineCodec.decode`.

## Migrating to 2.x

- `MyPointLatLng.latitude`/`longitude` are now `double` instead of `double?` (no `!` needed).
- Check success with `result.isSuccess` instead of `result.status == "ok"` (the API returns `"OK"`, so the old
  comparison was never true).
- All classes are exported from `package:google_maps_polyline/google_maps_polyline.dart`; remove `src/...`
  imports.
- The package no longer depends on Flutter.
- Since 2.2.0 the package's messages are in English by default; pass `language: 'tr'` to keep Turkish messages.

See [`example/`](example) for a complete Flutter app (English and Turkish).

---

## Türkçe

Google Directions API ile iki nokta arasındaki rotayı alır ve Google kodlanmış polyline dizelerini çözer/kodlar.
Saf Dart'tır; Flutter (Android, iOS, masaüstü) ve sunucu tarafında çalışır.

- `GoogleMapsPolyline().getRouteBetweenCoordinates(apiKey, başlangıç, hedef, ...)` istisna fırlatmaz;
  `result.isSuccess`, `result.status` (API'nin durumu ya da ağ/zaman aşımı/okuma hatasında `"error"`) ve
  `result.errorMessage` (API anahtarı maskelenir) kontrol edilir. Uygulama mantığını dilden bağımsız olan
  `status`'a göre kurun.
- **Dil:** Mesajlar varsayılan olarak İngilizcedir. Türkçe için `GoogleMapsPolyline(language: 'tr')` kullanın;
  bu değer Directions API'ye de gönderilir, böylece Google'ın hata mesajı da Türkçe gelir.
- `detailedPolyline: true`, sadeleştirilmiş `overview_polyline` yerine adım adım ayrıntılı rotayı döndürür.
- `PolylineCodec.decode(dize, precision: 5)` / `PolylineCodec.encode(noktalar, precision: 5)`; geçersiz dizede
  `FormatException` fırlatılır.
- **Flutter web:** Directions web servisi CORS izni vermediğinden rota isteği tarayıcıda çalışmaz; rotayı kendi
  sunucunuzda alıp polyline'ı tarayıcıda `PolylineCodec.decode` ile çözün.
- **Anahtar güvenliği:** Anahtarı yalnızca Directions API ile sınırlayın ve kota koyun ya da isteği kendi
  sunucunuzdan yapın.
- Directions API Google tarafından **Legacy** olarak işaretlendi; yeni projeler için Routes API önerilir.

## License / Lisans

MIT — see [LICENSE](LICENSE).
