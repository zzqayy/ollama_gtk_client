class MyDateUtils {
  //获取一天的开始
  static DateTime getDayStart(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
  }

  //获取一天的结束
  static DateTime getDayEnd(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  //转换为默认的字符串时间格式
  static String? date2DateTimeStr(DateTime? dateTime) {
    if(dateTime == null) {
      return null;
    }
    var year = MyDateUtils.lessTenDeal(dateTime.year);
    var month = MyDateUtils.lessTenDeal(dateTime.month);
    var day = MyDateUtils.lessTenDeal(dateTime.day);
    var hour = MyDateUtils.lessTenDeal(dateTime.hour);
    var minute = MyDateUtils.lessTenDeal(dateTime.minute);
    var second = MyDateUtils.lessTenDeal(dateTime.second);
    return "$year-$month-$day $hour:$minute:$second";
  }

  //转换为默认的字符串时间格式
  static String? date2DateStr(DateTime? dateTime) {
    if(dateTime == null) {
      return null;
    }
    var year = MyDateUtils.lessTenDeal(dateTime.year);
    var month = MyDateUtils.lessTenDeal(dateTime.month);
    var day = MyDateUtils.lessTenDeal(dateTime.day);
    return "$year-$month-$day";
  }

  static String lessTenDeal(int val) {
    return val < 10 ? "0$val" : val.toString();
  }

  /// 解析时间格式
  static DateTime? parseDateTimeFromStr(String? datetimeStr) {
    return DateTime.tryParse(datetimeStr??"")?.toUtc().add(const Duration(hours: 8));
  }

  /// 解析时间格式
  static DateTime? parseDateFromStr(String datetimeStr) {
    return DateTime.tryParse(datetimeStr);
  }
}