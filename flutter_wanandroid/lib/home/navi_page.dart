import '../common/config.dart';
import '../home/web_view_page.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:after_layout/after_layout.dart';

class _ChipsTile extends StatelessWidget {
  const _ChipsTile({
    Key key,
    this.label,
    this.children,
  }) : super(key: key);

  final String label;
  final List<Widget> children;

  // Wraps a list of chips into a ListTile for display as a section in the demo.
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        child: new Text(label, textAlign: TextAlign.start),
      ),
      subtitle: new Wrap(
        children: children
            .map((Widget chip) => new Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: chip,
                ))
            .toList(),
      ),
    );
  }
}

///当前界面关于这个问题 https://github.com/flutter/flutter/issues/12319

class NaviPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  NaviPage({@required Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _NaviPageState createState() => new _NaviPageState();
}

class _NaviPageState extends State<NaviPage> with AfterLayoutMixin<NaviPage> {
  bool loading = true;
  bool isReload = false;
  List<dynamic> data;
  int itemSize;

  ///左边列表数据
  List<String> leftList = <String>[];

  int selectedIndex = 0;

  ScrollController _scrollController;

  List<GlobalKey> rightListKey = <GlobalKey>[];

  List<double> rightListItemTop = <double>[];

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _loadData();
  }

  _loadData() async {
    print('NaviPage _loadData');

    await HttpUtil
        .get(
      navi_api,
    )
        .then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        data = dataModel.data;
        itemSize = data.length;
        print(itemSize);

        for (int i = 0; i < itemSize; i++) {
          leftList.add(data[i]['name']);
        }

        setState(() {
          loading = false;
          isReload = false;
        });
      } else {
        setState(() {
          loading = false;
          isReload = true;
        });
      }
    });
  }

  _buildBody() {
    print('NaviPage _buildBody');
    Widget body;
    if (loading == true) {
      body = Application.progressWidget;
    } else {
      ///获取数据出错，需要重新加载
      if (isReload) {
        body = Application.getReloadWidget(onPressed: () {
          if (!mounted) return;

          setState(() {
            loading = true;
            isReload = false;
          });
          _loadData();
        });
      } else {
        body = new Row(
          children: <Widget>[_buildLeftList(), _buildRightList()],
        );
      }
    }
    return body;
  }

  _buildLeftList() {
    print('NaviPage _buildLeftList');

    return new Expanded(
      child: new NotificationListener<ScrollStartNotification>(
          onNotification: (onNotification) {
            ///在布局完成的第一次操作前完成Widget信息的获取
            if (rightListItemTop.isEmpty) {
              for (int i = 0; i < rightListKey.length; i++) {
                var rect = RectGetter.getRectFromKey(rightListKey[i]);
                rightListItemTop.add(rect.top);
              }
            }
          },
          child: new ListView.builder(
              itemCount: leftList.length,
              itemBuilder: (context, index) {
                return new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new SizedBox(
                        height: 48.0,
                        width: double.infinity,
                        child: new InkWell(
                          onTap: () {
                            ///在布局完成的第一次操作前完成Widget信息的获取
                            if (rightListItemTop.isEmpty) {
                              for (int i = 0; i < rightListKey.length; i++) {
                                var rect =
                                    RectGetter.getRectFromKey(rightListKey[i]);
                                rightListItemTop.add(rect.top);
                              }
                            }

                            if (selectedIndex != index) {
                              selectedIndex = index;
                              ///调用这里就可以设置右边滑动
                              _scrollController.jumpTo(
                                  rightListItemTop[selectedIndex] -
                                      rightListItemTop[0]);
                              ///调用这里设置左边Item切换
                              setState(() {});
                            }
                          },

                          ///设置Item选中的背景颜色
                          child: new Container(
                            color: selectedIndex == index
                                ? Colors.grey[300]
                                : Colors.transparent,
                            child: new Center(
                                child: new Text(
                              leftList[index],
                              style: new TextStyle(fontSize: 16.0),
                            )),
                          ),
                        ),
                      ),
                      new Divider(
                        height: 1.0,
                      ),
                    ]);
              })),
    );
  }

  _buildRightList() {
    print('_NaviPage _buildRightList');

    rightListKey.clear();

    List<Widget> children = <Widget>[];

    for (int i = 0; i < leftList.length; i++) {
      Map<String, String> itemRightList = new Map<String, String>();

      var articles = data[i]['articles'];
      for (int i = 0; i < articles.length; i++) {
        itemRightList.putIfAbsent(
            articles[i]['title'], () => articles[i]['link']);
      }

      final List<Widget> actionChips = itemRightList.keys.map<Widget>(
        (String name) {
          return new ActionChip(
            key: new ValueKey<String>(name),
            label: new Text(name),
            onPressed: () {
              Navigator
                  .of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return new WebViewPage(
                    key: new Key(name), title: name, url: itemRightList[name]);
              }));
            },
          );
        },
      ).toList();

      ///将这个globalKey收集起来，后面获取Widget的信息
      var globalKey = RectGetter.createGlobalKey();

      rightListKey.add(globalKey);

      children.add(new RectGetter(
          key: globalKey,
          child: new GestureDetector(
            onTap: () {
              ///在布局完成的第一次操作前完成Widget信息的获取
              if (rightListItemTop.isEmpty) {
                for (int i = 0; i < rightListKey.length; i++) {
                  var rect = RectGetter.getRectFromKey(rightListKey[i]);
                  rightListItemTop.add(rect.top);
                }
              }
            },
            child: new _ChipsTile(
              label: leftList[i],
              children: actionChips,
            ),
          )));
    }

    return new Expanded(
        flex: 2,
        child: new NotificationListener<ScrollStartNotification>(
            onNotification: (notification) {
              ///在布局完成的第一次操作前完成Widget信息的获取
              if (rightListItemTop.isEmpty) {
                for (int i = 0; i < rightListKey.length; i++) {
                  var rect = RectGetter.getRectFromKey(rightListKey[i]);
                  rightListItemTop.add(rect.top);
                }
              }
            },

            ///直接使用new ListView，children就会在之前全部被创建
            child: new SingleChildScrollView(
              controller: _scrollController,
              child: new Column(
                children: children,
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    print('NaviPage build');
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.grey[100],
      ),
      child: new Material(
        child: _buildBody(),
      ),
    );
  }

  ///TODO 这个方法这里不太好使，因为第一次布局一定是进度条布局，真正的布局至少是在第二次
  @override
  void afterFirstLayout(BuildContext context) {
    // TODO: implement afterFirstLayout
  }
}
