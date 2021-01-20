import 'dart:convert';

import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/DiscoverMerchModel.dart';
import 'package:eventevent/Models/MerchCategoryModel.dart';
import 'package:eventevent/Models/MerchCollectionModel.dart';
import 'package:eventevent/Models/PopularMerchModel.dart';
import 'package:eventevent/Redux/Actions/BannerActions.dart';
import 'package:eventevent/Redux/Actions/CategoryActions.dart';
import 'package:eventevent/Redux/Actions/CollectionActions.dart';
import 'package:eventevent/Redux/Actions/DiscoverMerchActions.dart';
import 'package:eventevent/Redux/Actions/MerchDetailsActions.dart';
import 'package:eventevent/Redux/Actions/PopularMerchActions.dart';
import 'package:eventevent/Redux/Actions/SpecificCategoryActions.dart';
import 'package:eventevent/Redux/Reducers/logger.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/PopularEventWidget.dart';
import 'package:eventevent/Widgets/loginRegisterWidget.dart';
import 'package:eventevent/Widgets/merch/CategoryItem.dart';
import 'package:eventevent/Widgets/merch/MerchDetails.dart';
import 'package:eventevent/Widgets/merch/MerchSearch.dart';
import 'package:eventevent/Widgets/merch/PopularItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';
import 'package:eventevent/Widgets/merch/Banner.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MerchItem.dart';
import 'MerchCollection.dart';
import 'package:http/http.dart' as http;

class MerchDashboard extends StatefulWidget {
  final isRest;

  const MerchDashboard({Key key, this.isRest}) : super(key: key);
  @override
  _MerchDashboardState createState() => _MerchDashboardState();
}

class _MerchDashboardState extends State<MerchDashboard> {
  void handleInitialBuild(AppScreenProps props) {
    props.getBanner();
    props.getCollection();
    props.getPopularMerch();
    props.getDiscoverMerch();
    props.getCategoryList();
  }

  // void handleCollectionInitialBuild(CollectionScreenProps collectionProps) {
  //   collectionProps.getCollection();
  // }

