class DateTimeConverter{
  static String convertToNamedMonth(DateTime dateTime, String separatorType) {
    String monthToString;

    if(dateTime.month == 1 || dateTime.month == 01){
      monthToString = 'January';
    } else if(dateTime.month == 2 || dateTime.month == 02){
      monthToString = 'February';
    } else if(dateTime.month == 3 || dateTime.month == 03){
      monthToString = 'March';
    } else if(dateTime.month == 4 || dateTime.month == 04){
      monthToString = 'April';
    } else if(dateTime.month == 5 || dateTime.month == 05){
      monthToString = 'May';
    } else if(dateTime.month == 6 || dateTime.month == 06){
      monthToString = 'June';
    } else if(dateTime.month == 7 || dateTime.month == 07){
      monthToString = 'July';
    } else if(dateTime.month == 8 || dateTime.month == 08){
      monthToString = 'August';
    } else if(dateTime.month == 9 || dateTime.month == 09){
      monthToString = 'September';
    } else if(dateTime.month == 10){
      monthToString = 'October';
    } else if(dateTime.month == 11){
      monthToString = 'November';
    } else if(dateTime.month == 12){
      monthToString = 'December';
    }

    return '${dateTime.day}$separatorType$monthToString$separatorType${dateTime.year}';
  }

  static String convertToDate(DateTime dateTime, String separatorType){
    return '${dateTime.year}$separatorType${dateTime.month}$separatorType${dateTime.day}';
  }

  static String convertToTime(DateTime dateTime, String separatorType){
    return '${dateTime.hour}$separatorType${dateTime.minute}${separatorType}00';
  }
}