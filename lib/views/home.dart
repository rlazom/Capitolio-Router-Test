import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_functions.dart';
import '../utils/enums.dart';
import '../utils/colors.dart';
import 'conexion_config.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Timer _timerSubscription;
  List routerList;
  int checkTimer;
  Future<Status> fStatus;
  Future<List> fRouterList;
  Status status;
  String text;
  bool loading;
  bool silentLoading;
  bool autoCheckTimer;

  @override
  initState() {
    super.initState();

    routerList = new List();
    status = Status.NULL_STATUS;
    text = '';
    autoCheckTimer = true;
    loading = false;
    silentLoading = false;
    _loadSharedPreferences();
    fStatus = checkConnection();
  }

  Future _loadSharedPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    checkTimer = prefs.getInt('checkTimer') ?? 20;
    autoCheckTimer = prefs.getBool('autoCheckTimer') ?? true;

    if(autoCheckTimer) {
      setCheckTimer(checkTimer);
    }
  }
  setCheckTimer(int timer){
    print('setCheckTimer($timer)');
    _timerSubscription = Timer.periodic(Duration(seconds: timer), (_) {
      checkConnection(showLoading: false);
    });
  }

  Future resetConnection() async {
    print('HOME resetConnection()');

    setState(() {
      loading = true;
      text = 'Rebooting Router...';
      status = Status.OFFLINE;
    });
    await ApiRequests().resetConnection('3');
    setState(() {
      loading = false;
    });
    print('HOME resetConnection().DONE');
  }
  Future<Status> checkConnection({showLoading = true}) async {
    print('HOME checkConnection()');
    if(showLoading) {
      setState(() {
        loading = true;
        silentLoading = false;
        text = 'Loading Connection status...';
      });
    }
    else{
      setState(() {
        silentLoading = true;
        loading = false;
      });
    }
    String statusStr = await ApiRequests().checkConnectionStatus('jany');
    print('HOME statusStr = $statusStr');
    setState(() {
      status = getStatusFromStr(statusStr);
      loading = false;
      silentLoading = false;
    });
    print('HOME checkConnection().DONE');
    return status;
  }

  void cancelTimerSubscription(){
    print('cancelTimerSubscription()---');
    setState(() {
      loading = false;
      silentLoading = false;
    });
    _timerSubscription?.cancel();
  }

  goToSettings() async{
    MaterialPageRoute route = MaterialPageRoute(builder: (context) =>
        ConexionConfigData(),
    );

    cancelTimerSubscription();
    await Navigator.push(
      context,
      route, //MaterialPageRoute
    );

    var prefs = await SharedPreferences.getInstance();
    checkTimer = prefs.getInt('checkTimer') ?? 20;
    autoCheckTimer = prefs.getBool('autoCheckTimer') ?? true;

    print('Check automatic: $autoCheckTimer');
    if(autoCheckTimer) {
      setCheckTimer(checkTimer);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackList = new List<Widget>();

    stackList.addAll([
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
      new FutureBuilder(
          future: fStatus,
          builder: (context, snapshot) {

            return new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RouterWdt(
                    resetConnection: resetConnection,
                    status: status,
                  ),

                  new Tooltip(
                    message: 'Refresh Connection Status',
                    child: new Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: new OutlineButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        borderSide: BorderSide(color: Colors.white70),
                        highlightedBorderColor: Colors.white,
                        disabledBorderColor: Colors.white12,
                        disabledTextColor: Colors.white12,
                        onPressed: checkConnection,
                        child: new Text('Refresh',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
//              }
          }
      ),
      loading ? new Container() : new Positioned(
          top: 8.0,
          right: 8.0,
          child: new IconButton(
            icon: new Icon(Icons.settings, color: Colors.white24,),
            tooltip: 'Settings',
//                onPressed: _ToggleConexionDataStatus,
            onPressed: goToSettings,
          )
      ),// settings
      silentLoading ? LinearProgressIndicator() : new Container(),
    ]);


    if(loading){
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

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new Stack(
        children: stackList,
      ),
    );
  }
}

class RouterWdt extends StatelessWidget {
  final Status status;
  final Function resetConnection;

  const RouterWdt({Key key, this.status, this.resetConnection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new OutlineButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          borderSide: BorderSide(color: Colors.white70),
          highlightedBorderColor: Colors.white,
          disabledBorderColor: Colors.white12,
          disabledTextColor: Colors.white12,
          onPressed: null,
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text('Jany Router',
                style: TextStyle(
                    color: Colors.white70, fontSize: 18.0),
              ),
              new Padding(
                padding: const EdgeInsets.only (left: 8.0),
                child: new Icon(
                  Icons.settings_input_antenna,
                  color: getColorByStatus(status),
                  size: 18.0,
                ),
              )
            ],
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Tooltip(
            message: 'Reboot',
            child: new RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: kPrimaryColor,
              onPressed: resetConnection,
              child: new Icon(Icons.call_missed_outgoing,color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
