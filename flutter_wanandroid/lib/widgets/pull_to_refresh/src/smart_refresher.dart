/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'internals/default_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../src/internals/indicator_config.dart';
import '../src/internals/indicator_wrap.dart';
import '../src/internals/refresh_physics.dart';



enum WrapperType { Refresh, Loading }

class RefreshStatus {
  static const int idle = 0;
  static const int canRefresh = 1;
  static const int refreshing = 2;
  static const int completed = 3;
  static const int failed = 4;
  static const int noMore = 5;
}


/*
    This is the most important component that provides drop-down refresh and up loading.
 */
class SmartRefresher extends StatefulWidget {
  //indicate your listView
  final Widget child;
  
  final IndicatorBuilder headerBuilder;
  final IndicatorBuilder footerBuilder;
  // configure your header and footer
  final Config headerConfig, footerConfig;
  // This bool will affect whether or not to have the function of drop-up load.
  final bool enablePullUp;
  //This bool will affect whether or not to have the function of drop-down refresh.
  final bool enablePullDown;
  // if open OverScroll if you use RefreshIndicator and LoadFooter
  final bool enableOverScroll;
  // upper and downer callback when you drag out of the distance
  final OnRefresh onRefresh;
  // This method will callback when the indicator changes from edge to edge.
  final OnOffsetChange onOffsetChange;
  //controll inner state
  final RefreshController controller;

  SmartRefresher({
    Key key,
    @required this.child,
    this.headerBuilder,
    this.footerBuilder,
    RefreshController controller,
    this.headerConfig: const RefreshConfig(),
    this.footerConfig: const LoadConfig(),
    this.enableOverScroll:default_enableOverScroll,
    this.enablePullDown: default_enablePullDown,
    this.enablePullUp: default_enablePullUp,
    this.onRefresh,
    this.onOffsetChange,
  })  : assert(child != null),
        controller = controller ?? new RefreshController(),super(key: key);


  @override
  _SmartRefresherState createState() => new _SmartRefresherState();
}

class _SmartRefresherState extends State<SmartRefresher> {
  // listen the listen offset or on...
  ScrollController _scrollController;
  // the bool will check the user if dragging on the screen.
  bool _isDragging = false;
  // key to get height header of footer
  final GlobalKey _headerKey = new GlobalKey(), _footerKey = new GlobalKey();
  // the height must be  equals your headerBuilder
  double _headerHeight = 0.0, _footerHeight = 0.0;

  ValueNotifier<double> offsetLis = new ValueNotifier(0.0);

  ValueNotifier<int> topModeLis = new ValueNotifier(0);

  ValueNotifier<int> bottomModeLis =new ValueNotifier(0);

