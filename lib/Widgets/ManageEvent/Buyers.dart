import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/RecycleableWidget/Invoice.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';

class Buyers extends StatefulWidget {
  final ticketID;

  const Buyers({Key key, this.ticketID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuyersState();
  }
}

class BuyersState extends State<Buyers> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List buyerList = new List();

  @override
  void initState() {
    
    super.initState();
    getBuyerList().then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          buyerList = extractedData['data'];
        });
      } else {
        print('gagal');
      }
    }).timeout(Duration(seconds: 8), onTimeout: () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text('Request Time Out!', style: TextStyle(color: Colors.white)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    
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
          GestureDetector(
            onTap: () {
              exportCSV();
            },
            child: Center(
              child: Text('Export', style: TextStyle(color: eventajaGreenTeal)),
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: 15),
        itemCount: buyerList == null ? 0 : buyerList.length,
        itemBuilder: (BuildContext context, i) {
          return GestureDetector(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => Invoice(
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
                  SizedBox(width: 50),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(buyerList[i]['user']['fullName']),
                      Text('@' + buyerList[i]['user']['username']),
                      Text('Ticket quantity: ' + buyerList[i]['quantity']),
                    ],
                  ),
                  SizedBox(
                    width: 45,
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
    for (int i = 0; i < buyerList.length; i++) {
      List<dynamic> row = List();
      row.add(buyerList[i]['transaction_code']);
      row.add(buyerList[i]['user']['fullName']);
      row.add('@' + buyerList[i]['user']['username']);
      row.add(buyerList[i]['quantity']);
      rows.add(row);
    }

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus checkPermission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    print(checkPermission.toString());

    if (checkPermission == PermissionStatus.granted) {
      String dir =
          (await getExternalStorageDirectory()).absolute.path + '/report';
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
  }

  Future<http.Response> getBuyerList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/tickets/user?X-API-KEY=$API_KEY&ticketID=${widget.ticketID}=&?page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
