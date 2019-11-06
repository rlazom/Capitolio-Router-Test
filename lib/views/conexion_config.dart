import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';


class ConexionConfigData extends StatefulWidget {
  ConexionConfigData(
      {Key key})
      : super(key: key);


  @override
  _ConexionConfigDataState createState() => _ConexionConfigDataState();
}

class _ConexionConfigDataState extends State<ConexionConfigData> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _timeCtrl = new TextEditingController();
  bool autoCheckTimer;

  FocusNode fnTime;
  bool _loading;

  @override
  initState() {
    super.initState();
    _loading = false;
    autoCheckTimer = true;
    fnTime = new FocusNode();

    _loadSharedPreferences();
  }

  Future _loadSharedPreferences() async {
    print('_loadSharedPreferences On Boarding');

    var prefs = await SharedPreferences.getInstance();

    var timerInt = prefs.getInt('checkTimer') ?? 20;
    _timeCtrl.text = timerInt.toString().trim();

    autoCheckTimer = prefs.getBool('autoCheckTimer') ?? true;
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    fnTime.dispose();
    super.dispose();
  }

  saveConexionData(BuildContext context) async {
      print('_SaveConexionData()');
      var prefs = await SharedPreferences.getInstance();

      String time = _timeCtrl.text.trim();
      prefs.setInt('checkTimer', int.parse(time));
      prefs.setBool('autoCheckTimer', autoCheckTimer);

      Navigator.pop(context);
      return;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackList = new List<Widget>();
    stackList.addAll([
      new ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: new BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: new Container(
              decoration:
                  new BoxDecoration(color: Colors.black.withOpacity(0.5)),
            ),
          )), // DESENFOQUE
      new ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: new Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 1.0],
              colors: [
                kSecondaryAccentDarkColor,
                kSecondaryBackgroundDarkColor,
              ],
            ),
          ),
        ),
      ), // DEGRADADO
    ]);

    stackList.add(new Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 60.0, right: 60.0),
      child: new Builder(
        builder: (context) => new ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                new TextField(
                  controller: _timeCtrl,
                  focusNode: fnTime,
                  keyboardType: TextInputType.text,
                  autofocus: true,
                  style: TextStyle(color: Colors.white70),
                  cursorColor: Colors.white,
                  decoration: new InputDecoration(
                    prefixIcon: new Icon(
                      Icons.timer,
                      color: Colors.white54,
                    ),
                    labelText: 'Time to check',
                    labelStyle: TextStyle(color: Colors.white54),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54)),
                    hasFloatingPlaceholder: true,
                    hintStyle: new TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),// Server
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text('Automatic Check', style: TextStyle(
                        color: Colors.white54
                      ),),
                      new Switch(
                          value: autoCheckTimer,
                          onChanged: (bool value){
                            setState(() {
                              autoCheckTimer = value;
                            });
                          }
                      ),
                    ],
                  ),
                ),

                new Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: new RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: kPrimaryColor,
                    onPressed: () {
                      saveConexionData(context);
                    },
                    child: new Text(
                      'Save and Continue',
                      style: TextStyle(color: Colors.white70, fontSize: 18.0),
                    ),
                  ),
                ),// BTN Guardar y Continuar

              ],
            ),
      ),
    ));

    if(_loading){
      stackList.add(
        new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: new Container(
                decoration:
                new BoxDecoration(color: Colors.black.withOpacity(0.5)),
              ),
            )), // DESENFOQUE
      );
      stackList.add(
          new Center(
            child: new SizedBox(
              width: 80.0,
              height: 80.0,
              child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor.withOpacity(0.6))
              ),
            ),
          )
      );
    }

    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          centerTitle: true,
          title: new Text(
            'Connection Check Configuration',
          ),
          backgroundColor: kPrimaryColor,
        ),
        body: new Stack(
          children: stackList,
        ),
    );
  }
}