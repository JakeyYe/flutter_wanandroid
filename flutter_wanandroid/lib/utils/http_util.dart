import 'dart:io';

import 'package:dio/dio.dart';

import '../common/config.dart';
import '../model/data_model.dart';

class HttpUtil {

  static Dio dio = new Dio(new Options(
      connectTimeout: timeOut, headers: {"content-Type": "application/json"}));

  ///get网络请求
  static Future<DataModel> get(String url, [List params]) async {
    ///页码
    if (params != null) {
      url = fillPage(url, params);
    }

    try {
      Response response = await dio.get(url);

      if (response.statusCode == HttpStatus.OK) {
        ///200，有两种情况，数据为空，数据不为空
        Map map = response.data;
        print('get response data ${response.data}');

        return new DataModel(
            data: map['data'],

            ///0
            errorCode: map['errorCode'],
            errorMsg: map['errorMsg']);
      } else {
        print('url :$url \n错误msg ：\n${response.statusCode}');
        return getErrorModel();
      }
    } on DioError catch (e) {

      ///网络请求超时异常
      if(e.type==DioErrorType.CONNECT_TIMEOUT){
        print('---Error DioErrorType connect timeOut---');
        return getErrorModel(1);
      }

      ///DioError.response响应信息，如果发生在服务器返回数据之前，则为null
      if (e.response != null) {
        print('---Error response is not null------------');
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        return getErrorModel();
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print('---Error response is null------------------');
        print(e.message);
        return getErrorModel(2);
      }
    }
  }

  ///post网络请求
  static Future<DataModel> post(String url, Map map, [List params]) async {
    ///页码
    if (params != null) {
      url = fillPage(url, params);
    }

    try {
      Response response = await dio.post(url, data: map);

      if (response.statusCode == HttpStatus.OK) {
        print('post reponse.body ${response.data}');

        ///Response.data已经解析为Map数据类型了
        Map map = response.data;

        ///Response.headers 请求头数据
        print(response.headers['set-cookie']);///返回的是List的

//        ///登录请求，请求成功后保存cookie，后面可以根据cookie做自动登录
//        if (map['errorCode'] == 0 && url == login_api) {
//          print(response.headers.cookies);
//          setCookie(response.headers.cookies);
//        }
        return new DataModel(
            data: map['data'],
            errorCode: map['errorCode'],
            errorMsg: map['errorMsg']);
      } else {
        print('url :$url \n错误msg ：\n${response.statusCode}');
        return getErrorModel();
      }
    } on DioError catch (e) {
      ///网络请求超时异常
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        print('---Error DioErrorType connect timeOut---');
        return getErrorModel(1);
      }

      ///DioError.response响应信息，如果发生在服务器返回数据之前，则为null
      if (e.response != null) {
        print('---Error response is not null------------');
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
        return getErrorModel();
      } else {
        ///无网络的请求下跳转到这里，抛出SocketException 异常

        ///事件发生在设置或发送请求，触发一个错误
        /// Something happened in setting up or sending the request that triggered an Error
        print('---Error response is null------------------');
        print(e.message);
        return getErrorModel(2);
      }
    }
  }

  static DataModel getErrorModel([int tag = 0]) {
    String errorMsg;
    switch (tag) {
      case 0:
        errorMsg = '网络请求错误，请稍后重试';
        break;
      case 1:
        errorMsg = '网络请求超时，请稍后重试';
        break;
      case 2:
        errorMsg = '网络未连接，请检查网络后重试';
        break;
      default:
        errorMsg = '未知异常';
        break;
    }
    return new DataModel(data: null, errorCode: -1, errorMsg: errorMsg);
  }

  static String fillPage(String url, List params) {

    int index=0;
    for(int param in params){
      if (url.contains('{param}',index)) {
        index=url.indexOf(new RegExp(r'{param}'))+'{param}'.length;

        url=url.replaceFirst(new RegExp(r'{param}'), param.toString());
      }
    }

    return url;
  }
}
