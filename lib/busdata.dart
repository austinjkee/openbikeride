import 'package:google_maps_flutter/google_maps_flutter.dart';


class BusData {
  final String route_name;
  final String call_name;
  final int num_slots;
  final int slots_filled;
  final LatLng coords;

  BusData(this.route_name, this.call_name, this.num_slots, this.slots_filled, this.coords);

  BusData.fromJSONs(Map<String, dynamic> routeJson, Map<String, dynamic> vehicleJson, Map<String, dynamic> sensorJson)
    : route_name = routeJson['short_name'].toString(),
      call_name = vehicleJson['call_name'].toString(),
      num_slots = int.parse(sensorJson['slots_available']),
      slots_filled = int.parse(sensorJson['slots_used']),
      /*coords = Position.fromMap(()=>
          {
            'longitude' : vehicleJson['location_lng'],
            'latitude' : vehicleJson['location_lat'],
            'timestamp' : DateTime.parse(vehicleJson['last_update_on']),
            'mocked' : false,
            'accuracy' : 5,
            'altitude' : 54,
            'heading' : vehicleJson['heading'],
            'speed' : vehicleJson['speed'],
            'speedAccuracy' : 5
          });*/
      coords = LatLng(vehicleJson['location_lat'], vehicleJson['location_lng']);

  Map<String, dynamic> toJson() =>
    {
      'route_name' : route_name,
      'call_name' : call_name,
      'num_slots' : num_slots,
      'slots_filled' : slots_filled,
      'coords' : coords
    };
}