import 'package:flutter/material.dart';

///保存常量
const int timeOut = 5000;

class Application {
  static Widget progressWidget = new Center(
    child: new CircularProgressIndicator(),
  );

  static Widget getReloadWidget({VoidCallback onPressed}) {
    return new Center(
      child: new FlatButton(
          onPressed: onPressed,
          child: new Text(
            '请求数据出错，请点击重试.',
            style: new TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.italic,
                color: Colors.blue),
          )),
    );
  }
}
