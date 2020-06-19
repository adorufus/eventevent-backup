import 'package:eventevent/Models/AppState.dart';
import 'package:eventevent/Models/SpecificCategoryListModel.dart';
import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/merch/CollectionItem.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_api_middleware/redux_api_middleware.dart';

class CategoryItem extends StatefulWidget {
  final String categoryTitle;

  const CategoryItem({
    Key key,
    this.categoryTitle,
  }) : super(key: key);

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CategoryScreenProps>(
      converter: (store) => mapStateToProps(store),
      builder: (context, props) {
        List<SpecificCategoryListModel> data =
            props.specificCategoryResponse.data;
        bool isLoading = props.specificCategoryResponse.loading;
        APIError error = props.specificCategoryResponse.error;

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
                  title: Text(widget.categoryTitle),
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
            child:error != null && error.message.contains("400")
                ? Center(
                    child: EmptyState(
                      emptyImage: 'assets/drawable/event_empty_state.png',
                      reasonText: 'No Product Found',
                    ),
                  )
                : ListView.builder(
                    itemCount: data == null ? 0 : data.length,
                    padding: EdgeInsets.only(bottom: 13, left: 13, right: 13),
                    itemBuilder: (context, i) {
                      return CollectionItem(
                        image: data[i].imageUrl,
                        itemColor: eventajaGreenTeal,
                        profileImage: data[i].profileImageUrl,
                        itemPrice: 'Rp. ' + data[i].details[0]['final_price'],
                        title: data[i].productName,
                        username: data[i].merchantName,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class CategoryScreenProps {
  final ListSpecificCategory specificCategoryResponse;

  CategoryScreenProps({this.specificCategoryResponse});
}

CategoryScreenProps mapStateToProps(Store<AppState> store) {
  return CategoryScreenProps(
      specificCategoryResponse: store.state.specificCategories.list);
}
