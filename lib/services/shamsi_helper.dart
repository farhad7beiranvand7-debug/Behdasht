import 'package:shamsi_date/shamsi_date.dart';

class ShamsiHelper {
  static String toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    String output = input;
    for (int i = 0; i < 10; i++) {
      output = output.replaceAll(english[i], persian[i]);
    }
    return output;
  }

  static String formatFa(DateTime date) {
    final Jalali jDate = Jalali.fromDateTime(date);
    String dateStr = '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';
    return toPersianDigits(dateStr);
  }
}
