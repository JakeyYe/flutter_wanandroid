import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/pull_to_refresh/pull_to_refresh.dart';

import '../common/config.dart';
import '../home/web_view_page.dart';
import '../widgets/xbanner.dart';
import '../adapter/feed_item_adapter.dart';

class Banner extends StatefulWidget {
  Banner({@required Key key}) : super(key: key);

  @override
  _BannerState createState() => new _BannerState();
}

class _BannerState extends State<Banner> {
  ///有没有点击重新加载的第三种情况？？？
  bool loading = true;
  bool isReload = false;
  List<dynamic> data;

  /// "desc":"",
  /// "id":4,
  /// "imagePath":"http://www.wanandroid.com/blogimgs/ab17e8f9-6b79-450b-8079-0f2287eb6f0f.png",
  /// "isVisible":1,
  /// "order":0,
  /// "title":"看看别人的面经，搞定面试~",
  /// "type":1,
  /// "url":"http://www.wanandroid.com/article/list/0?cid=73"

  @override
  void initState() {
    super.initState();
    print('Banner initState');
    _loadDataBanner();
  }

  _loadDataBanner() async {
    print('_loadData');
    await HttpUtil.get(banner_api).then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        data = dataModel.data;
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

  _buildBanner() {
    return new XBanner(
      data.map((obj) {
        ///TODO 这里有缺陷，还需要更改？？？
        return new DecoratedBox(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                ///对齐方式，如果不指定，默认就是Center方式
                alignment: Alignment.topLeft,

                ///这个才是按原来的比例缩放展示
                fit: BoxFit.fill,
                image: new CachedNetworkImageProvider(obj['imagePath']),
              ),
            ),
            child: new Container(
              ///这里设置宽度无效
              margin: EdgeInsets.only(bottom: 16.0),

              child: new Align(
                child: new SizedBox(
                  height: 36.0,
                  width: double.infinity,
                  child: new DecoratedBox(
                    decoration: new BoxDecoration(color: Colors.black45),
                    child: new Align(
                      child: new Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text(
                          obj['title'],
                          style: new TextStyle(color: Colors.white),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                alignment: Alignment.bottomLeft,
              ),
            ));
      }).toList(),
      pageClick: (i) {
        print('click $i ${data[i]['title']} ${data[i]['url']}');

        ///TODO 这里跳转也会重建
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return new WebViewPage(
              key: new Key('WebViewPage'),
              title: data[i]['title'],
              url: data[i]['url']);
        }));
      },
    );
  }

  _buildBannerBody() {
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
          _loadDataBanner();
        });
      } else {
        body = _buildBanner();
      }
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    print('Banner build');

    ///这个高度可以控制Banner的高度
    return new SizedBox(
      height: 200.0,
      child: _buildBannerBody(),
    );
  }
}

class ArticleList extends StatefulWidget {
  ArticleList({@required Key key}) : super(key: key);

  @override
  _ArticleListState createState() => new _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  bool loading = true;
  bool isReload = false;
  List<dynamic> data;

  ///是否还有更多
  bool hasMore = true;

  ///Banner
  bool loadingBanner = true;
  bool isReloadBanner = false;
  List<dynamic> bannerData;

  ///当前页数
  int curPage = 0;
  int curPageSize = 0;

  RefreshController _refreshController;

  FeedItemAdapter _feedItemAdapter;

  /// "apkLink":"",
  /// "author":"HIT-Alibaba",
  /// "chapterId":73,
  /// "chapterName":"面试相关",
  /// "collect":false,
  /// "courseId":13,
  /// "desc":"",
  /// "envelopePic":"",
  /// "fresh":true,
  /// "id":2945,
  /// "link":"https://hit-alibaba.github.io/interview/basic/network/HTTP.html",
  /// "niceDate":"1天前",
  /// "origin":"",
  /// "projectLink":"",
  /// "publishTime":1526988545000,
  /// "superChapterId":61,
  /// "superChapterName":"热门专题",
  /// "tags":[
  ///
  /// ],
  /// "title":"笔试面试知识整理",
  /// "type":0,
  /// "userId":-1,
  /// "visible":1,
  /// "zan":0

