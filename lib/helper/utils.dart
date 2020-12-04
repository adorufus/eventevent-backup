import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;
  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

String formatPrice({String price}) {
  MoneyFormatterOutput fo =
      FlutterMoneyFormatter(amount: double.parse(price + '.0')).output;

  return fo.withoutFractionDigits;
}

class Utils {
  String currentUserId;

  String get getCurrentUserId {
    return currentUserId;
  }

  void setCurrentUserId(String currentUserId) {
    this.currentUserId = currentUserId;
  }

  Utils({this.currentUserId});
}

class TextFieldFormatPrice extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "id_ID");

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
