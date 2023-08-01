# Polyline Points Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_polyline.svg)](https://pub.dev/packages/google_maps_polyline)

Polyline Points Flutter, haritalarda polilinelerle çalışmak için kullanılan bir Flutter paketidir. Bu paket, Google Polilinelerini çözme ve kodlama işlemleri yapmanıza, ayrıca Google Yönlendirme API'sini kullanarak koordinatlar arasında rota almanıza olanak sağlar.

## Kullanım

1. İlk olarak, projenize `google_maps_flutter` paketini ekleyin. `pubspec.yaml` dosyasını aşağıdaki gibi düzenleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
```

2. Ardından, projenize `google_maps_polyline` paketini ekleyin. `pubspec.yaml` dosyasını aşağıdaki gibi düzenleyin ve paketi projenize ekleyin:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
  google_maps_polyline: ^1.0.2
```

3. İşte bir örnek kod:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/utils/my_request_enums.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/utils/result_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    drawPolyline();
  }

  void drawPolyline() async {
    // PolylinePointsFlutter sınıfını oluşturun
    PolylinePointsFlutter polylinePoints = PolylinePointsFlutter();

    // Kendi Google API anahtarınız ile değiştirin
    String googleApiKey = "SİZİN_GOOGLE_API_ANAHTARINIZ";

    // Başlangıç ve hedef koordinatları belirleyin
    MyPointLatLng origin = MyPointLatLng(37.7749, -122.4194); // San Francisco
    MyPointLatLng destination = MyPointLatLng(34.0522, -118.2437); // Los Angeles

    // Rota için API'ya istek gönderin ve sonuç polyline'ini alın
    ResultPolyline result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      origin,
      destination,
      travelMode: MyTravelMode.driving,
    );

    // Başarılı bir şekilde bir rota alındıysa, poliline çizmek için kullanılacak LatLng listesi oluşturun
    if (result.status == "ok" && result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
      }

      // Poliline'ı çizin ve polylines kümesine ekleyin
      polylines.add(Polyline(
        polylineId: const PolylineId("polylineIdString"),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyline Points Flutter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 10,
        ),
        polylines: polylines,
      ),
    );
  }
}

```

Bu örnekte, `PolylinePointsFlutter` sınıfı kullanılarak bir poliline çizilmektedir. `getRouteBetweenCoordinates` fonksiyonu, Google Yönlendirme API'sini kullanarak iki koordinat arasındaki rotayı alır.

---

Bu kadar! Artık Flutter projenizde Polyline Points Flutter paketini kullanabilirsiniz. Haritalarda polilinelerle çalışmak için `PolylinePointsFlutter` sınıfını kullanabilirsiniz.

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır. Daha fazla bilgi için [LICENSE](https://pub.dev/packages/google_maps_polyline/license) dosyasını inceleyebilirsiniz.

# Polyline Points Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_polyline.svg)](https://pub.dev/packages/google_maps_polyline)

Polyline Points Flutter is a Flutter package that provides utilities for working with polylines on maps. This package allows you to decode and encode Google Polylines, and get routes between coordinates using the Google Directions API.

## Usage

1. First, add the `google_maps_flutter` package to your project. Edit the `pubspec.yaml` file as follows:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
```

2. Next, add the `google_maps_polyline` package to your project. Edit the `pubspec.yaml` file as follows and add the package to your project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.0.10
  google_maps_polyline: ^1.0.2
```

3. Here's an example code:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/point_latlng.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/utils/my_request_enums.dart';
// ignore: implementation_imports
import 'package:flutter_polyline_points/src/utils/result_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    drawPolyline();
  }

  void drawPolyline() async {
    // PolylinePointsFlutter sınıfını oluşturun
    PolylinePointsFlutter polylinePoints = PolylinePointsFlutter();

    // Kendi Google API anahtarınız ile değiştirin
    String googleApiKey = "SİZİN_GOOGLE_API_ANAHTARINIZ";

    // Başlangıç ve hedef koordinatları belirleyin
    MyPointLatLng origin = MyPointLatLng(37.7749, -122.4194); // San Francisco
    MyPointLatLng destination = MyPointLatLng(34.0522, -118.2437); // Los Angeles

    // Rota için API'ya istek gönderin ve sonuç polyline'ini alın
    ResultPolyline result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      origin,
      destination,
      travelMode: MyTravelMode.driving,
    );

    // Başarılı bir şekilde bir rota alındıysa, poliline çizmek için kullanılacak LatLng listesi oluşturun
    if (result.status == "ok" && result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = [];
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude!, point.longitude!));
      }

      // Poliline'ı çizin ve polylines kümesine ekleyin
      polylines.add(Polyline(
        polylineId: const PolylineId("polylineIdString"),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyline Points Flutter Demo"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 10,
        ),
        polylines: polylines,
      ),
    );
  }
}

```

In this example, the `PolylinePointsFlutter` class is used to draw a polyline on the map. The `getRouteBetweenCoordinates` function retrieves the route between two coordinates using the Google Directions API.

---

That's it! You can now use the Polyline Points Flutter package in your Flutter project to work with polylines on maps.

## License

This project is licensed under the MIT License. For more information, see the [LICENSE](https://pub.dev/packages/google_maps_polyline/license) file.