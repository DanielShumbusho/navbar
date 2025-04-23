import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:geofencing_api/geofencing_api.dart';
import 'package:geofencing_flutter_plugin/geofencing_flutter_plugin.dart';


import '../Db_helpers/location_db.dart';

class MapInputScreen extends StatefulWidget {
  @override
  _MapInputScreenState createState() => _MapInputScreenState();
}


class _MapInputScreenState extends State<MapInputScreen> {
  gmap.GoogleMapController? _mapController;
  TextEditingController _latController = TextEditingController();
  TextEditingController _lngController = TextEditingController();

  gmap.LatLng? _pickedLocation;


  void _goToLocation() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if(lat == null || lng == null) return;

    final position = gmap.LatLng(lat, lng);

    setState(() {
      _pickedLocation = position;
    });


    _mapController!.animateCamera(
      gmap.CameraUpdate.newLatLngZoom(position, 3),
      duration: const Duration(milliseconds: 1000),
    ).then((_) {
      Future.delayed(Duration(milliseconds: 400), () {
        _mapController!.animateCamera(
          gmap.CameraUpdate.newLatLngZoom(position, 15),
          duration: const Duration(milliseconds: 1000),
        );
      });
    });
  }

  void _saveLocation() async {
    if (_pickedLocation == null) return;

    final newLocation = Locat(
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
    );

    await LocationDatabase.instance.insertLocation(newLocation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location Saved: $_pickedLocation")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Enter Coordinates')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: _latController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Latitude'),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Longitude'),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _goToLocation,
                  child: Text('Discover'),
                ),
              ],
            ),
          ),
          Expanded(
            child: gmap.GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: gmap.CameraPosition(
                target: gmap.LatLng(0.0, 0.0),
                zoom: 2,
              ),
              markers: _pickedLocation == null
                ? {}
                : {
                gmap.Marker(
                  markerId: gmap.MarkerId('pickedLocation'),
                  position: _pickedLocation!,
                )
                },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickedLocation != null ? _saveLocation : null,
                  icon: Icon(Icons.save),
                  label: Text('Save Location'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final locations = await LocationDatabase.instance.getLocations();
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Saved Locations"),
                        content: SizedBox(
                          height: 200,
                          width: 300,
                          child: ListView.builder(
                            itemCount: locations.length,
                            itemBuilder: (context, index){
                              final loc = locations[index];
                              return ListTile(
                                title: Text('Lat: ${loc.latitude}, Lng: ${loc.longitude}'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _latController.text = loc.latitude.toString();
                                  _lngController.text = loc.longitude.toString();
                                  _goToLocation();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  icon:Icon(Icons.list),
                  label: Text('View Saved')
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}