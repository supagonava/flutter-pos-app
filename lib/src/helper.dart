import 'package:charset_converter/charset_converter.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';

getPageSize(BuildContext context) => MediaQuery.of(context).size;

printReciept(PrinterBluetooth? printer, POSSellState printState, String billingNo) async {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  if (printer != null) {
    try {
      byteThaiChar(message) async => await CharsetConverter.encode('TIS-620', '$message');

      final shop = SHOP_BRANCH.firstWhere((el) => el.code == printState.shopCode);
      printerManager.selectPrinter(printer);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      printBody(List<int> bytes, bool isOriginal) async {
        bytes += generator.textEncoded((await byteThaiChar('ใบเสร็จอย่างย่อ ${isOriginal ? 'ต้นฉบับ' : 'สำเนา'}')), styles: PosStyles(align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes += generator.textEncoded((await byteThaiChar(shop.name)));
        bytes += generator.text("BN: $billingNo");
        bytes += generator.emptyLines(1);
        bytes += generator.textEncoded((await byteThaiChar(TABLE_NAMES[printState.tableNumber])));
        bytes += generator.text(DateTime.now().toLocal().toString());
        bytes += generator.text('', styles: PosStyles(height: PosTextSize.size2));
        double totalAmount = 0;

        bytes += generator.textEncoded((await byteThaiChar('รายการสินค้า')));
        for (var cart in printState.carts) {
          final recordAmount = (cart.product?.price ?? 0) * (cart.quantity ?? 0);
          bytes += generator.row([
            PosColumn(
                text: '', textEncoded: await byteThaiChar("${cart.product?.name} (${cart.product?.price} x ${cart.quantity})"), width: 9, styles: PosStyles(align: PosAlign.left)),
            PosColumn(text: '', textEncoded: await byteThaiChar('$recordAmount.-'), width: 3, styles: PosStyles(align: PosAlign.right)),
          ]);
          totalAmount += recordAmount;
        }
        bytes += generator.emptyLines(1);
        bytes += generator.row([
          PosColumn(text: 'Total', width: 9, styles: PosStyles(align: PosAlign.left)),
          PosColumn(text: "$totalAmount .-", width: 3, styles: PosStyles(align: PosAlign.right)),
        ]);
        return bytes;
      }

      bytes = await printBody(bytes, true);
      bytes += generator.textEncoded((await byteThaiChar('ขอบพระคุณที่มาอุดหนุนค่ะ')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('โอกาสหน้าเชิญชวนอีกครั้งนะคะ')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('ติดต่อร้าน')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('k\'บอย 0923457633')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('k\'ผึ้ง 0928707863')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.emptyLines(1);
      bytes += generator.text('-------THANK YOU!---------', styles: PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(3);
      // bytes = await printBody(bytes, false);
      // bytes += generator.emptyLines(3);

      // Print image:
      // final ByteData data = await rootBundle.load('assets/flutter_logo.png');
      // final Uint8List imgBytes = data.buffer.asUint8List();
      // final Image image = decodeImage(imgBytes)!;
      // bytes += generator.image(image);

      // Print barcode
      // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
      // bytes += generator.barcode(Barcode.upcA(barData));

      await printerManager.printTicket(bytes);
      print("DONE!");
    } catch (e) {
      print(e);
    }
  }
}
