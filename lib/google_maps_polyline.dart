/// Google Directions API ile rota alma ve Google kodlanmış polyline
/// dizelerini çözme/kodlama.
library;

import 'package:google_maps_polyline/src/my_network_util.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/polyline_codec.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:http/http.dart' as http;

export 'package:google_maps_polyline/src/point_latlng.dart';
export 'package:google_maps_polyline/src/polyline_codec.dart';
export 'package:google_maps_polyline/src/utils/my_request_enums.dart';
export 'package:google_maps_polyline/src/utils/result_polyline.dart';
export 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';

/// GoogleMapsPolyline sınıfı, polinleri çözme ve kodlama işlemleri için bir arayüz sağlar.
class GoogleMapsPolyline {
  /// Ağ isteklerini yürüten yardımcı.
  final MyNetworkUtil util;

  /// [client] verilirse istekler bu istemciyle yapılır (test veya özel
  /// yapılandırma için); kapatmak çağıranın sorumluluğundadır.
  /// [timeout] tek bir isteğin en fazla süresidir.
  GoogleMapsPolyline({http.Client? client, Duration timeout = const Duration(seconds: 15)})
      : util = MyNetworkUtil(client: client, timeout: timeout);

  /// İki nokta arasındaki rota için Google Yönlendirme API'sini kullanarak sonuç polyline'ini alır.
  /// Parametreler:
  /// - googleApiKey: Google Yönlendirme API'si için API anahtarı.
  /// - origin: Başlangıç noktası için enlem ve boylam bilgisi.
  /// - destination: Hedef noktası için enlem ve boylam bilgisi.
  /// - travelMode: Rota için kullanılacak seyahat modu (varsayılan: driving).
  /// - wayPoints: Yol üzerindeki diğer noktalar için WayPointPolyline listesi (varsayılan: boş liste).
  /// - avoidHighways: Otoyolları kullanmayı engellemek için boolean değeri (varsayılan: false).
  /// - avoidTolls: Ücretli yolları kullanmayı engellemek için boolean değeri (varsayılan: false).
  /// - avoidFerries: Feribot geçişlerini engellemek için boolean değeri (varsayılan: true).
  /// - optimizeWaypoints: Yol üzerindeki noktaların optimizasyonu için boolean değeri (varsayılan: false).
  /// - detailedPolyline: `true` ise sadeleştirilmiş `overview_polyline` yerine adım adım ayrıntılı
  ///   rota döndürülür (varsayılan: false).
  ///
  /// Hata durumunda istisna fırlatmaz; [ResultPolyline.isSuccess] `false` olur.
  Future<ResultPolyline> getRouteBetweenCoordinates(
      String googleApiKey, MyPointLatLng origin, MyPointLatLng destination,
      {MyTravelMode travelMode = MyTravelMode.driving,
      List<WayPointPolyline> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false,
      bool detailedPolyline = false}) {
    return util.getRouteBetweenCoordinates(googleApiKey, origin, destination, travelMode, wayPoints, avoidHighways,
        avoidTolls, avoidFerries, optimizeWaypoints,
        detailedPolyline: detailedPolyline);
  }

  /// Google polyline'i çözer ve çözümlenmiş koordinatları içeren bir liste döndürür.
  /// Örnek bir encoded polyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  /// Geçersiz dizede [FormatException] fırlatır.
  List<MyPointLatLng> decodePolyline(String encodedString, {int precision = 5}) {
    return PolylineCodec.decode(encodedString, precision: precision);
  }

  /// Koordinat listesini Google polyline dizesine kodlar.
  String encodePolyline(List<MyPointLatLng> points, {int precision = 5}) {
    return PolylineCodec.encode(points, precision: precision);
  }
}
