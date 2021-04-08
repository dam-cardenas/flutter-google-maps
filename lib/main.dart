import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  Location marker = new Location();
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  bool _serviceEnabled;
  LatLng l;
  var zoom = 16.0;
  MapController mc = new MapController();

  @override
  void initState() {
    super.initState();
    getPermissions();

    marker.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        l = new LatLng(currentLocation.latitude, currentLocation.longitude);
        if (mc != null) {
          mc.move(l, zoom);
        }
        print(l);
      });
    });
  }

  void getPermissions() async {
    _serviceEnabled = await marker.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await marker.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await marker.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await marker.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var circleMarkers = <CircleMarker>[
      CircleMarker(
          point: l,
          color: Colors.blue.withOpacity(0.7),
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          radius: 2000 // 2000 meters | 2 km
          ),
    ];
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            child: FlutterMap(
              mapController: mc,
              options: MapOptions(
                center: l,
                zoom: zoom,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                CircleLayerOptions(circles: circleMarkers),
                new MarkerLayerOptions(markers: [
                  new Marker(
                    width: 80.0,
                    height: 80.0,
                    point: l,
                    builder: (ctx) => new Container(
                      child: new FlutterLogo(),
                    ),
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