  _loadDataBanner() async {
    print('_loadDataBanner');

    await HttpUtil.get(banner_api).then((dataModel) {
      if (!mounted) return;

      ///这个errorCode只有两种情况
      if (dataModel.errorCode == 0) {
        bannerData = dataModel.data;
        setState(() {
          loadingBanner = false;
          isReloadBanner = false;
        });
      } else {
        setState(() {
          loadingBanner = false;
          isReloadBanner = true;
        });
      }
    });
  }

  _buildBanner() {
    print('_buildBanner');

    return new XBanner(
      bannerData.map((obj) {
        return new DecoratedBox(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                ///对齐方式，如果不指定，默认就是Center方式
                alignment: Alignment.topLeft,

                ///这个才是按原来的比例缩放展示
                fit: BoxFit.fill,
                image: new CachedNetworkImageProvider(obj['imagePath']),
              ),
            ),
            child: new Container(
              margin: EdgeInsets.only(bottom: 16.0),
              child: new Align(
                child: new SizedBox(
                  height: 36.0,
                  width: double.infinity,
                  child: new DecoratedBox(
                    decoration: new BoxDecoration(color: Colors.black45),
                    child: new Align(
                      child: new Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text(
                          obj['title'],
                          style: new TextStyle(color: Colors.white),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
                alignment: Alignment.bottomLeft,
              ),
            ));
      }).toList(),
      pageClick: (i) {
        print('click $i ${bannerData[i]['title']} ${bannerData[i]['url']}');
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return new WebViewPage(

              ///TODO 这样是不是不会重新创建同一个页面了
              key: new Key(bannerData[i]['title']),
              title: bannerData[i]['title'],
              url: bannerData[i]['url']);
        }));
      },
    );
  }

  _buildBannerBody() {
    print('_buildBannerBody');

    Widget body;
    if (loadingBanner == true) {
      body = Application.progressWidget;
    } else {
      ///获取数据出错，需要重新加载
      if (isReloadBanner) {
        body = Application.getReloadWidget(onPressed: () {
          if (!mounted) return;

          setState(() {
            loadingBanner = true;
            isReloadBanner = false;
          });
          _loadDataBanner();
        });
      } else {
        body = _buildBanner();
      }
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController();
    _feedItemAdapter = new FeedItemAdapter();

    print('IndexPage initState');

    ///Banner data
    _loadDataBanner();

    ///ArticleList data
    _loadData();
  }

  _loadData() async {
    print('_loadData');

    await HttpUtil.get(home_articles_api, <int>[curPage]).then((dataModel) {
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
          curPageSize += dataModel.data['size'];

          _refreshController.sendBack(false, RefreshStatus.idle);
        } else {
          data = dataModel.data['datas'];
          curPageSize = dataModel.data['size'];
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

  _buildBody() {
    print('_buildBody');

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
        ///TODO 这里ListView会在一开始将所有Item都加载出来
        body = new SmartRefresher(
            enablePullUp: true,
            enablePullDown: false,
            controller: _refreshController,
            onRefresh: _onRefresh,
            footerBuilder: _footerCreate,
            child: new ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: curPageSize + 1,
                itemBuilder: (context, index) {
                  print('index $index');

                  if (index == 0) {
                    ///这里没直接使用new Banner()是有原因的，如果使用new Banner()就会在Banner
                    ///消失再出现时返回创建Banner，Banner的流程都会走一遍
//                return new Banner();
                    ///这个高度可以控制Banner的高度
                    return new SizedBox(
                      height: 200.0,
                      child: _buildBannerBody(),
                    );
                  } else {
                    return _feedItemAdapter.getItemView(
                        context, data[index - 1]);
                  }
                }));
      }
    }
    return body;
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
      }else{
        _refreshController.sendBack(false, RefreshStatus.noMore);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Article build');
    return _buildBody();
  }
}

class IndexPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  IndexPage({@required Key key, @required this.scaffoldKey}) : super(key: key);

  @override
  _IndexPageState createState() => new _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        color: Colors.grey[100],
      ),
      child: new ArticleList(
        key: new Key('IndexPage'),
      ),
    );
  }
}
