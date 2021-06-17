import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/RecycleableWidget/Invoice.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Buyers extends StatefulWidget {
  final ticketID;
  final eventName;
  final ticketName;

  const Buyers({Key key, this.ticketID, this.eventName, this.ticketName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuyersState();
  }
}

class BuyersState extends State<Buyers> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List buyerList = new List();
  List buyerListExport = new List();
  bool isEmpty;
  bool isLoading = false;
  bool isExportDataLoading = false;
  int newPage = 0;
  List<int> bytes = [];
  int total = 0;
  int received = 0;
  RefreshController refreshController =
      new RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    print(widget.ticketID);
    // print('counter list' + Counter().counter.length.toString());
    getBuyerList(isPull: false).then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        setState(() {
          if (extractedData['desc'] == 'User not found') {
            isEmpty = true;
          } else {
            isEmpty = false;
            buyerList = extractedData['data'];
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.body);
        print('gagal');
      }
    });
  }

  void buyerExport() {
    getBuyerExport().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        setState(() {
          if (extractedData['desc'] == 'User not found') {
            isEmpty = true;
            isExportDataLoading = false;
          } else {
            isEmpty = false;
            buyerListExport = extractedData['data'];
            exportCSV();
          }
        });
        print('Buyer List Export: ' + buyerListExport.length.toString());
      } else {
        setState(() {
          isLoading = false;
          isExportDataLoading = false;
        });
        print(response.body);
        print('gagal');
      }
    });
  }

  void onLoading() async {
    await Future.delayed(Duration(seconds: 2));
    newPage += 1;

    getBuyerList(page: newPage, isPull: true).then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        buyerList.addAll(extractedData['data']);

        if (mounted) setState(() {});
        refreshController.loadComplete();
      } else {
        print(response.body);
        print('gagal');
        refreshController.loadFailed();
      }
    });
    // refreshController.loadComplete();
  }

  void onRefresh() async {
    newPage = 0;

    getBuyerList(isPull: true).then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        setState(() {
          if (extractedData['desc'] == 'User not found') {
            isEmpty = true;
          } else {
            isEmpty = false;
            buyerList = extractedData['data'];
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.body);
        print('gagal');
      }
    });

    if (mounted) setState(() {});
    refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    // http.Client().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    print("Received: " + ((received / total) * 100).toString() + '/ 100%');

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      key: scaffoldKey,
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1,
        backgroundColor: appBarColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            )),
        centerTitle: true,
        title: Text(
          'BUYERS',
          style: TextStyle(color: eventajaGreenTeal),
        ),
        actions: <Widget>[
          isEmpty == true
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(right: 13),
                  child: GestureDetector(
                    onTap: () {
                      buyerExport();
                    },
                    child: Center(
                      child: Text('Export',
                          style: TextStyle(color: eventajaGreenTeal)),
                    ),
                  ),
                )
        ],
      ),
      body: isLoading == true
          ? Container(
              child: Center(
                child: CupertinoActivityIndicator(radius: 20),
              ),
            )
          : isEmpty == true
              ? EmptyState(
                  imagePath:
                      'assets/icons             /empty_state/my_ticket.png',
                  reasonText: 'There is no buyers :(',
                )
              : Stack(
                  children: <Widget>[
                    SmartRefresher(
                      onLoading: onLoading,
                      onRefresh: onRefresh,
                      enablePullUp: true,
                      controller: refreshController,
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 15),
                        itemCount: buyerList == null ? 0 : buyerList.length,
                        itemBuilder: (BuildContext context, i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) => Invoice(
                                        transactionID: buyerList[i]['id'],
                                      )));
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Center(
                                      child: CircleAvatar(
                                    backgroundImage: NetworkImage(buyerList[i]
                                        ['user']['pictureAvatarURL']),
                                  )),
                                  SizedBox(
                                      width: ScreenUtil.instance.setWidth(50)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(buyerList[i]['user']['fullName']),
                                      Text('@' +
                                          buyerList[i]['user']['username']),
                                      Text('Ticket quantity: ' +
                                          buyerList[i]['quantity']),
                                    ],
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(45),
                                  ),
                                  Center(
                                    child: Text('See Invoice >'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    isExportDataLoading == true
                        ? Container(
                            color: Colors.grey.withOpacity(.8),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CupertinoActivityIndicator(
                                  animating: true,
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text('Please wait, this might take a while...')
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
    );
  }

  exportCSV() async {
    List<List<dynamic>> rows = List<List<dynamic>>();
    // rows.add('Transaction Code');
    //   rows.add('Full Name');
    //   rows.add('username');
    //   rows.add('Ticket Quantity');
    //   rows.add('Note');
    List buyersForm = List();
    Map formLists = Map();

    print('buyerList length' + buyerListExport.length.toString());

    for (Map buyers in buyerListExport) {
      print('buyers: ' + buyers.toString());
      List<dynamic> row = List();

      row.add(buyers['transaction_code']);
      row.add(buyers['user']['fullName']);
      row.add('@' + buyers['user']['username']);
      row.add(buyers['quantity']);
      row.add(buyers['email']);
      row.add(buyers['phone']);
      row.add(buyers['created_at']);
      row.add(buyers['amount'] == '0' ? 'Free' : 'Rp. ${buyers['amount']}');
      row.add(buyers['note'] == '' ? '-' : buyers['note']);
      if (buyers.containsKey('form')) {
        if (buyers['form'] != null || buyers['form'].length != 0) {
          for (var formList in buyers['form']) {
            setState(() {
              formLists = formList;
            });
            row.add(formList['answer']);
          }
        } else {
          row.add('-');
        }
      }

      rows.add(row);

      print('banyak user beli tiket: ' + rows.length.toString());
    }

    print('buyers Form: ' + formLists.toString());
    buyersForm.add(formLists['question']);

    rows.insert(0, [
      'Transaction Code',
      'Full Name',
      'Username',
      'Quantity',
      'Buyer E-mail',
      'Buyer Phone',
      'Date',
      'Total Paid',
      'Note',
      formLists.length != 0 ? formLists['question'] : 'Custom Form'
    ]);

    Map<Permission, PermissionStatus> permissions = await [
      Permission.storage,
    ].request();

    // Map<Permission, PermissionStatus> permissions =
    //     await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus checkPermission = permissions[Permission.storage];

    print(checkPermission.toString());

    if (checkPermission == PermissionStatus.granted) {}

    String dir;

    if (Platform.isAndroid) {
      dir = (await getApplicationDocumentsDirectory()).absolute.path +
          '/report_${widget.ticketName}';
    } else if (Platform.isIOS) {
      dir = (await getLibraryDirectory()).absolute.path +
          '/report_${widget.ticketName}';
    }

    String file = "$dir";
    print(file);
    File f = new File(file + ".csv");

    String csv = const ListToCsvConverter().convert(rows);
    print(csv);
    f.writeAsString(csv);

    print('saved');
    isExportDataLoading = false;
    if (mounted) setState(() {});
    // Share.file(path: f.path, mimeType: ShareType.TYPE_FILE, title: 'text');
    ShareExtend.share(f.path, "file");
  }

  Future<http.Response> getBuyerExport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isExportDataLoading = true;
    });

    String url = BaseApi().apiUrl +
        '/tickets/user?X-API-KEY=$API_KEY&ticketID=${widget.ticketID}&page=all';

    try {
      final response = await http.get(url, headers: {
        'Authorization': AUTH_KEY,
        'cookie': prefs.getString('Session'),
      });

      if (mounted) {
        setState(() {
          total = response.contentLength;
          bytes.addAll(response.bodyBytes);
          received += response.bodyBytes.length;

          print(
              "Received: " + ((received / total) * 100).toString() + '/ 100%');
        });
      }

      return response;
    } catch (e) {
      print('error occured: ' + e);
    }

    return null;
  }

  Future<http.Response> getBuyerList({int page, bool isPull = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentPage = 1;

    setState(() {
      if (page != null) {
        currentPage += page;
      }
      isPull == false ? isLoading = true : isLoading = false;
    });

    String url = BaseApi().apiUrl +
        '/tickets/user?X-API-KEY=$API_KEY&ticketID=${widget.ticketID}&page=$currentPage';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
