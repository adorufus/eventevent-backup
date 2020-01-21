import 'dart:convert';
import 'dart:io';
import 'package:eventevent/Widgets/ManageEvent/exportCounter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:eventevent/Widgets/RecycleableWidget/Invoice.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

class Buyers extends StatefulWidget {
  final ticketID;
  final eventName;

  const Buyers({Key key, this.ticketID, this.eventName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuyersState();
  }
}

class BuyersState extends State<Buyers> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List buyerList = new List();
  List buyerListExport = new List();

  @override
  void initState() {
    super.initState();
    // print('counter list' + Counter().counter.length.toString());
    getBuyerList().then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          buyerList = extractedData['data'];
        });
      } else {
        print(response.body);
        print('gagal');
      }
    });

    getBuyerExport().then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          buyerListExport = extractedData['data'];
        });
        print('Buyer List Export: ' + buyerListExport.length.toString());
      } else {
        print(response.body);
        print('gagal');
      }
    });
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
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
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
          Padding(
            padding: EdgeInsets.only(right: 13),
                      child: GestureDetector(
              onTap: () {
                exportCSV();
              },
              child: Center(
                child: Text('Export', style: TextStyle(color: eventajaGreenTeal)),
              ),
            ),
          )
        ],
      ),
      body: buyerList.length == 0 || buyerListExport.length == 0 ? Container(child: Center(child: CupertinoActivityIndicator(radius: 20),),) : ListView.builder(
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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  Center(
                      child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(buyerList[i]['user']['pictureAvatarURL']),
                  )),
                  SizedBox(width: ScreenUtil.instance.setWidth(50)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(buyerList[i]['user']['fullName']),
                      Text('@' + buyerList[i]['user']['username']),
                      Text('Ticket quantity: ' + buyerList[i]['quantity']),
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
      row.add(buyers['note']);
      if(buyers.containsKey('form')){
        if (buyers['form'] != null || buyers['form'].length != 0) {
        for (var formList in buyers['form']) {
          setState(() {
            formLists = formList;
          });
          row.add(formList['answer']);
        }
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
      'Note',
      formLists.length != 0 ? formLists['question'] : ''
    ]);

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus checkPermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    print(checkPermission.toString());

    if (checkPermission == PermissionStatus.granted) {
      
    }

    String dir;

    if(Platform.isAndroid){
      dir = (await getExternalStorageDirectory()).absolute.path +
          '/report_${widget.eventName}';
    }
    else if(Platform.isIOS){
      dir = (await getLibraryDirectory()).absolute.path + '/report_${widget.eventName}';
    }

      String file = "$dir";
      print(file);
      File f = new File(file + ".csv");

      String csv = const ListToCsvConverter().convert(rows);
      print(csv);
      f.writeAsString(csv);

      print('saved');
      // Share.file(path: f.path, mimeType: ShareType.TYPE_FILE, title: 'text');
      ShareExtend.share(f.path, "file");
  }

  Future<http.Response> getBuyerExport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/tickets/user?X-API-KEY=$API_KEY&ticketID=${widget.ticketID}&page=all';

    try{
      final response = await http.get(url, headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      });

      return response;
    }
    catch (e){
      print('error occured: ' + e);
    }

    return null;
  }

  Future<http.Response> getBuyerList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/tickets/user?X-API-KEY=$API_KEY&ticketID=${widget.ticketID}&page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
