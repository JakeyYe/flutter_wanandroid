import 'package:flutter_wanandroid/common/config.dart';
import 'package:flutter_wanandroid/home/tree/tree_item_tabs_page.dart';

///知识体系页面
class TreePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  TreePage({@required Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _TreePageState createState() => new _TreePageState();
}

///"children":[
///       {
///           "children":[
///           ],
///           "courseId":13,
///           "id":60,--------------cid
///           "name":"Android Studio相关",
///           "order":1000,
///           "parentChapterId":150,
///           "visible":1
///       },
///       {
///           "children":Array[0],
///           "courseId":13,
///           "id":169,
///           "name":"gradle",
///           "order":1001,
///           "parentChapterId":150,
///           "visible":1
///       },
///       Object{...}
///   ],
///   "courseId":13,
///   "id":150,
///   "name":"开发环境",
///   "order":1,
///   "parentChapterId":0,-------------id
///   "visible":1
class _TreePageState extends State<TreePage> {
  bool loading = true;
  bool isReload = false;
  List<dynamic> data;

  int itemSize;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    print('TreePage _loadData');

    await HttpUtil
        .get(
      tree_api,
    )
        .then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        data = dataModel.data;

        itemSize = data.length;
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
        body = new ListView.builder(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: itemSize,
            itemBuilder: (context, index) {
              print('TreePage index $index');
              return _buildTreeListItem(data[index]);
            });
      }
    }
    return body;
  }

  _buildTreeListItem(item) {
    Color primaryColor = Theme.of(context).primaryColor;

    Map<String, int> tabsLabel = new Map<String, int>();
    StringBuffer stringBuffer = new StringBuffer();

    int length = item['children'].length;
    for (int i = 0; i < length; i++) {
      Map map = item['children'][i];

      tabsLabel.putIfAbsent(map['name'], () => map['id']);

      stringBuffer.write(map['name']);
      if (i < length - 1) {
        stringBuffer.write(' ');
      }
    }

    Widget childsText = new Text(stringBuffer.toString());

    return new Material(
      child: new InkWell(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return new TreeItemTabsPage(
                key: new Key(item['name']),
                title: item['name'],
                tabsLabel: tabsLabel
            );
          }));
        },
        child: new Card(
            elevation: 4.0,
            child: new Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      children: <Widget>[
                        new Text(item['name'],
                            style: new TextStyle(
                                color: primaryColor, fontSize: 18.0)),
                        childsText,
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.grey[100],
      ),
      child: _buildBody(),
    );
  }
}
