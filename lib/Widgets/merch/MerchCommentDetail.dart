import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/MerchCommentModel.dart';
import 'package:eventevent/Redux/Actions/MerchCommentActions.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MerchCommentDetail extends StatefulWidget {
  final merchId;

  const MerchCommentDetail({Key key, this.merchId}) : super(key: key);
  @override
  _MerchCommentDetailState createState() => _MerchCommentDetailState();
}

class _MerchCommentDetailState extends State<MerchCommentDetail> {
  TextEditingController commentController = TextEditingController();

  void initialization(MerchCommentProps props) {
    props.getCommentList(widget.merchId);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, MerchCommentProps>(
      converter: (store) => mapCommentStateToProps(store),
      onInitialBuild: (props) => initialization(props),
      builder: (context, props) {
        List<MerchCommentModel> data = props.merchCommentResponse.data;
        bool isLoading = props.merchCommentResponse.loading;

        // print(props.merchCommentResponse.error.message);

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(null, 100),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: ScreenUtil.instance.setWidth(80),
              padding: EdgeInsets.symmetric(horizontal: 13),
              color: Colors.white,
              child: AppBar(
                brightness: Brightness.light,
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
                title: Text('Comments'),
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
          bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: ScreenUtil.instance.setWidth(70),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      autofocus: true,
                      controller: commentController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                            borderSide: BorderSide(color: Colors.black)),
                        hintText: 'Add a comment..',
                        suffix: GestureDetector(
                          onTap: () async {
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            data.add(
                              MerchCommentModel(
                                  comment: commentController.text,
                                  commentId: '',
                                  userId: '',
                                  user: User(
                                    photo: preferences.getString('UserPicture'),
                                    fullName:
                                        preferences.getString('UserFirstname'),
                                    email: '',
                                    isVerified: '',
                                    lastName: '',
                                    username: '',
                                  )),
                            );
                            if(mounted) setState((){});
                            FocusScope.of(context).requestFocus(FocusNode());
                            postComment(commentController.text).then(
                              (response) {
                                var extractedData = json.decode(response.body);

                                if (response.statusCode == 200 ||
                                    response.statusCode == 201) {
                                  print(response.body);

                                  print('****Comment Posted!*****');
                                  commentController.text = '';
                                  setState(() {});
                                } else {
                                  print(response.body);
                                  print('****Comment Failed****');
                                  print('reason: ${extractedData['desc']}');
                                }
                              },
                            ).catchError(
                              (e, s) {
                                print(s.toString());
                                print('****Comment Failed****');
                                print('reason: ' + e.toString());
                              },
                            );
                          },
                          child: Container(
                            child: Text(
                              'Send',
                              style: TextStyle(
                                  color: eventajaGreenTeal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: isLoading == true
              ? HomeLoadingScreen().followListLoading()
              : ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data[i].user.photo),
                      ),
                      title: Text(
                        data[i].user.fullName + ': ',
                        style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        data[i].comment,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Future<http.Response> postComment(String commentText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/product/comment';

    final response = await http.post(url, body: {
      'X-API-KEY': API_KEY,
      'productId': widget.merchId,
      'comment': commentText,
    }, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session'),
    });

    return response;
  }
}

class MerchCommentProps {
  final Function getCommentList;
  final ListMerchComment merchCommentResponse;

  MerchCommentProps({this.getCommentList, this.merchCommentResponse});
}

MerchCommentProps mapCommentStateToProps(Store<AppState> store) {
  return MerchCommentProps(
    merchCommentResponse: store.state.merchComments.list,
    getCommentList: (merchId) => store.dispatch(getCommentList(merchId)),
  );
}
