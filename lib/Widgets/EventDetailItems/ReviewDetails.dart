import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class ReviewDetails extends StatefulWidget {
  final eventName;
  final goodReview;
  final badReview;
  final eventId;

  const ReviewDetails({Key key, this.eventName, this.goodReview, this.badReview, this.eventId}) : super(key: key);

  @override
  _ReviewDetailsState createState() => _ReviewDetailsState();
}

class _ReviewDetailsState extends State<ReviewDetails> {

  @override
  void initState() {
    getReviewData();
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(80),
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset(
                'assets/icons/icon_apps/arrow.png',
                scale: 5.5,
                alignment: Alignment.centerLeft,
              ),
            ),
            title: Text('REVIEW EVENT'),
            centerTitle: true,
            textTheme: TextTheme(
                title: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.instance.setSp(14),
                  color: Colors.black,
                )),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: ScreenUtil.instance.setWidth(13), vertical: ScreenUtil.instance.setWidth(13)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.eventName.toString().toUpperCase()),
                  SizedBox(height: ScreenUtil.instance.setWidth(15),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.thumb_up,
                          size: 30,
                          color: eventajaGreenTeal),
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: ScreenUtil
                              .instance
                              .setWidth(10),
                          progressColor:
                          eventajaGreenTeal,
                          percent: int.parse(widget.goodReview) /
                              100,
                        ),
                      ),
                      Container(
                        width: ScreenUtil.instance
                            .setWidth(40),
                        child: Text(
                          (widget.goodReview +
                              '%'),
                          style: TextStyle(
                              color: eventajaGreenTeal,
                              fontWeight:
                              FontWeight.bold),
                          textAlign:
                          TextAlign.end,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.instance
                        .setWidth(15),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.thumb_down,
                          size: 30, color: Colors.red),
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: ScreenUtil
                              .instance
                              .setWidth(10),
                          progressColor: Colors.red,
                          percent: int.parse(widget.badReview) /
                              100,
                        ),
                      ),
                      Container(
                        width: ScreenUtil.instance
                            .setWidth(40),
                        child: Text(
                          widget.badReview +
                              '%',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1.5,
              color: Color(0xff8a8a8b),
            ),
            SizedBox(height: ScreenUtil.instance.setWidth(13),),
            Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil.instance.setWidth(13)),
                child: Text('0 Review', style: TextStyle(color: Color(0xff8a8a8b), fontSize: ScreenUtil.instance.setSp(13)),)),
            Container(
              margin: EdgeInsets.symmetric(horizontal: ScreenUtil.instance.setWidth(13)),
              child: FutureBuilder(
                future: getReviewData(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                      Container(child: Center(child: Text('Please Enable Your Intenet Connection', style: TextStyle(fontWeight: FontWeight.bold),),),);
                      break;
                    case ConnectionState.waiting:
                      Container(
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 20),
                        ),
                      );
                      break;
                    case ConnectionState.active:
                      // TODO: Handle this case.
                      break;
                    case ConnectionState.done:
                      print(snapshot.data['data']['data_review']);
                      if(snapshot.data['data']['data_review'] != false){
                        List reviewData = snapshot.data['data']['data_review'];
                        print(reviewData);

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reviewData == null ? 0 : reviewData.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(reviewData[i]['user']['pictureCommentURL']),
                              ),
                              title: Text(
                                reviewData[i]['user']['fullName'] + ' ${reviewData[i]['user']['lastName']}' +
                                    ': ',
                                style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(12),
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('\"${reviewData[i]['description'] == null ? reviewData[i]['review_type']['type_name'] : reviewData[i]['description']}\"'),
                              trailing: reviewData[i]['review_type']['type'] == 'good' ? Icon(Icons.thumb_up,
                                  size: 30, color: eventajaGreenTeal) : Icon(Icons.thumb_down,
                                  size: 30, color: Colors.red),
                            );
                          },
                        );

                      }
                      else{
                        return Container(
                          child: Center(child: Text('No review found'),),
                        );
                      }
                      break;
                  }
                  return Container();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future getReviewData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/event_review/list?X-API-KEY=$API_KEY&eventID=${widget.eventId}&page=1';

    final response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': sharedPreferences.getString('Session')
      }
    );

    var extractedData = json.decode(response.body);

    return extractedData;
  }
}
