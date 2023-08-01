library google_maps_polyline;


 
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:google_maps_polyline/src/my_network_util.dart';

/// GoogleMapsPolyline sınıfı, polinleri çözme ve kodlama işlemleri için bir arayüz sağlar.
class GoogleMapsPolyline {
  MyNetworkUtil util = MyNetworkUtil();

  /// İki nokta arasındaki rota için Google Yönlendirme API'sini kullanarak sonuç polyline'ini alır.
  /// Parametreler:
  /// - googleApiKey: Google Yönlendirme API'si için API anahtarı.
  /// - origin: Başlangıç noktası için enlem ve boylam bilgisi.
  /// - destination: Hedef noktası için enlem ve boylam bilgisi.
  /// - travelMode: Rota için kullanılacak seyahat modu (varsayılan: driving).
  /// - wayPoints: Yol üzerindeki diğer noktalar için WayPointPolyline listesi (varsayılan: boş liste).
  /// - avoidHighways: Otoyolları kullanmayı engellemek için boolean değeri (varsayılan: false).
  /// - avoidTolls: Otoyol geçişlerini engellemek için boolean değeri (varsayılan: false).
  /// - avoidFerries: Feribot geçişlerini engellemek için boolean değeri (varsayılan: true).
  /// - optimizeWaypoints: Yol üzerindeki noktaların optimizasyonu için boolean değeri (varsayılan: false).
  Future<ResultPolyline> getRouteBetweenCoordinates(
      String googleApiKey, MyPointLatLng origin, MyPointLatLng destination,
      {MyTravelMode travelMode = MyTravelMode.driving,
      List<WayPointPolyline> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false}) async {
    return await util.getRouteBetweenCoordinates(
        googleApiKey,
        origin,
        destination,
        travelMode,
        wayPoints,
        avoidHighways,
        avoidTolls,
        avoidFerries,
        optimizeWaypoints);
  }

  /// Google polyline'i çözer ve çözümlenmiş koordinatları içeren bir liste döndürür.
  /// Örnek bir encoded polyline: "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  List<MyPointLatLng> decodePolyline(String encodedString) {
    return util.decodeEncodedPolyline(encodedString);
  }
}
