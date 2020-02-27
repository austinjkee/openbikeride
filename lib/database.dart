import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'busdata.dart';

const String baseurl = "https://mctrans.ce.ufl.edu/bikeapp";

//const String sensorurl = "http://mnm.ece.ufl.edu/bikerack/system.php";
const String sensorurl = "http://35.196.203.13/data/data.json";

const Set<int> systemIDWhitelist = {2, 4, 9, 12, 13, 21};

//const Set<String> single_digits = { "zero", "one", "two", "three", "four","five", "six", "seven", "eight", "nine"};
//const Set<String> two_digits = { "", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"};
//const Set<String> tens_digits = {"", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"};
//const Set<String> hundreds_digits = {"hundred"};

class AppBase {
  List<String> parseStringForBusID(String str){}
  Future<DateTime> refreshData(){}
  Future<List<BusData>> getJSONs(){}
  Future<List<BusData>> parseData(List<String> strs){}
  Future<Position> getCurrentPosition(){}
}

class BusAppBase implements AppBase{

  Future<List<BusData>> data;
  DateTime lastUpdated;

  BusAppBase(){
    this.lastUpdated = DateTime.now();
    this.data = getJSONs();
    if(this.data == null){
      throw Exception("There was an error retrieving data from the server!");
    }
  }

  List<String> parseStringForBusID(String str){
    List<String> searchIDs = [];
    //search string for numbers
    RegExp exp = new RegExp(r"([1-9]?\d{1,2})");
    Iterable<RegExpMatch> matches = exp.allMatches(str);
    //populate return variable with matched numbers
    for(RegExpMatch match in matches){
      searchIDs.add(str.substring(match.start, match.end));
    }
    return searchIDs;
  }

  Future<DateTime> refreshData() async {
    if((DateTime.now().difference(lastUpdated)).inMilliseconds > 200 ) {
      this.lastUpdated = DateTime.now();
      this.data = getJSONs();
    }
    return this.lastUpdated;
  }

  Future<List<BusData>> getJSONs() async {
    final res = await http.get(baseurl + "/api/GetRoutes");
    final sensres = await http.get(sensorurl);
    var routes;
    var sensors;

    if (res.statusCode == 200 && sensres.statusCode == 200) {
      //convert from string to json
      routes = json.decode(res.body);
      sensors = json.decode(sensres.body);
    }
    else{
      throw Exception('Failed to contact McTrans api!');
    }

    List<BusData> f = new List<BusData>();

    for(var route in routes){
      if(route['vehiclesDetails'].toString() != "[]"){
        for(var vehicle in route['vehiclesDetails']){
          for(var sensor in sensors) {
            if (vehicle['call_name'] == sensor['call_name']) {
              f.add(BusData.fromJSONs(route, vehicle, sensor));
            }
          }
        }
      }
    }
    this.lastUpdated = DateTime.now();
    return f;
  }

  Future<List<BusData>> parseData(List<String> strs) async {
    List<BusData> outputData = new List<BusData>();

    await this.data.then((List<BusData> dats){
      for(BusData dat in dats) {
        for (String str in strs) {
          if (dat.route_name.toString() == str) {
            outputData.add(dat);
          }
        }
      }
    });
    return outputData;
  }

  Future<Position> getCurrentPosition() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position == null){
      position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return position;
  }
}