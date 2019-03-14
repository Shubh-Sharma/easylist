import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoloc;

import '../helpers/ensure_visible.dart';
import '../../models/product.dart';
import '../../models/location_data.dart';

class LocationInput extends StatefulWidget {
  Function setLocation;
  Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  Uri _staticMapUri;
  LocationData _locationData;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }
    _addressInputFocusNode.addListener(_updateLocation);
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    _addressInputFocusNode.dispose();
    super.dispose();
  }

  Future<String> _getAddress(double lat, double lng) async {
    final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${lat.toString()},${lng.toString()}',
        'key': 'AIzaSyBNAfoz2HjQDCCz8i9mbtDqbsDzxhns6fo'
      });
    final http.Response response = await http.get(uri);
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String formattedAddress = responseData['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geoloc.Location();
    final currentLocation = await location.getLocation();
    final address = await _getAddress(currentLocation['latitude'], currentLocation['longitude']);
  }

  void _getStaticMap(String address, {geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': 'AIzaSyBNAfoz2HjQDCCz8i9mbtDqbsDzxhns6fo'
      });
      final http.Response response = await http.get(uri);

      final Map<String, dynamic> responseData = json.decode(response.body);
      final formattedAddress = responseData['results'][0]['formatted_address'];
      final coords = responseData['results'][0]['geometry']['location'];
      _locationData = LocationData(
          latitude: coords['lat'],
          longitude: coords['lng'],
          address: formattedAddress);
    } else {
      _locationData = widget.product.location;
    }

    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyBNAfoz2HjQDCCz8i9mbtDqbsDzxhns6fo');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker("position", "Position", _locationData.latitude,
          _locationData.longitude),
    ],
        center: Location(_locationData.latitude, _locationData.longitude),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
    widget.setLocation(_locationData);
    setState(() {
      _addressInputController.text = _locationData.address;
      _staticMapUri = staticMapUri;
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            focusNode: _addressInputFocusNode,
            controller: _addressInputController,
            decoration: InputDecoration(labelText: "Address"),
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(
          child: Text("Locate me"),
          onPressed: _getUserLocation,
        ),
        SizedBox(
          height: 10.0,
        ),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString())
      ],
    );
  }
}
