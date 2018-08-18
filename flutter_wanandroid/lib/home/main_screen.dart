import '../common/config.dart';
import '../home/drawer_page.dart';
import '../home/index_page.dart';
import '../home/navi_page.dart';
import '../home/project_page.dart';
import '../home/tree/tree_page.dart';

enum _NavigationItemName { indexs, tree, navi, project }

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    String title,
    Color color,
    _NavigationItemName name,
  }):
        _name = name,
        item = new BottomNavigationBarItem(

          ///BottomNavigationBarItem,底部导航栏的Item
          icon: icon,
          title: new Text(title),
          backgroundColor: color,
        );

  final BottomNavigationBarItem item;
  _NavigationItemName _name;
  Widget page;

  Widget build(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    if (page != null) {
      return page;
    }
    switch (_name) {
      case _NavigationItemName.indexs:
        page = new IndexPage(
          scaffoldKey: scaffoldKey,
          key: new Key(_name.toString()),
        );
        break;
      case _NavigationItemName.tree:
        page = new TreePage(
          scaffoldKey: scaffoldKey,
          key: new Key(_name.toString()),
        );
        break;
      case _NavigationItemName.navi:
        page = new NaviPage(
          scaffoldKey: scaffoldKey,
          key: new Key(_name.toString()),
        );
        break;
      case _NavigationItemName.project:
        page = new ProjectPage(
            key: new Key(_name.toString()),
            scaffoldKey: scaffoldKey);
        break;
      default:
      //error
        print('error $_name');
    }
    return page;
  }
}

///主界面
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => new _MainScreenState();
}

///TODO AutomaticKeepAliveClientMixin 对IndexPage跳转WebViewPage会调用IndexPage的build方法没效果
class _MainScreenState extends State<MainScreen>{

  int _currentIndex = 0;

  ///底部导航栏的类型
  BottomNavigationBarType _type = BottomNavigationBarType.fixed;

  ///导航元素
  List<NavigationIconView> _navigationViews;

  ///对应导航元素的页面
  List<Widget> pages = <Widget>[];

  List<String> _titleList = ['首页', '体系', '导航', '项目'];

  ///GlobalKey 全局Key，使用全局Key来唯一标志widget
  ///可以通过GlobalKey.currentState获取当前key对应的Widget的状态
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    ///TODO Dart项目中的StackTrance和Flutter中的不一样，所以需要不同分析
    Log.d(StackTrace.current, 'Log initState');
  }

  Widget _buildNavigationBar(BuildContext context) {
    if (_navigationViews == null || _navigationViews.length == 0) {
      _navigationViews = <NavigationIconView>[
        new NavigationIconView(
            icon: const Icon(Icons.home),
            title: _titleList[0],
            color: Colors.blue,
            name: _NavigationItemName.indexs
        ),
        new NavigationIconView(
            icon: const Icon(Icons.extension),
            title: _titleList[1],
            color: Colors.blue,
            name: _NavigationItemName.tree
        ),
        new NavigationIconView(
            icon: const Icon(Icons.navigation),
            title: _titleList[2],
            color: Colors.blue,
            name: _NavigationItemName.navi
        ),
        new NavigationIconView(
            icon: const Icon(Icons.collections_bookmark),
            title: _titleList[3],
            color: Colors.blue,
            name: _NavigationItemName.project
        )
      ];
    }

    return new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: _type,
      onTap: (int index) {
        ///ValueChanged<int>
        if (index != _currentIndex) {
          print('BottomNavigationBar onTap $index');
          setState(() {
            _currentIndex = index;
          });
        }
      },
    );
  }

  Widget _buildPage(BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) {

    print('_buildPage $_currentIndex');

    _navigationViews[_currentIndex].build(context, scaffoldKey);

    _navigationViews.forEach((NavigationIconView item) {
      if (!(pages.indexOf(item.page) >= 0) && item.page != null) {
        pages.add(item.page);
      }
    });

    ///IndexedStack可以直接控制那个Widget在最上面
    ///这里如果使用IndexedStack的话就不能使用懒加载PageView了
//    return new IndexedStack(
//      index: _currentIndex,
//      children:pages,
//    );

    ///相当于List重新排序
    pages
      ..removeWhere((Widget page) => page == _navigationViews[_currentIndex].page)
      ..add(_navigationViews[_currentIndex].page);

    return new Stack(
      children: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build $_currentIndex');

    Widget botNavBar = _buildNavigationBar(context);

    String appBarTitle;
    if(_currentIndex==0){
      appBarTitle='WanAndroid';
    }else{
      appBarTitle=_titleList[_currentIndex];
    }

    return new Scaffold(
      key: _scaffoldKey,

      ///这里只切换了AppBar和BottomNavigationBar之间的布局
      appBar: new AppBar(
        title: new Text(appBarTitle),
      ),

      drawer: new DrawerPage(scaffoldKey: _scaffoldKey),
      ///BottomNavigationBar模式的，使用Stack作为页面的容器，为每个节目传入一个Key的话，这样
      ///随着底部导航栏切换页面的时候就不会每次都重建页面了
      body: _buildPage(context, _scaffoldKey),

      ///这里界面只是Stack中的一层布局，所以要求每次背景都不能是透明的，否则界面将穿透

      ///这里好像调用了几次
      bottomNavigationBar: botNavBar,
    );
  }
}
