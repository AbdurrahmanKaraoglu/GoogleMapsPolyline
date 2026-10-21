import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:test/test.dart';

void main() {
  // Google dokümantasyonundaki örnek:
  // https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  const googleExample = r'_p~iF~ps|U_ulLnnqC_mqNvxq`@';
  const googlePoints = [
    MyPointLatLng(38.5, -120.2),
    MyPointLatLng(40.7, -120.95),
    MyPointLatLng(43.252, -126.453),
  ];

  group('decode', () {
    test('Google dokümantasyon örneğini çözer', () {
      expect(PolylineCodec.decode(googleExample), googlePoints);
    });

    test('GoogleMapsPolyline.decodePolyline aynı sonucu verir', () {
      expect(GoogleMapsPolyline().decodePolyline(googleExample), googlePoints);
    });

    test('boş dize boş liste döndürür', () {
      expect(PolylineCodec.decode(''), isEmpty);
    });

    test('dokümandaki tek değer örneği (-179.9832104)', () {
      final points = PolylineCodec.decode('`~oia@`~oia@');
      expect(points.single.latitude, closeTo(-179.98321, 1e-9));
      expect(points.single.longitude, closeTo(-179.98321, 1e-9));
    });

    test('precision 6 ile gidiş-dönüş', () {
      final encoded = PolylineCodec.encode(googlePoints, precision: 6);
      expect(encoded, isNot(googleExample));
      expect(PolylineCodec.decode(encoded, precision: 6), googlePoints);
    });

    test('yarım kalmış dizede FormatException fırlatır', () {
      expect(() => PolylineCodec.decode('_p~iF~ps|U_ulL'), throwsFormatException);
      expect(() => PolylineCodec.decode('_p~iF'), throwsFormatException);
    });

    test('geçersiz karakterde FormatException fırlatır', () {
      expect(() => PolylineCodec.decode('_p~iF ps|U'), throwsFormatException);
    });

    test('geçersiz precision için RangeError fırlatır', () {
      expect(() => PolylineCodec.decode(googleExample, precision: -1), throwsRangeError);
      expect(() => PolylineCodec.decode(googleExample, precision: 7), throwsRangeError);
    });
  });

  group('encode', () {
    test('Google dokümantasyon örneğini kodlar', () {
      expect(PolylineCodec.encode(googlePoints), googleExample);
      expect(GoogleMapsPolyline().encodePolyline(googlePoints), googleExample);
    });

    test('-179.9832104 dokümandaki gibi kodlanır', () {
      expect(PolylineCodec.encode(const [MyPointLatLng(-179.9832104, 0)]), '`~oia@?');
    });

    test('boş liste boş dize verir', () {
      expect(PolylineCodec.encode(const []), '');
    });

    test('sınır ve işaret değişimi değerlerinde gidiş-dönüş', () {
      const points = [
        MyPointLatLng(0, 0),
        MyPointLatLng(-90, 180),
        MyPointLatLng(90, -180),
        MyPointLatLng(41.01384, 28.94966),
        MyPointLatLng(-0.00001, 0.00001),
      ];
      expect(PolylineCodec.decode(PolylineCodec.encode(points)), points);
    });
  });
}
