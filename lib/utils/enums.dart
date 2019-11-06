import 'package:flutter/material.dart';

enum Status{
  ONLINE,
  NEED_AUTHENTICATION,
  NULL_STATUS,
  OFFLINE,
}

Status getStatusFromStr(String str){
  return str == "online" ? Status.ONLINE
      : str == "need-authentication" ? Status.NEED_AUTHENTICATION
      : str == "offline" ? Status.OFFLINE
      : Status.NULL_STATUS;
}

getColorByStatus(Status status){
  return status == Status.ONLINE ? Colors.green
      : status == Status.NEED_AUTHENTICATION ? Colors.orange
      : status == Status.OFFLINE ? Colors.red
      : Colors.black;
}