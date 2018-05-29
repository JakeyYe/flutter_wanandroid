import '../common/config.dart';
import '../startup/login_page.dart';
import '../notifications/notifications.dart';

///DrawerHeader
class DrawerHeaderPage extends StatefulWidget {
  const DrawerHeaderPage({Key key}) : super(key: key);

  @override
  _DrawerHeaderState createState() => new _DrawerHeaderState();
}

class _DrawerHeaderState extends State<DrawerHeaderPage> {
  ///是否登录
  bool isLogin = false;
  String username;

  @override
  void initState() {
    super.initState();

    ///每次打开Drawer都会调用这个方法
    print('drawer Page initState');

    ///去获取cookie值
    getCookie().then((cookie) {
      if (cookie != null && cookie.isNotEmpty) {

        print('cookie $cookie');
        ///这里解析Cookie
        ///loginUserName=JakeyYe; Expires=Wed, 13-Jun-2018 09:13:39 GMT; Path=/
        ///loginUserPassword=ye829225; Expires=Wed, 13-Jun-2018 09:13:39 GMT; Path=/
        if (cookie.contains('loginUserName=')) {
          List<String> list = cookie.split(';');
          for (String s in list) {
            if (s.contains('loginUserName=')) {
              String loginUserName = s.substring('loginUserName'.length + 1);
              setState(() {
                isLogin = true;
                username = loginUserName;
              });
              break;
            }
          }
        }
      }
    });
  }

  Widget getDrawerHeaderWidgets() {
    //可以使用通知来刷新这个

    Widget widget;

    ///登录状态
    if (isLogin) {
      widget = new Stack(
        children: <Widget>[
          new Container(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                ///圆形Image
                new SizedBox(

                  height: 64.0,
                  width: 64.0,
                  child: new DecoratedBox(
                    decoration: new BoxDecoration(
                      border: new Border.all(
                          width: 1.0, color: const Color(0xFFFFFFFF)),
                      shape: BoxShape.circle,
//                    borderRadius: new BorderRadius.circular(6.0),
                      image: new DecorationImage(
                        image: new AssetImage(
                          'assets/logo.png',
                        ),
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),

                ///圆形图片+用户名(登录状态)
                const SizedBox(
                  width: 12.0,
                ),

                ///用户名
                Text('JakeyYe')
              ],
            ),
          ),

          ///右下角加一个点击弹出选择框，一项操作'退出登录'
          new PositionedDirectional(
            bottom: 12.0,
            end: 12.0,
            child: new GestureDetector(
              child: new Icon(Icons.exit_to_app),
              onTap: () {
                ///弹出弹窗提示用户是否确认退出登录
                showAlertDialog(context, '退出登录？').then((value) {
                  if (value == true) {
                    ///退出登录操作
                    setState(() {
                      isLogin = false;
                    });
                  }
                });
              },
            ),
          ),
        ],
      );
    } else {
      ///非登录状态
      widget = new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ///未登录状态的圆形Image，前景加一层灰色
            new SizedBox(
              ///使用SizedBox来控制大小
              height: 64.0,
              width: 64.0,
              child: new DecoratedBox(
//                child: new Material(color: Colors.grey[400]),
                decoration: new BoxDecoration(
                  border: new Border.all(
                      width: 1.0, color: const Color(0xFFFFFFFF)),
                  shape: BoxShape.circle,
//                    borderRadius: new BorderRadius.circular(6.0),
                  image: new DecorationImage(
                    image: new AssetImage(
                      'assets/logo.png',
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              ///这个装饰是作为背景的，当然也可以设置为前景
            ),

            ///圆形图片+用户名(登录状态)
            const SizedBox(
              width: 12.0,
            ),
            FlatButton(
              child: Text(
                '去登陆',
                style: new TextStyle(color: Colors.blue, fontSize: 16.0),
              ),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return new LoginPage();
                }));
              },
            )
          ],
        ),
      );
    }
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    print('drawer page build');

    ///DrawerHeader有两种状态，登录状态和未登录状态

    ///NotificationListener通知
    return new NotificationListener<LoginChangeNotification>(
        onNotification: (notification){
          isLogin=true;
        },
        child: new DrawerHeader(
      //这个margin是
      margin: EdgeInsets.only(top: 0.0, bottom: 12.0),

      ///背景图片
//        decoration: new BoxDecoration(color: Colors.amberAccent),
      decoration: BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.fill,
              image: new AssetImage('assets/drawer_header_bg.jpg'))),
      duration: const Duration(milliseconds: 750),
      child: getDrawerHeaderWidgets(),
    ));
  }
}

///Drawer,由两部分组成，顶部用户信息和下面的条目
class DrawerPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  DrawerPage({@required this.scaffoldKey});

  @override
  _DrawerPageState createState() => new _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  static const List<String> _drawerContents = const <String>['收藏', '设置', '关于'];

  @override
  Widget build(BuildContext context) {
    final List<Widget> allDrawerItems = <Widget>[
      new DrawerHeaderPage(),

      ///要使用这个MediaQuery.removePadding()才可以将Drawer的布局绘制到statusBar上
      new MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: new Expanded(
              child: new ListView(
            children: <Widget>[_getDrawerItems()],
          )))
    ];

    return new Drawer(
        child: new Column(
      children: allDrawerItems,
    ));
  }

  void _showNotImplementedMessage(String item) {
    Navigator.pop(context); // Dismiss the drawer.
    widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text('Drawer item: $item')));
  }

  Widget _buildListTile(String title, Widget icon, GestureTapCallback onTap) {
    return new ListTile(
      leading: new CircleAvatar(child: icon),
      title: new Text(title),
      onTap: onTap,
    );
  }

  _getDrawerItems() {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        new Divider(
          height: 2.0,
        ),
        _buildListTile(_drawerContents[0], new Icon(Icons.favorite), () {
          _showNotImplementedMessage('收藏');
        }),
        new Divider(
          height: 2.0,
        ),
        _buildListTile(_drawerContents[1], new Icon(Icons.settings), () {
          _showNotImplementedMessage('设置');
        }),
        new Divider(
          height: 2.0,
        ),
        _buildListTile(_drawerContents[2], new Icon(Icons.description), () {
          _showNotImplementedMessage('关于');
        }),
      ],
    );
  }
}
