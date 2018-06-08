import 'package:flutter/material.dart';

///保存常量
const int timeOut = 5000;

class Application {
  static Widget progressWidget = new Center(
    child: new CircularProgressIndicator(),
  );

  static Widget loadMoreWidget = new Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      new CircularProgressIndicator(value: 8.0,),
      new Text('加载中...',style: new TextStyle(fontSize: 16.0),)
    ],
  );

  static Widget noMoreWidget = new Center(
    child: new Text('没有更多了:(',style: new TextStyle(fontSize: 16.0),),
  );

  static Widget getLoadMoreFailedWidget({VoidCallback onPressed}) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Icon(Icons.sms_failed),
        new FlatButton(onPressed: onPressed, child: new Text('加载失败，点击重试',style: new TextStyle(fontSize: 16.0),))
      ],
    );
  }

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
