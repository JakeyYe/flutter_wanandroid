import 'package:flutter/material.dart';


class SnackBarUtil{

   static showInSnackBar(GlobalKey<ScaffoldState> scaffoldKey,String value){
     ///隐藏之前要显示或将要显示的Snacker
     scaffoldKey.currentState
         .hideCurrentSnackBar(reason: SnackBarClosedReason.hide);

     ///这个currentState一定要是Scaffold,否则将找不到showSnacker方法
     scaffoldKey.currentState
         .showSnackBar(new SnackBar(content: new Text(value)));

  }
}