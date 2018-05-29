import 'package:flutter/material.dart';
import 'dart:async';

showProgressDialog({BuildContext context}) {
  final ThemeData theme = Theme.of(context);
  final TextStyle dialogTextStyle =
  theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

  showDialog(
      context: context,
      barrierDismissible: false,

      ///添加该属性,设置该属性为false，点击Dialog之外的区域就不会消失，按返回键还是会消失
      builder: (BuildContext context) =>
      new AlertDialog(
        content: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(),
            const SizedBox(
              width: 18.0,
            ),
            new Text(
              '请求中...',
              style: dialogTextStyle,
            ),
          ],
        ),
      ));
}

Future<bool> showAlertDialog(BuildContext context, String alert) {
  final ThemeData theme = Theme.of(context);
  final TextStyle dialogTextStyle =
  theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

  return showDialog(
    context: context,
    builder: (BuildContext context) =>
    new AlertDialog(
        content: new Text(
          alert,
          style: dialogTextStyle,
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context, false);
              }),
          new FlatButton(
              child: const Text('确认'),
              onPressed: () {
                Navigator.pop(context, true);
              })
        ]),
  );
}
