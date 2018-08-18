import 'package:flutter_wanandroid/common/config.dart';
import 'package:flutter_wanandroid/home/main_screen.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {

//  https://pub.flutter-io.cn/packages/stack_trace
//  这里使用是这个开源库，可以处理StackTrack(堆栈跟踪)信息，但是直接这样使用好像是没有效果的
//  Chain.capture(() {
//    runApp(new MyApp());
//  }, onError: (final error, final Chain chain) {
//    print("Caught error $error\n"
//        "${chain.terse}");
//  });
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    ///调用这个可以让状态栏隐藏，下滑还是可以出现，一段时间后消失
//    SystemChrome.setEnabledSystemUIOverlays([]);
    return new MaterialApp(
      title: 'WanAndroid APP',
      //设置debug模式下是否展示banner
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.grey[100],
      ),
      home: MainScreen(),
    );
  }
}
