import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:simple_coffee_shop/core/utils/formatters.dart';
import 'package:simple_coffee_shop/data/models/order.dart';

class PrintService {
  Future<void> printInvoice({
    required String shopName,
    required Order order,
  }) async {
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;
      if (connected != true) return;

      final buffer = StringBuffer()
        ..writeln(shopName)
        ..writeln(order.invoiceNo)
        ..writeln(formatDateTime(order.createdAt))
        ..writeln('Metode: ${order.paymentLabel}')
        ..writeln('----------------');

      for (final item in order.items) {
        buffer.writeln('${item.productName} x${item.qty}');
        buffer.writeln(formatRupiah(item.lineTotal));
      }

      buffer
        ..writeln('----------------')
        ..writeln('Total ${formatRupiah(order.total)}');
      if (order.isCash) {
        buffer
          ..writeln('Tunai ${formatRupiah(order.paid)}')
          ..writeln('Kembali ${formatRupiah(order.changeAmount)}');
      }
      buffer.writeln('Terima kasih');
      buffer.writeln();

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 2, text: buffer.toString()),
      );
    } catch (_) {
      // Tidak ada printer / izin / perangkat: abaikan.
    }
  }
}
