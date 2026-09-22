import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatRupiah(int amount) => _rupiah.format(amount);

String formatDateTime(DateTime value) {
  return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(value);
}

String formatDayLabel(DateTime value) {
  return DateFormat('E', 'id_ID').format(value);
}