  //handle the scrollStartEvent
  bool _handleScrollStart(ScrollStartNotification notification) {
    // This is used to interupt useless callback when the pull up load rolls back.
    if ((notification.metrics.outOfRange)) {
      return false;
    }
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUp) bottomWrap.onDragStart(notification);
    if (widget.enablePullDown) topWrap.onDragStart(notification);
    return false;
  }

  //handle the scrollMoveEvent
  bool _handleScrollMoving(ScrollUpdateNotification notification) {
    bool down = _isPullDown(notification);
    if (down) {
      if (widget.onOffsetChange != null)
        widget.onOffsetChange(notification.metrics.extentBefore == 0,
            notification.metrics.minScrollExtent - notification.metrics.pixels);
    } else {
      if (widget.onOffsetChange != null)
        widget.onOffsetChange(notification.metrics.extentAfter == 0,
            notification.metrics.pixels - notification.metrics.maxScrollExtent);
    }
    if (_measure(notification) != -1.0) offsetLis.value = _measure(notification);
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUp) bottomWrap.onDragMove(notification);
    if (widget.enablePullDown) topWrap.onDragMove(notification);
    return false;
  }

  //handle the scrollEndEvent
  bool _handleScrollEnd(ScrollNotification notification) {
    GestureProcessor topWrap = _headerKey.currentState as GestureProcessor;
    GestureProcessor bottomWrap = _footerKey.currentState as GestureProcessor;
    if (widget.enablePullUp) bottomWrap.onDragEnd(notification);
    if (widget.enablePullDown) topWrap.onDragEnd(notification);
    return false;
  }

  bool _dispatchScrollEvent(ScrollNotification notification) {
    // when is scroll in the ScrollInside,nothing to do
    if ((!_isPullUp(notification) && !_isPullDown(notification))) return false;
    if (notification is ScrollStartNotification) {
      return _handleScrollStart(notification);
    }
    if (notification is ScrollUpdateNotification) {
      //if dragDetails is null,This represents the user's finger out of the screen
      if (notification.dragDetails == null) {
        return _handleScrollEnd(notification);
      } else if (notification.dragDetails != null) {
        return _handleScrollMoving(notification);
      }
    }
    if (notification is ScrollEndNotification) {
      print("end");
      _handleScrollEnd(notification);
    }

    return false;
  }


  //check user is pulling up
  bool _isPullUp(ScrollNotification noti) {
    return noti.metrics.pixels < 0;
  }

  //check user is pulling down
  bool _isPullDown(ScrollNotification noti) {
    return noti.metrics.pixels > 0;
  }

  double _measure(ScrollNotification notification) {
    if (notification.metrics.minScrollExtent - notification.metrics.pixels >
        0) {
      return (notification.metrics.minScrollExtent -
              notification.metrics.pixels) /
          widget.headerConfig.triggerDistance;
    } else if (notification.metrics.pixels -
            notification.metrics.maxScrollExtent >
        0) {
      return (notification.metrics.pixels -
              notification.metrics.maxScrollExtent) /
          widget.footerConfig.triggerDistance;
    }
    return -1.0;
  }

  void _init() {
    _scrollController = new ScrollController();
    widget.controller.scrollController =_scrollController;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _onAfterBuild();
    });
    widget.controller._headerMode = topModeLis;
    widget.controller._footerMode = bottomModeLis;
  }

  _didChangeMode(bool up, ValueNotifier<int> mode) {
    switch (mode.value) {
      case RefreshStatus.refreshing:
        if (widget.onRefresh != null) {
          widget.onRefresh(up);
        }
        if(up&&widget.headerConfig is RefreshConfig){
          RefreshConfig config = widget.headerConfig as RefreshConfig;
          _scrollController.jumpTo(_scrollController.offset+config.visibleRange);
        }
        break;
    }
  }

  void _onAfterBuild() {
    if(widget.headerConfig is LoadConfig){
      if((widget.headerConfig as LoadConfig).bottomWhenBuild){
        _scrollController.jumpTo(-(_scrollController.position.pixels-_scrollController.position.maxScrollExtent));
      }
    }

    topModeLis.addListener(() {
      _didChangeMode(true, topModeLis);
    });
    bottomModeLis.addListener(() {
      _didChangeMode(false, bottomModeLis);
    });
    setState(() {
      if (widget.enablePullDown)
        _headerHeight = _headerKey.currentContext.size.height;
      if (widget.enablePullUp) {
        _footerHeight = _footerKey.currentContext.size.height;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }

  Widget _buildWrapperByConfig(Config config, bool up) {
    if (config is LoadConfig) {
      return new LoadWrapper(
        key: up ? _headerKey : _footerKey,
        modeListener: up ? topModeLis : bottomModeLis,
        up: up,
        autoLoad: config.autoLoad,
        triggerDistance: config.triggerDistance,
        builder: up
            ? widget.headerBuilder
            : widget.footerBuilder,
      );
    } else if (config is RefreshConfig) {
      return new RefreshWrapper(
        key: up ? _headerKey : _footerKey,
        modeLis: up ? topModeLis : bottomModeLis,
        up: up,
        completeDuration: config.completeDuration,
        triggerDistance: config.triggerDistance,
        visibleRange: config.visibleRange,
        builder: up
            ? widget.headerBuilder
            : widget.footerBuilder,
      );
    }
    return new Container();
  }
  
  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    // TODO: implement didUpdateWidget
    widget.controller._headerMode = topModeLis;
    widget.controller._footerMode = bottomModeLis;
    widget.controller.scrollController =_scrollController;
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, cons) {
      return new Stack(
        children: <Widget>[
          new Positioned(
              top: !widget.enablePullDown||widget.headerConfig is LoadConfig ? 0.0 : -_headerHeight,
              bottom: !widget.enablePullUp||widget.footerConfig is LoadConfig ? 0.0 : -_footerHeight,
              left: 0.0,
              right: 0.0,
              child: new NotificationListener(
                child: new SingleChildScrollView(
                    controller: _scrollController,
                    physics: new RefreshScrollPhysics(enableOverScroll:widget.enableOverScroll ),
                    child: new Column(
                      children: <Widget>[
                        widget.headerBuilder != null && widget.enablePullDown
                            ? _buildWrapperByConfig(widget.headerConfig, true)
                            : new Container(),
                        new ConstrainedBox(
                          constraints: new BoxConstraints(
                            maxHeight: double.MAX_FINITE-1.0,
                              minHeight: cons.biggest.height),
                          child: widget.child,
                        ),
                        widget.footerBuilder != null && widget.enablePullUp
                            ? _buildWrapperByConfig(widget.footerConfig, false)
                            : new Container()
                      ],
                    )),
                onNotification: _dispatchScrollEvent,
              )),
        ],
      );
    });
  }
}


abstract class Indicator extends StatefulWidget {

  final int mode;
  
  const Indicator({Key key,this.mode}):super(key:key);
}

class RefreshController{
  
  ValueNotifier<int> _headerMode ;
  ValueNotifier<int> _footerMode;
  ScrollController scrollController;

  void requestRefresh(bool up){
    if(up) {
      if (_headerMode.value == RefreshStatus.idle)
        _headerMode.value = RefreshStatus.refreshing;
    }
    else {
        if (_footerMode.value == RefreshStatus.idle) {
          _footerMode.value = RefreshStatus.refreshing;
        }
      }
  }

  void scrollTo(double offset){
    scrollController.jumpTo(offset);
  }
  
  void sendBack(bool up,int mode){
    if(up){
      _headerMode.value = mode;
    }
    else{
      _footerMode.value = mode;
    }
  }

  int get headerMode => _headerMode.value;

  int get footerMode => _footerMode.value;
  
  isRefresh(bool up){
    if(up){
      return _headerMode.value==RefreshStatus
          .refreshing;
    }
    else{
      return _footerMode.value==RefreshStatus
          .refreshing;
    }
  }
  
  
}