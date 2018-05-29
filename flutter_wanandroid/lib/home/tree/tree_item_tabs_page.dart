import 'package:flutter_wanandroid/common/config.dart';
import 'package:flutter_wanandroid/adapter/feed_item_adapter.dart';

import 'package:flutter_wanandroid/widgets/pull_to_refresh/pull_to_refresh.dart';

///TODO TabBarPage和IndexPage中的ListView相同，后期是不是可以提取出来
class TabBarPage extends StatefulWidget {
  final int cid;

  TabBarPage({@required Key key, @required this.cid}) : super(key: key);

  @override
  _TabBarPageState createState() => new _TabBarPageState();
}

///AutomaticKeepAliveClientMixin对保留Page状态有作用
class _TabBarPageState extends State<TabBarPage>
    with AutomaticKeepAliveClientMixin<TabBarPage> {
  bool loading = true;
  bool isReload = false;
  List<dynamic> data;

  bool hasMore = true;

  int itemSize;

  ///当前页数，参数从0开始
  int curPage = 0;

  RefreshController _refreshController;
  FeedItemAdapter _feedItemAdapter;

  _loadData() async {
    print('TabBarPage _loadData');

    await HttpUtil
        .get(tree_article_api, <int>[curPage, widget.cid]).then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        curPage++;

        ///判断是否还有更多数据
        if (dataModel.data['curPage'] < dataModel.data['pageCount']) {
          hasMore = true;
        } else {
          hasMore = false;
        }

        if (data != null) {
          data.addAll(dataModel.data['datas']);
          itemSize = data.length;

          _refreshController.sendBack(false, RefreshStatus.idle);
        } else {
          data = dataModel.data['datas'];
          itemSize = data.length;
        }

        setState(() {
          loading = false;
          isReload = false;
        });
      } else {
        if (data != null) {
          _refreshController.sendBack(false, RefreshStatus.failed);
        } else {
          setState(() {
            loading = false;
            isReload = true;
          });
        }
      }
    });
  }

  _buildTabPage() {
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
        body = new SmartRefresher(
            enablePullDown: false,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            footerBuilder: _footerCreate,
            child: new ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemSize,
                itemBuilder: (context, index) {
                  print('TabBarPage index $index');
                  return _feedItemAdapter.getItemView(context, data[index]);
                }));
      }
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshController = new RefreshController();
    _feedItemAdapter = new FeedItemAdapter();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTabPage();
  }

  Widget _footerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: 'loading...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: '上拉加载更多...',
    );
  }

  ///无论顶部还是底部的指示器，当进入刷新状态，onRefresh都会被回调
  _onRefresh(bool up) {
    if (!up) {
      if (hasMore) {
        _loadData();
      } else {
        _refreshController.sendBack(false, RefreshStatus.noMore);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class TreeItemTabsPage extends StatefulWidget {
  final Map<String, int> tabsLabel;
  final String title;

  TreeItemTabsPage(
      {@required Key key, @required this.title, @required this.tabsLabel})
      : super(key: key);

  @override
  _TreeItemTabsPageState createState() => new _TreeItemTabsPageState();
}

class _TreeItemTabsPageState extends State<TreeItemTabsPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        new TabController(length: widget.tabsLabel.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),

        ///TODO TabBar的tab点击跳转到相对页面出错，是AutomaticKeepAliveClientMixin的问题
        bottom: new TabBar(
            controller: _controller,
            isScrollable: true,
            indicator: const UnderlineTabIndicator(),
            tabs: widget.tabsLabel.keys.map((label) {
              return new Tab(text: label);
            }).toList()),
      ),
      body: new TabBarView(
//        key: new Key('tree_item_tabs'),
        controller: _controller,
        children: widget.tabsLabel.keys.map((label) {
          return new TabBarPage(
            key: new Key(label),
            cid: widget.tabsLabel[label],
          );
        }).toList(),
      ),
    );
  }
}
