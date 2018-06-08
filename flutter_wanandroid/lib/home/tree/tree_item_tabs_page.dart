import 'package:flutter_wanandroid/common/config.dart';
import 'package:flutter_wanandroid/adapter/feed_item_adapter.dart';

import 'package:flutter_wanandroid/widgets/pull_to_refresh/pull_to_refresh.dart';

class SortItemPageBean {
  int cid;

  ///当前TabBar page
  Widget page;

  ///当前页面滑动的位置
  double offset;

  SortItemPageBean({@required this.cid});
}

///TODO SortItemPage和IndexPage中的ListView相同，后期是不是可以提取出来
///SortItemPage代表 tree 的下的TabBarView Page
class SortItemPage extends StatefulWidget {
  final int cid;
  ScrollController controller;
  double offset;

  bool loading = true;
  bool isReload = false;
  List<dynamic> data;

  bool hasMore = true;

  int itemSize;

  bool isLoadMoring = false;
  bool isLoadMoreFailed = false;

  ///当前页数，参数从0开始
  int curPage = 0;

  SortItemPage({@required this.cid, @required this.offset});

  @override
  _SortItemPageState createState() => new _SortItemPageState();
}

///AutomaticKeepAliveClientMixin对保留Page状态有作用
class _SortItemPageState extends State<SortItemPage> {
//  RefreshController _refreshController;
  FeedItemAdapter _feedItemAdapter;

  _loadData() async {
    print('SortItemPage _loadData');

    await HttpUtil.get(
        tree_article_api, <int>[widget.curPage, widget.cid]).then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        widget.curPage++;

        ///判断是否还有更多数据
        if (dataModel.data['curPage'] < dataModel.data['pageCount']) {
          widget.hasMore = true;
        } else {
          widget.hasMore = false;
        }

        if (widget.data != null) {
          widget.data.addAll(dataModel.data['datas']);
          widget.itemSize = widget.data.length;
        } else {
          widget.data = dataModel.data['datas'];
          widget.itemSize = widget.data.length;
        }

        setState(() {
          widget.loading = false;
          widget.isReload = false;
          if (widget.isLoadMoring) {
            widget.isLoadMoring = false;
            if (widget.isLoadMoreFailed) {
              widget.isLoadMoreFailed = false;
            }
          }
        });
      } else {
        setState(() {
          widget.loading = false;
          widget.isReload = true;

          ///加载更多，加载失败
          if (widget.isLoadMoring) {
            widget.isLoadMoreFailed = true;
          }
        });
      }
    });
  }

  _buildTabPage() {
    Widget body;
    if (widget.loading == true) {
      body = Application.progressWidget;
    } else {
      ///获取数据出错，需要重新加载
      if (widget.isReload) {
        body = Application.getReloadWidget(onPressed: () {
          if (!mounted) return;

          setState(() {
            widget.loading = true;
            widget.isReload = false;
          });
          _loadData();
        });
      } else {
        ///TODO 这里上拉加载不使用SmartRefresher了，自己写个简单的上拉加载
        body = new ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.controller,
            shrinkWrap: true,
            itemCount: widget.itemSize + 1,
            itemBuilder: (context, index) {
              print('SortItemPage _buildTabPage index $index');

              ///已加载更多一次，而且加载失败了
              if (widget.isLoadMoring && widget.isLoadMoreFailed) {
                return Application.getLoadMoreFailedWidget(onPressed: () {
                  widget.isLoadMoreFailed=false;
                  _loadData();
                });
              }

              ///滑动到最后一个，显示加载更多的布局
              if (index == widget.itemSize) {
                if (widget.hasMore) {
                  return Application.loadMoreWidget;
                } else {
                  return Application.noMoreWidget;
                }
              }
              return _feedItemAdapter.getItemView(context, widget.data[index]);
            });
      }
    }
    return body;
  }

  @override
  void initState() {
    super.initState();

    print('_SortItemPageState initState');

    ///避免多次请求网络数据
    if (widget.loading) {
      _loadData();
    }
    _feedItemAdapter = new FeedItemAdapter();
  }

  @override
  Widget build(BuildContext context) {
    print('_SortItemPageState build ${widget.cid}');

    ///ScrollController是控制ListView滑动到那个位置的，设置
    widget.controller =
        new ScrollController(initialScrollOffset: widget.offset);
    widget.controller.addListener(() {
      ///当绑定了该ScrollController的ListView滑动时就会调用该方法
      widget.offset = widget.controller.offset;
      print('_SortItemPageState _buildTabPage ${widget.offset}');

      ///这里判断是否滑动到底部了，就可以进行加载更多的操作了
      if (widget.controller.position.pixels ==
          widget.controller.position.maxScrollExtent) {
        if (!widget.isLoadMoring) {
          widget.isLoadMoring = true;
          _loadData();
        }
      }
    });

    return _buildTabPage();
  }
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
  TabController _tabController;
  List<SortItemPageBean> sortItemPageBean = <SortItemPageBean>[];

  @override
  void initState() {
    super.initState();

    print('_TreeItemTabsPageState initState');
    _tabController =
        new TabController(length: widget.tabsLabel.length, vsync: this);

    widget.tabsLabel.keys.map((name) {
      print('_TreeItemTabsPageState $name');
      sortItemPageBean.add(new SortItemPageBean(cid: widget.tabsLabel[name]));
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        bottom: new TabBar(
            controller: _tabController,
            isScrollable: true,
            indicator: const UnderlineTabIndicator(),
            tabs: widget.tabsLabel.keys.map((label) {
              return new Tab(text: label);
            }).toList()),
      ),
      body: new TabBarView(
//        key: new Key('tree_item_tabs'),
        controller: _tabController,
        children: sortItemPageBean.map((bean) {
          if (bean.page == null) {
            bean.offset = 0.0;
            bean.page = new SortItemPage(
              cid: bean.cid,
              offset: bean.offset,
            );
          }
          return bean.page;
        }).toList(),
      ),
    );
  }
}