  List popularPeopleData = [];
  List discoverPeopleData = [];
  bool isLoading = false;
  String urlType = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPopularPeople();
    fetchDiscoverPeople();
    if (widget.isRest == true) {
      urlType = BaseApi().restUrl;
    } else {
      urlType = BaseApi().apiUrl;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(75),
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            brightness: Brightness.light,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            titleSpacing: 0,
            centerTitle: false,
            title: Container(
              width: ScreenUtil.instance.setWidth(240),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(23),
                    width: ScreenUtil.instance.setWidth(95),
                    child: Hero(
                      tag: 'eventeventlogo',
                      child: Image.asset(
                        'assets/drawable/emerch-logo.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            textTheme: TextTheme(
                title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.instance.setSp(14),
              color: Colors.black,
            )),
            actions: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MerchSearch()));
                },
                child: Container(
                    height: ScreenUtil.instance.setWidth(35),
                    width: ScreenUtil.instance.setWidth(35),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 0),
                              spreadRadius: 1.5,
                              blurRadius: 2)
                        ]),
                    child: Image.asset(
                      'assets/icons/icon_apps/search.png',
                      scale: 4.5,
                    )),
              ),
              SizedBox(width: ScreenUtil.instance.setWidth(8)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: StoreConnector<AppState, AppScreenProps>(
          converter: (store) =>
              mapStateToProps(store, isInRecommendation: false),
          onInitialBuild: (props) => handleInitialBuild(props),
          builder: (context, props) {
            List<MerchBannerModel> bannerData = props.listResponse.data;
            List<MerchCollectionModel> collectionData =
                props.listCollectionResponse.data;
            List<PopularMerchModel> popularMerchData =
                props.listPopularMerchResponse.data;
            List<DiscoverMerchModel> discoverMerchData =
                props.listDiscoverResponse.data;
            List<MerchCategoryModel> categoryData =
                props.listCategoryResponse.data;
            bool bannerLoading = props.listResponse.loading;
            bool collectionLoading = props.listCollectionResponse.loading;
            bool popularMerchLoading = props.listPopularMerchResponse.loading;
            bool discoverMerchLoading = props.listDiscoverResponse.loading;
            bool categoryLoading = props.listCategoryResponse.loading;

            return ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    BannerWidget(loading: bannerLoading, data: bannerData),
                    titleText('Category', ''),
                    categoryLoading == true
                        ? HomeLoadingScreen().merchCategoryLoading()
                        : categoryWidget(data: categoryData, props: props),
                    titleText('Collections',
                        'Check out our hand picked collection bellow'),
                    collectionLoading == true
                        ? HomeLoadingScreen().collectionLoading()
                        : collectionImage(data: collectionData),
                    Row(children: <Widget>[
                      titleText('Popular Merch', 'Most popular products in store'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PopularItem(
                                loading: popularMerchLoading,
                                data: popularMerchData,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(color: eventajaGreenTeal),
                        ),
                      ),
                      SizedBox(
                        width: 13,
                      )
                    ]),
                    popularMerchLoading == true
                        ? HomeLoadingScreen().eventLoading()
                        : merchItem(data: popularMerchData, props: props),
                    peopleText('Popular', onNavigateSeeAll: () {}),
                    peopleImage(data: popularPeopleData),
                    Row(children: <Widget>[
                      titleText('Discover Merch', 'One of these pieces might be made just for you'),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PopularItem(
                                loading: discoverMerchLoading,
                                data: discoverMerchData,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(color: eventajaGreenTeal),
                        ),
                      ),
                      SizedBox(
                        width: 13,
                      )
                    ]),
                    discoverMerchLoading == true
                        ? HomeLoadingScreen().eventLoading()
                        : merchItem(data: discoverMerchData, props: props),
                    peopleText('Discover', onNavigateSeeAll: () {}),
                    peopleImage(data: discoverPeopleData),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget titleText(String mainTitle, String subTitle) {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                mainTitle,
                style: TextStyle(
                    color: eventajaBlack,
                    fontSize: ScreenUtil.instance.setSp(19),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
              height: ScreenUtil.instance.setWidth(subTitle != '' ? 5 : 0)),
          Text(subTitle,
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget categoryWidget({List<MerchCategoryModel> data, AppScreenProps props}) {
    return Container(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: data.map((data) {
          return GestureDetector(
            onTap: () {
              props.getSpecificCategoryList(data.categoryId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryItem(
                    categoryTitle: data.categoryName,
                  ),
                ),
              );
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 2,
                      color: Colors.black.withOpacity(.1),
                      spreadRadius: 1.5)
                ],
              ),
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(),
                  ),
                  Image.network(
                    data.imageUrl == null ? "" : data.imageUrl,
                    scale: 10,
                  ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Text(data.categoryName),
                  SizedBox(
                    height: 15,
                  )
                ],
              )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget peopleText(String title, {Function onNavigateSeeAll}) {
    return Padding(
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                title + ' Merchant',
                style: TextStyle(
                    color: eventajaBlack,
                    fontSize: ScreenUtil.instance.setSp(19),
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4.5,
              )),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onNavigateSeeAll,
                child: Container(
                  height: 20,
                  child: Center(
                    child: Text(
                      'See All',
                      style: TextStyle(
                          color: eventajaGreenTeal,
                          fontSize: ScreenUtil.instance.setSp(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text(
              title == 'Popular'
                  ? 'Find the most popular merchant'
                  : 'Discover the undiscovered',
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget peopleImage({data}) {
    return Container(
      height: ScreenUtil.instance.setWidth(80),
      child: popularPeopleData == null
          ? HomeLoadingScreen().peopleLoading()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (BuildContext context, i) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //     builder: (BuildContext context) => ProfileWidget(
                    //           initialIndex: 0,
                    //           userId: popularPeopleData[i]['id'],
                    //         )));
                  },
                  child: new Container(
                    padding: i == 0
                        ? EdgeInsets.only(left: 13)
                        : EdgeInsets.only(left: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil.instance.setWidth(40.50),
                          width: ScreenUtil.instance.setWidth(41.50),
                          decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3)
                              ],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: data[i]["photo"] == null ? AssetImage('assets/grey-fade.jpg') : NetworkImage(data[i]["photo"]),
                                fit: BoxFit.fill,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget collectionImage({List<MerchCollectionModel> data}) {
    return Container(
      height: ScreenUtil.instance.setWidth(90),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (BuildContext context, i) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MerchCollection(
                    merchId: data[i].collectionId,
                    merchBannerImage: data[i].imageUrl,
                  ),
                ),
              );
            },
            child: new Container(
              width: ScreenUtil.instance.setWidth(150),
              margin: i == 0
                  ? EdgeInsets.only(left: 13)
                  : EdgeInsets.only(left: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: ScreenUtil.instance.setWidth(70),
                    width: ScreenUtil.instance.setWidth(150),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1.5)
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        data[i].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget merchItem({List<dynamic> data, AppScreenProps props}) {
    // print(data[0]);

    return Container(
        height: ScreenUtil.instance.setWidth(300),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, i) {
              print('data' + data[i].toString());
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MerchDetails(
                                merchId: data[i].merchId,
                                minimalData: data[i].toJson(),
                              )));
                },
                child: MerchItem(
                  imageUrl: data[i].imageUrl,
                  title: data[i].productName,
                  color: Color(0xFF34B323),
                  profilePictUrl: data[i].profileImageUrl,
                  price: 'Rp. ' + data[i].details[0]['basic_price'],
                  merchantName: data[i].merchantName,
                ),
              );
            }));
  }

  ///Untuk Fetching gambar PopularPeople
  Future fetchPopularPeople() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    final popularPeopleUrl = urlType +
        '/product/seller?X-API-KEY=$API_KEY&page=1&type=popular&limit=10';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': SIGNATURE
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(popularPeopleUrl, headers: headerType);

    print('Merch dashboard - fetch pop merchant' +
        response.statusCode.toString());

    if (response.statusCode == 200) {
      print('fetched data');
      if (!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        popularPeopleData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: response.reasonPhrase,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context).then((val) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
        });
    }
  }

  ///Untuk fetching gambar DiscoverPeople
  Future fetchDiscoverPeople() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();

    final popularPeopleUrl = urlType +
        '/product/seller?X-API-KEY=$API_KEY&page=1&type=discover&limit=10';

    Map<String, String> headerType = {};

    Map<String, String> headerProd = {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': preferences.getString('Session')
    };

    Map<String, String> headerRest = {
      'Authorization': AUTHORIZATION_KEY,
      'signature': SIGNATURE
    };

    setState(() {
      if (widget.isRest == true) {
        headerType = headerRest;
      } else if (widget.isRest == false) {
        headerType = headerProd;
      }
    });

    final response = await http.get(popularPeopleUrl, headers: headerType);

    print('Merch dashboard - fetch discover people ' +
        response.statusCode.toString());

    if (response.statusCode == 200) {
      print('fetched data discoverPeople');
      if (!mounted) return;
      setState(() {
        var extractedData = json.decode(response.body);
        discoverPeopleData = extractedData['data'];

        isLoading = false;
      });
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: response.reasonPhrase,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context).then((val) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginRegisterWidget()));
        });
    }
  }
}

