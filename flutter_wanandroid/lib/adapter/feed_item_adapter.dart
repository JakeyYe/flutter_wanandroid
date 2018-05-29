import 'package:flutter/material.dart';
import '../adapter/base_adapter.dart';
import '../home/web_view_page.dart';

class FeedItemAdapter extends BaseAdapter{

  @override
  Widget getItemView(BuildContext context, item) {

    Color primaryColor = Theme.of(context).primaryColor;

    List<TextSpan> spanList = <TextSpan>[];

    ///Article Item 中的'项目'标志
    if (item['tags'].length > 0) {
      String name = item['tags'][0]['name'];
      spanList.add(
          new TextSpan(text: name, style: new TextStyle(color: primaryColor)));
    }

    spanList.addAll([
      new TextSpan(text: ' 作者：${item['author']} '),
      new TextSpan(
          text: '分类：${item['superChapterName']}/${item['chapterName']} ',
          style: new TextStyle(color: primaryColor)),
      new TextSpan(
          text: '时间：${item['niceDate']}',
          style: new TextStyle(color: Colors.grey)),
    ]);

    Widget itemAuthors = new Text.rich(new TextSpan(children: spanList));

    ///TODO 这里请求时若添加cookie，返回值这个'collect'应该就不一样
    Widget itemCollect = new IconButton(
        icon: item['collect']
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
        onPressed: () {
          print('这里这里 ${item['title']}');
        });

    Widget itemTitle =
    new Text(item['title'], style: new TextStyle(fontSize: 18.0));

    return new Material(
      child: new Column(
        children: <Widget>[
          new InkWell(
              onTap: () {
                Navigator
                    .of(context)
                    .push(new MaterialPageRoute(builder: (context) {
                  return new WebViewPage(
                      key: new Key(item['title']),
                      title: item['title'],
                      url: item['link']);
                }));
              },
              child: new Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Expanded(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new SizedBox(
                                width: 8.0,
                              ),
                              new Expanded(child: itemTitle),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new SizedBox(
                                width: 8.0,
                              ),
                              new Expanded(child: itemAuthors),
                            ],
                          ),
                        ],
                      ),
                    ),
                    new SizedBox(
                      width: 4.0,
                    ),
                    itemCollect,
                    new SizedBox(
                      width: 8.0,
                    ),
                  ],
                ),
              )),
          new Divider(
            height: 1.0,
          ),
        ],
      ),
    );
  }


}