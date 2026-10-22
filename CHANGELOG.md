## 2.2.2

* DOCS: README lists the publisher's other packages. / README'ye yayıncının diğer paketlerinin listesi eklendi.
* DOCS: pubspec description is now in English. / pubspec açıklaması İngilizceye çevrildi.

## 2.2.1

* Directions API responses are decoded as UTF-8 even when the `Content-Type` header has no charset, so non-ASCII `error_message` texts (e.g. Turkish) are no longer garbled.
* README: "Works well with" section for animated_route_marker, route_simulator and marker_crafter.
* Example app: demo mode without `DIRECTIONS_API_KEY` (bundled sample polylines decoded offline), a map-independent route preview, travel mode and detail options disabled in demo mode.

## 2.2.0

* **Language support:** new `language` parameter on `GoogleMapsPolyline` (default `en`). It is sent to the Directions API as `language` and selects the language of the package's own messages (`tr` → Turkish, anything else → English).
* **Behaviour change:** package messages are now English by default (previously Turkish). Pass `language: 'tr'` to keep Turkish messages. `status` values are unchanged.
* Network error messages no longer include the request URL.
* Timeout messages show milliseconds for sub-second timeouts.
* `MyPointLatLng.toString()` now returns `MyPointLatLng(lat, lng)`.
* API documentation is now in English; README is English first with a Turkish section.
* Example app: modern corporate design, English/Turkish localization following the device language, Maps SDK key read from `local.properties`, Windows Kotlin build fix.

## 2.1.0

* `detailedPolyline` seçeneği: rota, sadeleştirilmiş `overview_polyline` yerine adım (`legs[].steps[].polyline`) polylineleri birleştirilerek oluşturulabiliyor; adımlar arasındaki ortak nokta tekrarlanmıyor.
* Koordinatlar isteğe sabit ondalıkla (en fazla 7 basamak) yazılıyor; sıfıra yakın değerler artık `1e-7` gibi üstel gösterimle gidip API tarafından reddedilmiyor.
* `NaN`/sonsuz başlangıç veya hedef koordinatı istek atılmadan hata sonucu döndürüyor; `MyNetworkUtil.buildUri` bu durumda `ArgumentError` fırlatıyor.
* README: Flutter web'de Directions API'nin CORS nedeniyle çalışmadığı ve önerilen çözüm eklendi.

## 2.0.0

**Kırıcı değişiklikler**

* Paket saf Dart oldu; Flutter bağımlılığı kaldırıldı. Kökteki gereksiz platform klasörleri silindi.
* `MyPointLatLng.latitude` ve `longitude` artık null olamaz (`double`); sınıf `const` kurucuya, `==` ve `hashCode`'a sahip.
* Dart SDK alt sınırı 3.6.

**Hata düzeltmeleri**

* `mode` parametresi yanlış gönderiliyordu (`Mydriving` gibi); artık `driving`, `walking`, `bicycling`, `transit`.
* `avoidHighways`/`avoidTolls`/`avoidFerries` API'nin tanımadığı parametreler olarak gönderiliyordu; artık `avoid=highways|tolls|ferries`.
* `stopOver: false` olan ara noktalar `via:` öneki olmadan gönderiliyordu.
* HTTP 200 dışı yanıtlarda `status` boş kalıyordu; artık hata durumu ve mesajı dolduruluyor.
* Ağ hatası mesajlarında API anahtarı istek adresiyle birlikte loglanabiliyordu; artık maskeleniyor ve `debugPrint` yapılmıyor.
* Bozuk polyline `RangeError` ile çöküyordu; çözücü artık `FormatException` fırlatıyor, ağ katmanı bunu hata sonucuna çeviriyor.
* README'deki `result.status == "ok"` kontrolü hiçbir zaman doğru olmuyordu (API `"OK"` döndürür).

**Yenilikler**

* Tüm public sınıflar ana kütüphaneden dışa aktarılıyor (`src/` içe aktarması gerekmiyor).
* `ResultPolyline.isSuccess`, `ResultPolyline.statusError`.
* `PolylineCodec.decode`/`encode` ve `GoogleMapsPolyline.encodePolyline`; `precision` (5 veya 6) desteği.
* `GoogleMapsPolyline(client:, timeout:)`: özel `http.Client` ve zaman aşımı (varsayılan 15 sn).
* `ZERO_RESULTS`, `OVER_QUERY_LIMIT`, `REQUEST_DENIED` vb. durumlar için açıklayıcı mesajlar.
* Birim ve sahte HTTP istemcili ağ testleri; yenilenmiş örnek uygulama; README'ye Routes API notu.

## 1.0.3

* Basit güncellemeler.

## 1.0.2

* Basit güncellemeler.

## 1.0.1

* İlk sürüm.
