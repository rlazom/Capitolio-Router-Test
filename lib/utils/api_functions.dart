import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;

import 'package:http/http.dart' as http;


var headerParamsJson = {Io.HttpHeaders.contentTypeHeader: 'application/json'};

class ApiRequests {


  Future resetConnection(String id) async {
    print('resetConnection()');

    var baseUrl = 'https://raul.cu.aleph.engineering';
    var url = baseUrl + '/api/reboot_router/$id';
    var response;

    try {
      response = await http.get(url).timeout(new Duration(seconds: 15));
    } on Io.SocketException catch (_) {
      print('Not connected. Failed to reset Connection');
      throw Exception('Not connected. Failed to reset Connection');
    }

    if(response.statusCode == 200){
      var list = json.decode(response.body);
      return list;
    }
    else{
      throw Exception('Something went wrong');
    }
  }

  Future<String> checkConnectionStatus(String name) async{
    print('checkConnectionStatus($name)');
    List list = await checkAllConnections();
    var myConnection = list.firstWhere((conn) => conn['name'] == name);
    var status = myConnection['status'];
    return status;
  }

  Future<List> checkAllConnections() async {
    print('checkAllConnections()');

    var baseUrl = 'https://raul.cu.aleph.engineering';
    var url = baseUrl + '/api/routers';
    var response;

    try {
      response = await http.get(url).timeout(new Duration(seconds: 15));
    } on Io.SocketException catch (_) {
      print('Not connected. Failed to load Connections');
      throw Exception('Not connected. Failed to load Connections');
    }

    if(response.statusCode == 200){
      var list = json.decode(response.body) as List;
      return list;
    }
    else{
      throw Exception('Something went wrong');
    }
  }

}