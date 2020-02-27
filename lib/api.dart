import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'database.dart';
import 'busdata.dart';
/*
 *  Creates an interface for the frontend to access the backends
 */
class BackendInterface {
  Future<Position> getAsyncCurrentPos(){}
  Future<List<BusData>> getBusesByStr(String str){}
  //doRefresh(Timer t){}
}

class BusAppAPI implements BackendInterface {

  BusAppBase dbase;

  BusAppAPI(){
    this.dbase = new BusAppBase();
  }

  Future<Position> getAsyncCurrentPos() async {
    return this.dbase.getCurrentPosition();
  }

  Future<List<BusData>> getBusesByStr(String str) async {
    Future<List<BusData>> output = this.dbase.refreshData().then((DateTime timestamp) {
      return this.dbase.parseData(this.dbase.parseStringForBusID(str));
    });
    return output;
  }

//  doRefresh(Timer t) async {
//    this.dbase.refreshData();
//  }
}