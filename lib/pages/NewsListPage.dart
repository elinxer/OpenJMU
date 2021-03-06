import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

class NewsListPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
    final ScrollController _scrollController = ScrollController();
    final TextStyle titleTextStyle = TextStyle(fontSize: 15.0);
    final TextStyle summaryTextStyle = TextStyle(color: Colors.grey, fontSize: 14.0);
    final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: 12.0);

    String sid;
    List listData;
    List slideData;
    int curPage = 1;
    int listTotalSize = 0;
    bool isUserLogin = false;

    @override
    void initState() {
        super.initState();
        _scrollController.addListener(() {
            var maxScroll = _scrollController.position.maxScrollExtent;
            var pixels = _scrollController.position.pixels;
            if (maxScroll == pixels && listData.length < listTotalSize) {
                curPage++;
                getNewsList(true);
            }
        });
        DataUtils.isLogin().then((isLogin) {
            getNewsList(false);
            setState(() {
                this.isUserLogin = isLogin;
            });
        });
        Constants.eventBus.on<LoginEvent>().listen((event) {
            setState(() {
                this.isUserLogin = true;
            });
        });
        Constants.eventBus.on<LogoutEvent>().listen((event) {
            setState(() {
                this.isUserLogin = false;
            });
        });
        Constants.eventBus.on<ScrollToTopEvent>().listen((event) {
            if (this.mounted) {
                _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
            }
        });
    }

    Future<Null> _pullToRefresh() async {
        curPage = 1;
        getNewsList(false);
        return null;
    }

    @override
    Widget build(BuildContext context) {
        if (listData == null) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
                ),
            );
        } else {
            Widget listView = ListView.builder(
                itemCount: listData.length,
                itemBuilder: (context, i) => renderRow(i),
                controller: _scrollController,
            );
            return RefreshIndicator(
                    color: ThemeUtils.currentColorTheme,
                    child: listView,
                    onRefresh: _pullToRefresh
            );
        }
    }

    void getNewsList(bool isLoadMore) async {
        sid = UserUtils.currentUser.sid;
        int uid = UserUtils.currentUser.uid;
        Map<String, dynamic> headers = {
            "APIKEY": Constants.newsApiKey,
            "APPID": "273",
            "CLIENTTYPE": "android",
            "CLOUDID": "jmu",
            "CUID": "$uid",
            "SID": sid,
            "TAGID": "1"
        };
        String url;
        isLoadMore
                ? url = Api.newsList+"/max_ts/"+listData[listData.length-1]['create_time']+"/size/20"
                : url = Api.newsList+"/size/20";
        NetUtils.getWithHeaderSet(url).then((response) {
            if (response != null) {
                Map<String, dynamic> map = jsonDecode(response);
                List _listData = map["data"];
                listTotalSize = map['total'];
//          List _slideData = data['slide'];
                setState(() {
                    if (!isLoadMore) {
                        listData = _listData;
//              slideData = _slideData;
                    } else {
                        List list1 = [];
                        list1..addAll(listData)..addAll(_listData);
                        if (list1.length >= listTotalSize) {
                            list1.add(Constants.endLineTag);
                        }
                        listData = list1;
                        // 轮播图数据
//              slideData = _slideData;
                    }
//            initSlider();
                });
            }
        }).catchError((e) {
            print(e.toString());
            showShortToast(e.toString());
            return e;
        });
//    });
    }

//  void initSlider() {
//    indicator = SlideViewIndicator(slideData.length);
////    slideView = SlideView(slideData, indicator);
//  }

    Widget renderRow(i) {
//    if (i == 0) {
//      return Container(
//        height: 180.0,
//        child: Stack(
//          children: <Widget>[
////            slideView,
//            Container(
//              alignment: Alignment.bottomCenter,
//              child: indicator,
//            )
//          ],
//        ),
//      );
//    }
        var itemData = listData[i];
        var titleRow = Row(
            children: <Widget>[
                Expanded(
                    child: Text(itemData['title'], style: titleTextStyle),
                )
            ],
        );
        var summaryRow = Row(
            children: <Widget>[
                Expanded(
                    child: Text(itemData['summary'], style: summaryTextStyle),
                )
            ],
        );
        var timeRow = Row(
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Text(
                        DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time'])).toString().substring(0,16),
                        style: subtitleStyle,
                    ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                            Text("${itemData['glances']} ", style: subtitleStyle),
                            Icon(Icons.remove_red_eye, color: Colors.grey, size: 12.0)
                        ],
                    ),
                )
            ],
        );
        Widget thumbImg;
        if (itemData['cover_img'] != null) {
            String thumbImgUrl = Api.newsImageList + itemData['cover_img']['fid'] + "/sid/$sid";
            thumbImg = Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
//          shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                            image: CachedNetworkImageProvider(thumbImgUrl, cacheManager: DefaultCacheManager()),
                            fit: BoxFit.cover
                    ),
                    border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                    ),
                ),
            );
        }
        var row = Row(
            children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            children: <Widget>[
                                titleRow,
                                summaryRow,
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                                    child: timeRow,
                                )
                            ],
                        ),
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                        width: 80.0,
                        height: 80.0,
                        color: const Color(0xFFECECEC),
                        child: Center(
                            child: thumbImg,
                        ),
                    ),
                )
            ],
        );
        return InkWell(
            child: row,
            onTap: () {
                return CommonWebPage.jump(context, Api.newsDetail + itemData['post_id'], itemData['title']);
            },
        );
    }
}
