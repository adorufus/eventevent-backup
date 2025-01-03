import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/EventDetailComment.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoveItem extends StatefulWidget {
  final isComment;
  final int loveCount;
  final commentCount;
  final isAlreadyCommented;
  final isAlreadyLoved;
  final eventId;

  const LoveItem({
    Key key,
    this.isComment,
    this.loveCount,
    this.commentCount,
    this.isAlreadyCommented,
    this.isAlreadyLoved,
    @required this.eventId,
  }) : super(key: key);

  @override
  _LoveItemState createState() => _LoveItemState();
}

class _LoveItemState extends State<LoveItem> {
  Map commentData;
  int _loveCount = 0;
  bool _isLoved;
  Dio dio = Dio(BaseOptions(
    baseUrl: BaseApi().apiUrl,
    receiveTimeout: 10000,
    connectTimeout: 10000,
  ));

  @override
  void initState() {
    setState(() {
      _isLoved = widget.isAlreadyLoved;
      _loveCount = widget.loveCount;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    return GestureDetector(
      onTap: () {
        if (widget.isComment == false) {
          if (_isLoved == false) {
            setState(() {
              _loveCount += 1;
              _isLoved = true;
              doLove();
            });
          } else {
            _loveCount -= 1;
            _isLoved = false;
            doUnlove();
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailComment(
                eventID: widget.eventId,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.isComment == false
                ? _loveCount < 1 ? 7.5 : 13
                : widget.commentCount == "0" ? 7.5 : 13),
        height: ScreenUtil.instance.setWidth(30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 1.5)
            ]),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Image.asset(
            widget.isComment == false
                ? 'assets/icons/icon_apps/love.png'
                : 'assets/icons/icon_apps/comment.png',
            color: widget.isComment == false
                ? _isLoved == false ? Color(0xff8a8a8b) : Colors.red
                : widget.isAlreadyCommented == false
                    ? Color(0xff8a8a8b)
                    : eventajaGreenTeal,
            scale: 3.5,
          ),
          widget.isComment == false
              ? _loveCount < 1
                  ? Container()
                  : SizedBox(width: ScreenUtil.instance.setWidth(5))
              : widget.commentCount == "0"
                  ? Container()
                  : SizedBox(width: ScreenUtil.instance.setWidth(5)),
          widget.isComment == false
              ? _loveCount < 1
                  ? Container()
                  : Text(_loveCount.toString(),
                      style: TextStyle(
                          color: eventajaBlack, fontWeight: FontWeight.bold))
              : widget.commentCount == "0"
                  ? Container()
                  : Text(widget.commentCount,
                      style: TextStyle(
                          color: eventajaBlack, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  Future doLove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      Map<String, dynamic> data = {'X-API-KEY': API_KEY, 'id': widget.eventId};

      Response response = await dio.post('/event_love/post',
          options: Options(
            headers: {
              'Authorization': AUTH_KEY,
              'cookie': prefs.getString('Session')
            },
            contentType: 'text',
          ),
          data: FormData.fromMap(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('BERHASIL LIKE EVENT!');
      } else {
        print('GAGAL LIKE EVENT, KENAPA? ');
        print(response.statusMessage);
        setState(() {
          _isLoved = false;
          _loveCount -= 1;
        });
      }
    } catch (e) {
      if (e is DioError) {
        print(e.response);
        print(e.message);
        print(e.error);
        setState(() {
          _isLoved = false;
          _loveCount -= 1;
        });
      } else if (e is NoSuchMethodError) {
        print(e.stackTrace);
      }
    }
  }

  Future doUnlove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      Response response = await dio.delete(
        '/event_love/delete',
        options: Options(
          headers: {
            'Authorization': AUTH_KEY,
            'cookie': prefs.getString('Session'),
            'X-API-KEY': API_KEY,
            'id': widget.eventId
          },
          contentType: 'text',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('BERHASIL DISLIKE EVENT!');
      } else {
        print('GAGAL LIKE EVENT, KENAPA? ');
        print(response.statusMessage);
        setState(() {
          _isLoved = true;
          _loveCount += 1;
        });
      }
    } catch (e) {
      if (e is DioError) {
        print(e.response);
        print(e.message);
        print(e.error);
        setState(() {
          _isLoved = true;
          _loveCount += 1;
        });
      } else if (e is NoSuchMethodError) {
        print(e.stackTrace);
      }
    }
  }
}
