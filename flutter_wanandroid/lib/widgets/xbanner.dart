import 'package:flutter/material.dart';
import 'dart:async';

///
///XBanner 中的点击事件
typedef void PageClick(int i);

/// Banner widget
class XBanner extends StatefulWidget {
  final List<Widget> _pages;
  final PageClick pageClick;
  final Duration bannerDuration;
  final Duration bannerAnimationDuration;

  /// [_pages] 为 Banner 中需要展示的页面集合。
  /// [pageClick] 为 Banner 中页面的点击事件回调。
  /// [bannerDuration] Banner 中页面切换的时间间隔，默认为 2 秒。
  /// [bannerAnimationDuration] Banner 中每次页面切换的动画时间，默认为 1 秒。
  XBanner(this._pages,
      {this.pageClick,
      this.bannerDuration = const Duration(seconds: 2),
      this.bannerAnimationDuration = const Duration(milliseconds: 1000)});

  @override
  State<StatefulWidget> createState() {
    return new XBannerState();
  }
}

class XBannerState extends State<XBanner> with SingleTickerProviderStateMixin {
  PageController _pageController = new PageController();
  Timer _timer;
  int _currentPage = 0;
  bool reverse = false;
  GlobalKey<_XBannerTipState> _xBannerTipStateKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _timer = new Timer.periodic(widget.bannerDuration, (timmer) {
      _pageController.animateToPage(_currentPage,
          duration: widget.bannerAnimationDuration, curve: Curves.linear);
      if (!reverse) {
        _currentPage += 1;
        if (_currentPage == widget._pages.length) {
          _currentPage -= 1;
          reverse = true;
        }
      } else {
        _currentPage -= 1;
        if (_currentPage < 0) {
          _currentPage += 1;
          reverse = false;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageWithClick = [];
    for (var i = 0; i < widget._pages.length; i++) {
      pageWithClick.add(new InkWell(
        child: widget._pages[i],
        onTap: () {
          if (widget.pageClick != null) {
            widget.pageClick(i);
          }
        },
      ));
    }

    ///两层，PageView+XBannerTip
    return new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        new NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotification) {
              // if (scrollNotification is ScrollUpdateNotification) {
              //   print("offset : ${_pageController.offset}");
              //   print("position : ${_pageController.position.pixels}");
              //   print("page : ${_pageController.page}");
              // }
              return false;
            },
            child: new PageView(
              controller: _pageController,
              children: pageWithClick,
              onPageChanged: (index) {
                _currentPage = index;

                ///回调方法
                _xBannerTipStateKey.currentState.changeTipIndex(index);
              },
            )),
        new Align(
          child: new _XBannerTip(
            widget._pages.length,
            key: _xBannerTipStateKey,
          ),
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }
}

///banner提示控件
class _XBannerTip extends StatefulWidget {
  final int _count;

  _XBannerTip(this._count, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _XBannerTipState();
  }
}

class _XBannerTipState extends State<_XBannerTip> {
  int _index = 0;

  changeTipIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [];
    for (int i = 0; i < widget._count; i++) {
      childs.add(new SizedBox(
        width: 7.0,
        height: 7.0,
        child: new DecoratedBox(
            decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: i == _index ? Colors.black : Colors.grey,
        )),
//        child: new Container(
//          color: i == _index ? Colors.black : Colors.grey,
//        ),
      ));
    }

    return new SizedBox(
      width: widget._count * 15.0,
      height: 15.0,
      child: new Row(
        children: childs,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }
}
