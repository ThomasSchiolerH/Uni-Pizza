import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var address;
  List<double> distances = new List();
  double _latitude, _longitude;

  void calculateDistance() {
    List<double> lat = [55.795380, 55.797539, 55.778690, 55.778570, 55.795680];
    List<double> lon = [12.536150, 12.513710, 12.510310, 12.515550, 12.528540];

    var p = 0.017453292519943295;
    var c = cos;

    for (int i = 0; i < lat.length; i++) {
      var a = 0.5 -
          c((lat[i] - _latitude) * p) / 2 +
          c(_latitude * p) *
              c(lat[i] * p) *
              (1 - c((lon[i] - _longitude) * p)) /
              2;
      var res = 12742 * asin(sqrt(a));
      distances.add(double.parse((res).toStringAsFixed(2)));
    }
    print(distances.toString() +
        "-----------------------------------------------");
  }

  Future<void> _updatePosition() async {
    Position position = await _determinePosition();
    List<Placemark> pm =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      address = pm[0].locality;
      calculateDistance();
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static const _initalCameraPosition = CameraPosition(
    target: LatLng(55.785747, 12.521015),
    zoom: 14,
  );

  GoogleMapController _googleMapController;

  List<Marker> _marker = [];
  static const List<Marker> _list = [
    Marker(
      markerId: MarkerId('4'),
      position: LatLng(55.795380, 12.536150),
      infoWindow: InfoWindow(
        title: 'La Vida Stenovns Pizza',
        snippet: 'Eremitageparken 315,\n2800 Kongens Lyngby',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),
    Marker(
      markerId: MarkerId('5'),
      position: LatLng(55.797539, 12.513710),
      infoWindow: InfoWindow(
          title: 'Il Mondo', snippet: 'Egegårdsvej 1,\n2800 Kongens Lyngby'),
      icon: BitmapDescriptor.defaultMarker,
    ),
    Marker(
      markerId: MarkerId('7'),
      position: LatLng(55.778690, 12.510310),
      infoWindow: InfoWindow(
          title: 'Alunas Pizza',
          snippet: 'Sorgenfrigårdsvej 80B,\n2800 Kongens Lyngby'),
      icon: BitmapDescriptor.defaultMarker,
    ),
    Marker(
      markerId: MarkerId('8'),
      position: LatLng(55.778570, 12.515550),
      infoWindow: InfoWindow(
          title: 'La Sosta Pizza & Bøfhus',
          snippet: 'Carlshøjvej 49,\n2800 Kongens Lyngby'),
      icon: BitmapDescriptor.defaultMarker,
    ),
    Marker(
      markerId: MarkerId('10'),
      position: LatLng(55.795680, 12.528540),
      infoWindow: InfoWindow(
          title: 'Saras Pizza & Burger House',
          snippet: 'Lundtofteparken 67,\n2800 Kongens Lyngby'),
      icon: BitmapDescriptor.defaultMarker,
    ),
  ];

  void initState() {
    super.initState();
    _marker.addAll(_list);
    _updatePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${address}"),
      ),
      body: GoogleMap(
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        initialCameraPosition: _initalCameraPosition,
        mapType: MapType.normal,
        markers: Set<Marker>.of(_marker),
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              splashColor: Colors.orange,
              enableFeedback: true,
              hoverColor: Colors.orange,
              onPressed: () {
                _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(_initalCameraPosition));
              },
              child: const Icon(Icons.center_focus_strong),
            ),
          ),
        ],
      ),
    );
  }
}
