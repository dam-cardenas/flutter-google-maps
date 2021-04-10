import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

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
  double zoom = 14.0;
  double radius = 1000;
  MapController mc = new MapController();

  //Widget mainWidget
  @override
  void initState() {
    super.initState();
    getLocationPermissions().then((enabled) {
      if (_permissionGranted == PermissionStatus.granted) {
        // show map
        // start with location service
        marker.onLocationChanged.listen((LocationData currentLocation) {
          setState(() {
            l = new LatLng(currentLocation.latitude, currentLocation.longitude);
            if (mc != null) {
              try {
                mc.move(l, zoom);
              } catch (e) {
                print(e);
              }
            }
            print(l);
          });
        });
      }
    });
  }

  Future<bool> getLocationPermissions() async {
    try {
      _serviceEnabled = await marker.serviceEnabled();
      while (!_serviceEnabled) {
        _serviceEnabled = await marker.requestService();
        setState(() {});
      }
      _permissionGranted = await marker.hasPermission();
      while (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await marker.requestPermission();
        setState(() {});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget loader() {
    return Center(
      child: Text('Loading...'),
    );
  }

  Widget mapWidget() {
    var circleMarkers = <CircleMarker>[
      CircleMarker(
          point: l,
          color: Colors.blue.withOpacity(0.7),
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          radius: radius // meassure in meters
          ),
    ];
    return Center(
      child: FlutterMap(
        mapController: mc,
        options: MapOptions(center: l, zoom: zoom, interactive: false),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          CircleLayerOptions(circles: circleMarkers),
          new MarkerLayerOptions(markers: [
            new Marker(
              point: l,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            )
          ]),
        ],
      ),
    );
  }

  Widget uiControlls() {
    return Column(
      children: [
        Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: 60.0),
            child: Column(
              children: [
                Text(
                  'Radius',
                  textAlign: TextAlign.left,
                ),
                Slider(
                  value: radius.toDouble(),
                  min: 1000,
                  max: 30000,
                  divisions: 30,
                  label: '${(radius / 1000).round()} KM',
                  onChanged: (value) {
                    setState(() {
                      radius = value;
                    });
                  },
                ),
              ],
            )),
        Container(
            color: Colors.white,
            margin: const EdgeInsets.only(top: 60.0),
            child: Column(
              children: [
                Text(
                  'Zoom',
                  textAlign: TextAlign.left,
                ),
                Slider(
                  value: zoom.toDouble(),
                  min: 5,
                  max: 17,
                  divisions: 100,
                  onChanged: (value) {
                    setState(() {
                      zoom = value;
                      try {
                        mc.move(l, zoom);
                      } catch (e) {
                        print(e);
                      }
                    });
                  },
                )
              ],
            ))
      ],
    );
  }

  List<Widget> generateChildren() {
    List<Widget> widgets = [];
    widgets.add(
        _permissionGranted == PermissionStatus.granted && _serviceEnabled
            ? mapWidget()
            : loader());
    widgets.add(uiControlls());
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(children: generateChildren()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.save),
            backgroundColor: Colors.green,
            onPressed: () {
              // TODO: call saving method
              //
            }),
      ),
    );
  }
}
