import 'package:meta/meta.dart';

///DataModel 是基础返回数据Model
class DataModel {
  int errorCode;
  String errorMsg;
  dynamic data;///动态类型，根据不同返回接口，数据类型不同

  DataModel(
      {@required this.data, @required this.errorCode, @required this.errorMsg});

  @override
  String toString() {
    return '{"errorCode": $errorCode,"errorMsg": $errorMsg,"data": $data}';
  }
}
