import '../common/config.dart';

///ProjectPage可以直接使用tree_item_tab_page来代替
class ProjectPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  ProjectPage({@required Key key, @required this.scaffoldKey})
      : super(key: key);

  @override
  _ProjectPageState createState() => new _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(
          color: Colors.grey[100],
        ),
        child: new Center(
            child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text('项目页面',style: new TextStyle(fontSize: 18.0),),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Text('与前面一个页面(结构TabBar+TabBarView)相似，故该页面不实现了',style: new TextStyle(fontSize: 16.0),),
            )
          ],
        )));
  }
}
