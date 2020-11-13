import 'package:flutter_money_formatter/flutter_money_formatter.dart';

Iterable<E> mapIndexed<E, T>(Iterable<T> items, E Function(int index, T item) f) sync* {
    var index = 0;
    for(final item in items){
      yield f(index, item);
      index = index + 1;
    }
}

String formatPrice({String price}){
  MoneyFormatterOutput fo = FlutterMoneyFormatter(amount: double.parse(price + '.0')).output;

  return fo.withoutFractionDigits;
}

class Utils {
  String currentUserId;

  String get getCurrentUserId{
    return currentUserId;
  }

  void setCurrentUserId (String currentUserId){
    this.currentUserId = currentUserId;
  }

  Utils({this.currentUserId});
}