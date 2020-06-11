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
import 'package:eventevent/Redux/Reducers/logger.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/PopularEventWidget.dart';
import 'package:eventevent/Widgets/merch/MerchDetails.dart';
import 'package:eventevent/Widgets/merch/PopularItem.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redux/redux.dart';
import 'package:eventevent/Models/MerchBannerModel.dart';
import 'package:eventevent/Redux/Reducers/BannerReducers.dart';
import 'package:eventevent/Widgets/merch/Banner.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'MerchItem.dart';
import 'MerchCollection.dart';

class MerchDashboard extends StatefulWidget {
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
            // actions: <Widget>[
            //   GestureDetector(
            //     onTap: () {},
            //     child: Container(
            //         height: ScreenUtil.instance.setWidth(35),
            //         width: ScreenUtil.instance.setWidth(35),
            //         decoration: BoxDecoration(
            //             color: Colors.white,
            //             shape: BoxShape.circle,
            //             boxShadow: <BoxShadow>[
            //               BoxShadow(
            //                   color: Colors.black.withOpacity(0.1),
            //                   offset: Offset(0, 0),
            //                   spreadRadius: 1.5,
            //                   blurRadius: 2)
            //             ]),
            //         child: Image.asset(
            //           'assets/icons/icon_apps/search.png',
            //           scale: 4.5,
            //         )),
            //   ),
            //   SizedBox(width: ScreenUtil.instance.setWidth(8)),
            // ],
          ),
        ),
      ),
      body: SafeArea(
        child: StoreConnector<AppState, AppScreenProps>(
          converter: (store) => mapStateToProps(store),
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
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 6,
                            ),
                            child: categoryWidget(data: categoryData),
                          ),
                    titleText('Collections',
                        'Check out our hand picked collection bellow'),
                    collectionLoading == true
                        ? HomeLoadingScreen().collectionLoading()
                        : collectionImage(data: collectionData),
                    Row(children: <Widget>[
                      titleText('Popular Merch', 'Lorem Ipsum Dolor'),
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
                    Row(children: <Widget>[
                      titleText('Discover Merch', 'Lorem Ipsum Dolor Sit Amet'),
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
      padding: EdgeInsets.only(left: 13, right: 13, top: 20, bottom: 6),
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
          SizedBox(height: ScreenUtil.instance.setWidth(5)),
          Text(subTitle,
              style: TextStyle(
                  color: Color(0xFF868686),
                  fontSize: ScreenUtil.instance.setSp(14))),
        ],
      ),
    );
  }

  Widget categoryWidget({List<MerchCategoryModel> data}) {
    return Container(
      width: 550,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: data.map((data) {
          return Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                image: NetworkImage(data.imageUrl),
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    blurRadius: 2,
                    color: Colors.black.withOpacity(.1),
                    spreadRadius: 1.5)
              ],
            ),
          );
        }).toList(),
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
                  builder: (context) => MerchCollection(),
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
              print(data[i]);
              return GestureDetector(
                onTap: () {
                  props.getMerchDetail(data[i].merchId);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MerchDetails()));
                },
                child: MerchItem(
                  imageUrl: data[i].imageUrl,
                  title: data[i].productName,
                  color: eventajaGreenTeal,
                  profilePictUrl: data[i].profileImageUrl,
                  price: 'Rp. ' + data[i].details[0]['basic_price'],
                  merchantName: data[i].merchantName,
                ),
              );
            }));
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
  final Function getMerchDetail;

  AppScreenProps({
    this.getCategoryList,
    this.listCategoryResponse,
    this.getBanner,
    this.listResponse,
    this.getCollection,
    this.listCollectionResponse,
    this.getPopularMerch,
    this.listPopularMerchResponse,
    this.getDiscoverMerch,
    this.listDiscoverResponse,
    this.getMerchDetail,
  });
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

AppScreenProps mapStateToProps(Store<AppState> store) {
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
    getMerchDetail: (String id) => store.dispatch(getMerchDetail(id)),
  );
}
