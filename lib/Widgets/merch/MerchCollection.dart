import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/SpecificCollectionListModel.dart';
import 'package:eventevent/Redux/Actions/SpecificCollectoinActions.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:googleapis/appengine/v1.dart';
import 'package:redux/redux.dart';
import 'CollectionItem.dart';

class MerchCollection extends StatefulWidget {
  final merchId;
  final merchBannerImage;

  const MerchCollection({Key key, this.merchId, this.merchBannerImage}) : super(key: key);
  @override
  _MerchCollectionState createState() => _MerchCollectionState();
}

class _MerchCollectionState extends State<MerchCollection> {
  void handleInitialBuild(CollectionListScreenProps props, String id) {
    props.getSpecificCollection(id);
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CollectionListScreenProps>(
      converter: (store) => mapStateToProps(store),
      onInitialBuild: (props) => handleInitialBuild(props, widget.merchId),
      builder: (context, props) {
        List<SpecificCollectionListModel> data = props.specificCollectionResponse.data;
        bool isLoading = props.specificCollectionResponse.loading;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(null, 100),
            child: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
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
                  title: Text('Collections'),
                  centerTitle: true,
                  textTheme: TextTheme(
                      title: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  )),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: isLoading == true ? HomeLoadingScreen().myTicketLoading() : Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                children: <Widget>[
                  Container(
                    height: ScreenUtil.instance.setWidth(200),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      // color: Color(0xfffec97c),
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(image: NetworkImage(widget.merchBannerImage), fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.2),
                          blurRadius: 2.5,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    'From This Collection',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: eventajaBlack),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ColumnBuilder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      return CollectionItem(
                        image: data[i].imageUrl,
                        profileImage: data[i].profileImageUrl,
                        // isAvailable: true,
                        itemColor: eventajaGreenTeal,
                        itemPrice: 'Rp. ' + data[i].details[0]['final_price'],
                        title: data[i].productName,
                        username: '@' + data[i].merchantName,
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CollectionListScreenProps {
  final Function getSpecificCollection;
  final ListSpecificCollection specificCollectionResponse;

  CollectionListScreenProps({
    this.getSpecificCollection,
    this.specificCollectionResponse,
  });
}

CollectionListScreenProps mapStateToProps(Store<AppState> store) {
  return CollectionListScreenProps(
    specificCollectionResponse: store.state.specificCollections.list,
    getSpecificCollection: (id) => store.dispatch(getSpecificCollection(id)),
  );
}
