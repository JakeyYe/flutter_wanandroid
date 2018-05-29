import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../common/config.dart';
import 'package:url_launcher/url_launcher.dart';

///WebViewPage 具体内容页面 TODO WebView这个页面效果不好
class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  WebViewPage({@required Key key, @required this.title, @required this.url})
      : super(key: key);

  @override
  _DetailPageState createState() => new _DetailPageState();
}

class _DetailPageState extends State<WebViewPage> {

  bool isFavorite=false;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ///flutter_webview_plugin, The webview is not integrated in the widget tree,
    /// it is a native view on top of the flutter view. you won't be able to use snackbars, dialogs ...
    return new WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        ///TODO AppBar上的title设置为跑马灯效果
        title: new Text(widget.title),
        ///TODO 弹出式的Menu不能用，会被native WebView遮挡
        actions: <Widget>[
          new GestureDetector(
            child: new Icon(isFavorite?Icons.favorite:Icons.favorite_border),
            onTap: (){
              setState(() {
                isFavorite=!isFavorite;
              });
            },
          ),
          new SizedBox(width: 8.0,),
          new GestureDetector(
            child: const Icon(Icons.explore),
            onTap: () async {
              if (await canLaunch(widget.url)) {
                await launch(widget.url);
              } else {
                ///这里使用Toast
                print('Could not launch ${widget.url}');
              }
            },
          ),
          new SizedBox(width: 8.0,),
        ],
      ),
    );
  }
}
