// result_polyline.dart
import 'package:google_maps_polyline/src/point_latlng.dart';

/// ResultPolyline sınıfı, Google Yönlendirme API'sinden dönen sonuç polyline'ini temsil eder.
class ResultPolyline {
  /// Ağ, zaman aşımı veya yanıt ayrıştırma hatalarında kullanılan durum değeri.
  static const String statusError = "error";

  /// İstek durumu.
  ///
  /// Directions API'nin döndürdüğü değerdir (`OK`, `ZERO_RESULTS`,
  /// `NOT_FOUND`, `OVER_QUERY_LIMIT`, `REQUEST_DENIED`, `INVALID_REQUEST`,
  /// `MAX_WAYPOINTS_EXCEEDED`, `MAX_ROUTE_LENGTH_EXCEEDED`, `UNKNOWN_ERROR`).
  /// İstek API'ye ulaşamadıysa veya yanıt okunamadıysa [statusError] olur.
  String? status;

  /// Çözümlenmiş koordinat listesi.
  List<MyPointLatLng> points;

  /// Hata mesajı (eğer varsa).
  String? errorMessage;

  ResultPolyline({this.status, this.points = const [], this.errorMessage = ""});

  /// Rota başarıyla alındıysa `true`.
  bool get isSuccess => status == "OK";
}
