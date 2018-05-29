import 'package:flutter_wanandroid/common/config.dart';
import 'package:flutter_wanandroid/home/main_screen.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:flutter_wanandroid/home/navi_page.dart';

void main() {

  Chain.capture(() {
    runApp(new MyApp());
  }, onError: (final error, final Chain chain) {
    print("Caught error $error\n"
        "${chain.terse}");
  });
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
