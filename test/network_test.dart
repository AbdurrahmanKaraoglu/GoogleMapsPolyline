import 'dart:convert';

import 'package:google_maps_polyline/google_maps_polyline.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _apiKey = 'AIzaSy-test_KEY123';
const _origin = MyPointLatLng(41.0082, 28.9784);
const _destination = MyPointLatLng(39.9334, 32.8597);

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  late Uri lastUri;

  GoogleMapsPolyline polylineWith(Future<http.Response> Function(http.Request) handler,
      {Duration timeout = const Duration(seconds: 15)}) {
    return GoogleMapsPolyline(
      client: MockClient((request) {
        lastUri = request.url;
        return handler(request);
      }),
      timeout: timeout,
    );
  }

  test('OK yanıtında overview_polyline çözülür', () async {
    final api = polylineWith((_) async => _json({
          'status': 'OK',
          'routes': [
            {
              'overview_polyline': {'points': r'_p~iF~ps|U_ulLnnqC_mqNvxq`@'}
            }
          ],
        }));

    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);

    expect(result.isSuccess, isTrue);
    expect(result.status, 'OK');
    expect(result.points, hasLength(3));
    expect(result.points.first, const MyPointLatLng(38.5, -120.2));
  });

  test('istek adresi doğru parametrelerle kurulur', () async {
    final api = polylineWith((_) async => _json({'status': 'ZERO_RESULTS', 'routes': []}));

    await api.getRouteBetweenCoordinates(
      _apiKey,
      _origin,
      _destination,
      travelMode: MyTravelMode.walking,
      avoidHighways: true,
      avoidTolls: true,
      wayPoints: [
        WayPointPolyline(location: 'Bolu, Türkiye'),
        WayPointPolyline(location: '40.7,31.6', stopOver: false),
      ],
      optimizeWaypoints: true,
    );

    expect(lastUri.scheme, 'https');
    expect(lastUri.host, 'maps.googleapis.com');
    expect(lastUri.path, '/maps/api/directions/json');
    final q = lastUri.queryParameters;
    expect(q['origin'], '41.0082,28.9784');
    expect(q['destination'], '39.9334,32.8597');
    expect(q['mode'], 'walking');
    expect(q['avoid'], 'highways|tolls|ferries');
    expect(q['waypoints'], 'optimize:true|Bolu, Türkiye|via:40.7,31.6');
    expect(q['key'], _apiKey);
    expect(q.keys, isNot(contains('avoidHighways')));
    // Özel karakterler kodlanmış olmalı.
    expect(lastUri.query, isNot(contains(' ')));
    expect(lastUri.query, isNot(contains('|')));
  });

  test('avoid ve waypoint yoksa parametre gönderilmez', () async {
    final api = polylineWith((_) async => _json({'status': 'ZERO_RESULTS'}));
    await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination, avoidFerries: false);
    expect(lastUri.queryParameters.containsKey('avoid'), isFalse);
    expect(lastUri.queryParameters.containsKey('waypoints'), isFalse);
    expect(lastUri.queryParameters['mode'], 'driving');
  });

  for (final status in ['ZERO_RESULTS', 'OVER_QUERY_LIMIT', 'NOT_FOUND']) {
    test('$status durumu açıklayıcı mesajla döner', () async {
      final api = polylineWith((_) async => _json({'status': status, 'routes': []}));
      final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
      expect(result.isSuccess, isFalse);
      expect(result.status, status);
      expect(result.points, isEmpty);
      expect(result.errorMessage, isNotEmpty);
    });
  }

  test('REQUEST_DENIED: API mesajı iletilir, anahtar maskelenir', () async {
    final api = polylineWith((_) async => _json({
          'status': 'REQUEST_DENIED',
          'error_message': 'The provided API key is invalid: $_apiKey',
          'routes': [],
        }));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, 'REQUEST_DENIED');
    expect(result.errorMessage, contains('API key is invalid'));
    expect(result.errorMessage, isNot(contains(_apiKey)));
  });

  test('OK fakat rota yoksa ZERO_RESULTS döner', () async {
    final api = polylineWith((_) async => _json({'status': 'OK', 'routes': []}));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.isSuccess, isFalse);
    expect(result.status, 'ZERO_RESULTS');
  });

  test('JSON olmayan HTTP 500 yanıtı hata olarak döner', () async {
    final api = polylineWith((_) async => http.Response('Internal error', 500));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, ResultPolyline.statusError);
    expect(result.errorMessage, contains('500'));
  });

  test('HTTP 400 JSON gövdesindeki API durumu korunur', () async {
    final api = polylineWith((_) async => _json({'status': 'INVALID_REQUEST', 'routes': []}, 400));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, 'INVALID_REQUEST');
  });

  test('bozuk JSON hata olarak döner', () async {
    final api = polylineWith((_) async => http.Response('{bozuk', 200));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, ResultPolyline.statusError);
  });

  test('bozuk polyline istisna fırlatmaz, hata döner', () async {
    final api = polylineWith((_) async => _json({
          'status': 'OK',
          'routes': [
            {
              'overview_polyline': {'points': '_p~iF'}
            }
          ],
        }));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, ResultPolyline.statusError);
  });

  test('ağ hatasında anahtar mesajda görünmez', () async {
    final api = GoogleMapsPolyline(
        client: MockClient((request) async => throw http.ClientException('Bağlantı kurulamadı', request.url)));
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, ResultPolyline.statusError);
    expect(result.errorMessage, contains('Bağlantı kurulamadı'));
    expect(result.errorMessage, isNot(contains(_apiKey)));
  });

  test('zaman aşımında hata döner', () async {
    final api = polylineWith(
      (_) => Future.delayed(const Duration(seconds: 2), () => _json({'status': 'OK'})),
      timeout: const Duration(milliseconds: 50),
    );
    final result = await api.getRouteBetweenCoordinates(_apiKey, _origin, _destination);
    expect(result.status, ResultPolyline.statusError);
    expect(result.errorMessage, contains('yanıtlanmadı'));
  });
}
