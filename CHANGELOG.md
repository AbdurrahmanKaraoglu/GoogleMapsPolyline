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
