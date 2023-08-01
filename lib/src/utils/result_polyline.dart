/// result_polyline.dart\
import 'package:google_maps_polyline/src/point_latlng.dart';

/// ResultPolyline sınıfı, Google Yönlendirme API'sinden dönen sonuç polyline'ini temsil eder.
class ResultPolyline {

  /// İstek durumu ("ok" veya "error").
  String? status;

  /// Çözümlenmiş koordinat listesi.
  List<MyPointLatLng> points;

  /// Hata mesajı (eğer varsa).
  String? errorMessage;

  ResultPolyline({this.status, this.points = const [], this.errorMessage = ""});
}
