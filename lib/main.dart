import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui';
import 'dart:async';
import 'api.dart';
import 'busdata.dart';

void main() => runApp(BusApp());

class BusApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikeRide App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new BikeRideApp(),
    );
  }
}

class BikeRideApp extends StatefulWidget {
  @override
  BikeRideAppState createState() {
    return new BikeRideAppState();
  }
}

class BikeRideAppState extends State<BikeRideApp> {
  GoogleMapController mapController;

  final BusAppAPI busAppApi = new BusAppAPI();

  //use UF as the default center (29.6436° N, 82.3549° W)
  final LatLng _center = const LatLng(29.6436, -82.3549);

  // Location markers
  final Map<String, Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;

  // Data for testing
  List<BusData> busDataList = new List<BusData>();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Drawer myDrawer = new Drawer();

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
  }

  @override
  Widget build(BuildContext context) {
    //new Timer.periodic(new Duration(seconds:5), busAppApi.doRefresh);
    return Scaffold(
      key: _scaffoldKey,
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        myLocationButtonEnabled: false,
        markers: _markers.values.toSet(),
      ),
      drawer: myDrawer,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _getLocation,
              tooltip: 'Get location',
              child: Icon(Icons.navigation),
            ),
            FloatingActionButton(
              onPressed: () {
                _displaySearchDialog(context);
              },
              tooltip: 'Search routes',
              child: Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }

  /// Set custom map pin for buses
  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5), 'assets/icons/dot.png');
  }

  /// Get the user's current location (async) on the map
  void _getLocation() async {
    var currentLocation = await busAppApi.getAsyncCurrentPos();

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;

      mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15.0,
      )));
    });
  }

  /// Get the bus's location on the map
  void _getBusLocation(LatLng position) async {
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("bus_loc"),
        position: position,
        infoWindow: InfoWindow(title: 'Bus location'),
        icon: pinLocationIcon,
      );
      _markers["Bus Location"] = marker;

      mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: 16.0,
      )));
    });
  }

  void _setBusDataList(input){
    busAppApi.getBusesByStr(input).then((List<BusData> dat) =>
        setState(() {
          busDataList = dat;

          myDrawer = Drawer(
            child: ListView(
              children: _getDrawerList(input),
            ),
          );
          Navigator.of(context).pop();
          _scaffoldKey.currentState.openDrawer();
        })
    );
  }

  /// Display the search dialog
  void _displaySearchDialog(BuildContext context) async {
    // TODO: change AlertDialog if possible
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            title: Text('Search buses'),
            content: TextField(
              onSubmitted: (input) => _setBusDataList(input)
              ,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          width: 16.0, color: Colors.lightBlue.shade900)),
                  contentPadding: EdgeInsets.all(5.0),
                  hintText: 'Enter a bus route'),
            ),
          );
        });
  }

  /// Create a list including route info and bus info
  List<Widget> _getDrawerList(input) {
    List<Widget> drawerList = [];
    var padding = Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'Route $input',
        style: new TextStyle(fontSize: 20.0, color: Colors.black),
      ),
    );
    drawerList.add(padding);
    drawerList.addAll(_getBusInfoItems(busDataList));
    return drawerList;
  }

  /// Create a GestureDetector for every bus
  List<GestureDetector> _getBusInfoItems(List<BusData> list) {
    List<GestureDetector> busInfoItems = [];
    for (BusData element in list) {
      var item = GestureDetector(
          onTap: () async {
            Navigator.of(_scaffoldKey.currentContext).pop();
            _getBusLocation(
                LatLng(element.coords.latitude, element.coords.longitude));
          },
          child: Container(
            margin: EdgeInsets.all(15.0),
            padding: EdgeInsets.all(10.0),
            child: _getSlotsStatus(
                element.call_name, element.num_slots, element.slots_filled),
          ));
      busInfoItems.add(item);
    }
    return busInfoItems;
  }

  /// Display slot status in the drawer
  Row _getSlotsStatus(String busId, int numSlots, int slotsFilled) {
    var row;
    switch (numSlots) {
      case 101:
      case 110:
      case 011:
        {
          switch (slotsFilled) {
            case 0:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 001:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
            case 010:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 011:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text(
                      '     $busId          ',
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
          }
        }
        break;
      case 111:
        {
          switch (slotsFilled) {
            case 0:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 001:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
            case 010:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 100:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 011:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
            case 101:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
            case 110:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.green,
                    ),
                  ],
                );
              }
              break;
            case 111:
              {
                row = Row(
                  children: <Widget>[
                    Icon(Icons.directions_bus, color: Colors.blue),
                    Text('     $busId          '),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ],
                );
              }
              break;
          }
        }
        break;
      default:
        {
          row = Row(
            children: <Widget>[
              Icon(Icons.directions_bus, color: Colors.blue),
              Text('     $busId          '),
              Icon(
                Icons.remove_circle,
                color: Colors.grey,
              ),
              Icon(
                Icons.remove_circle,
                color: Colors.grey,
              ),
              Icon(
                Icons.remove_circle,
                color: Colors.grey,
              ),
            ],
          );
        }
        break;
    }
    return row;
  }
}