class AppScreenProps {
  final Function getBanner;
  final ListBannerState listResponse;
  final Function getCollection;
  final ListCollectionState listCollectionResponse;
  final Function getPopularMerch;
  final ListPopularState listPopularMerchResponse;
  final Function getDiscoverMerch;
  final ListDiscoverState listDiscoverResponse;
  final Function getCategoryList;
  final ListCategoryState listCategoryResponse;
  final Function getSpecificCategoryList;

  AppScreenProps(
      {this.getCategoryList,
      this.listCategoryResponse,
      this.getBanner,
      this.listResponse,
      this.getCollection,
      this.listCollectionResponse,
      this.getPopularMerch,
      this.listPopularMerchResponse,
      this.getDiscoverMerch,
      this.listDiscoverResponse,
      this.getSpecificCategoryList});
}

// class CollectionScreenProps {
//   final Function getCollection;
//   final ListCollectionState listResponse;

//   CollectionScreenProps({this.getCollection, this.listResponse});
// }

// CollectionScreenProps mapCollectionStateToProps(Store<AppState> store) {
//   return CollectionScreenProps(
//       listResponse: store.state.collections.list,
//       getCollection: () => store.dispatch(getCollection()));
// }

AppScreenProps mapStateToProps(Store<AppState> store,
    {@required bool isInRecommendation, List<String> categoryIds}) {
  return AppScreenProps(
    listResponse: store.state.banner.list,
    listCollectionResponse: store.state.collections.list,
    listPopularMerchResponse: store.state.popularMerch.list,
    listDiscoverResponse: store.state.discoverMerch.list,
    listCategoryResponse: store.state.category.list,
    getCollection: () => store.dispatch(getCollection()),
    getBanner: () => store.dispatch(getBanners()),
    getPopularMerch: () => store.dispatch(getPopularMerch()),
    getDiscoverMerch: () => store.dispatch(getDiscoverMerch()),
    getCategoryList: () => store.dispatch(getCategory()),
    getSpecificCategoryList: (String id) =>
        store.dispatch(getSpecificCategory(id)),
  );
}
