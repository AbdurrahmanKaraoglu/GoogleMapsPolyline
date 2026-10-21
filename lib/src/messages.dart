/// Human-readable messages produced by the package itself.
///
/// Turkish is used when the language code starts with `tr`; every other
/// language falls back to English.
class PolylineMessages {
  const PolylineMessages._(this._turkish);

  factory PolylineMessages.forLanguage(String language) => PolylineMessages._(language.toLowerCase().startsWith('tr'));

  final bool _turkish;

  String get invalidCoordinates => _turkish
      ? 'Başlangıç ve hedef koordinatları sonlu sayılar olmalı.'
      : 'Origin and destination coordinates must be finite numbers.';

  String timeout(Duration timeout) {
    final ms = timeout.inMilliseconds;
    final amount = ms % 1000 == 0 ? (_turkish ? '${ms ~/ 1000} saniye' : '${ms ~/ 1000} s') : '$ms ms';
    return _turkish ? 'İstek $amount içinde yanıtlanmadı.' : 'The request did not complete within $amount.';
  }

  String network(String detail) => _turkish ? 'Ağ hatası: $detail' : 'Network error: $detail';

  String get unreadableResponse =>
      _turkish ? 'Directions API yanıtı okunamadı.' : 'The Directions API response could not be read.';

  String http(int statusCode) => _turkish ? 'HTTP $statusCode hatası.' : 'HTTP error $statusCode.';

  String polyline(String detail) =>
      _turkish ? 'Polyline çözülemedi: $detail' : 'The polyline could not be decoded: $detail';

  String unknownStatus(String? status) =>
      _turkish ? 'Bilinmeyen yanıt durumu: $status' : 'Unknown response status: $status';

  /// Description of a Directions API `status` value, or `null` if unknown.
  String? status(String? status) => (_turkish ? _statusTr : _statusEn)[status];

  static const _statusEn = {
    'ZERO_RESULTS': 'No route could be found between the origin and destination.',
    'NOT_FOUND': 'At least one of the origin, destination or waypoints could not be geocoded.',
    'OVER_QUERY_LIMIT': 'The API quota has been exceeded.',
    'OVER_DAILY_LIMIT': 'The daily API quota has been exceeded or billing is not enabled.',
    'REQUEST_DENIED': 'The request was denied; check the API key and that the Directions API is enabled.',
    'INVALID_REQUEST': 'The request was invalid.',
    'MAX_WAYPOINTS_EXCEEDED': 'Too many waypoints were provided.',
    'MAX_ROUTE_LENGTH_EXCEEDED': 'The requested route is too long.',
    'UNKNOWN_ERROR': 'Server error; the request may succeed if you try again.',
  };

  static const _statusTr = {
    'ZERO_RESULTS': 'Başlangıç ve hedef arasında rota bulunamadı.',
    'NOT_FOUND': 'Başlangıç, hedef veya ara noktalardan en az biri bulunamadı.',
    'OVER_QUERY_LIMIT': 'API kotası aşıldı.',
    'OVER_DAILY_LIMIT': 'Günlük API kotası aşıldı veya faturalandırma etkin değil.',
    'REQUEST_DENIED': 'İstek reddedildi; API anahtarını ve Directions API yetkisini kontrol edin.',
    'INVALID_REQUEST': 'Geçersiz istek.',
    'MAX_WAYPOINTS_EXCEEDED': 'Ara nokta sayısı sınırı aşıldı.',
    'MAX_ROUTE_LENGTH_EXCEEDED': 'Rota çok uzun.',
    'UNKNOWN_ERROR': 'Sunucu hatası; istek tekrar denenebilir.',
  };
}
