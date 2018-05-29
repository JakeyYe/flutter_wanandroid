import 'package:flutter/material.dart';

abstract class BaseAdapter{
  Widget getItemView(BuildContext context,item);
}