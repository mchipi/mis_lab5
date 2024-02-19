import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mis_lab3/models/location_model.dart';

class MapScreen extends StatefulWidget {
  final List<LocationModel> locations;

  const MapScreen({
    required this.locations,
    super.key
    });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool userLocation = false;
  Location location = Location();
  LatLng? currentLocation;
  Marker? currentMarker;
  static const LatLng _cameraPostition = LatLng(41.988466302674475, 21.46444417848708);
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
    initMarkers();
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation != null) {
      markers.add(Marker(
          markerId: const MarkerId("initialPosition"),
          position: currentLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
      return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition:
            const CameraPosition(target: _cameraPostition, zoom: 15),
        markers: markers,
        polylines: Set<Polyline>.of(polylines.values),
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> cametaToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
  }

  void initMarkers() {
    for (LocationModel location in widget.locations) {
      markers.add(Marker(
          markerId: MarkerId(location.name),
          position: LatLng(location.latitude, location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen)));
    }
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      return;
    }

    serviceEnabled = await location.requestService();

    permissionGranted = await location.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      updateCurrentLocation(currentLocation);
    });
  }

  void updateCurrentLocation(LocationData currentLocation) {
    if (currentLocation.latitude == null || currentLocation.longitude == null) {
      return;
    }

    if (!userLocation) {
      setState(() {
        this.currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        userLocation = true;
        cametaToPosition(this.currentLocation!);
        getPolyLinePoints(
            LocationData.fromMap({
              "latitude": currentLocation.latitude,
              "longitude": currentLocation.longitude
            }),
            LocationData.fromMap({
              "latitude": widget.locations[0].latitude,
              "longitude": widget.locations[0].longitude
            })).then((points) => {gereratePolyline(points)});
      });
    }
  }

  Future<List<LatLng>> getPolyLinePoints(
      LocationData start, LocationData end) async {
        const googleApiKey = "AIzaSyAvi5nnAzmGs0S1-jSNTJG2GMG6AelXIpY";
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey,
        PointLatLng(start.latitude!, end.longitude!),
        PointLatLng(
            widget.locations[0].latitude, widget.locations[0].longitude),
        travelMode: TravelMode.driving);
    return result.points.map((e) => (LatLng(e.latitude, e.longitude))).toList();
  }

  void gereratePolyline(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 3);
    setState(() {
      polylines[id] = polyline;
    });
  }
}