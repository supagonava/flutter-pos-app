import 'package:charset_converter/charset_converter.dart';
import 'package:dimsummaster/src/constants.dart';
import 'package:dimsummaster/src/posshop/index.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';

getPageSize(BuildContext context) => MediaQuery.of(context).size;
unfocus(ctx) => FocusScope.of(ctx).unfocus();
printReciept(PrinterBluetooth? printer, POSSellState printState, String billingNo, String shopname) async {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  final Shop shop = printState.shop;
  if (printer != null) {
    try {
      byteThaiChar(message) async => await CharsetConverter.encode('TIS-620', '$message');

      // final shop = SHOP_BRANCH.firstWhere((el) => el.code == printState.shopCode);
      printerManager.selectPrinter(printer);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      printBody(List<int> bytes) async {
        bytes += generator.textEncoded((await byteThaiChar('ใบเสร็จอย่างย่อ')), styles: PosStyles(align: PosAlign.center));
        bytes += generator.emptyLines(1);
        bytes += generator.textEncoded((await byteThaiChar(shopname)));
        bytes += generator.text("BN: $billingNo");
        bytes += generator.emptyLines(1);
        bytes += generator.textEncoded((await byteThaiChar(TABLE_NAMES[printState.tableNumber])));
        bytes += generator.text(DateTime.now().toLocal().toString());
        bytes += generator.text('', styles: PosStyles(height: PosTextSize.size2));
        double totalAmount = 0;

        bytes += generator.row([
          PosColumn(text: '===========', width: 4, styles: PosStyles(align: PosAlign.left)),
          PosColumn(text: "ITEMS", width: 4, styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '===========', width: 4, styles: PosStyles(align: PosAlign.right)),
        ]);
        for (var cart in printState.carts) {
          final recordAmount = (cart.product?.price ?? 0) * (cart.quantity ?? 0);
          bytes += generator.row([PosColumn(text: '', textEncoded: await byteThaiChar("${cart.product?.name}"), width: 12, styles: PosStyles(align: PosAlign.left))]);
          bytes += generator.row([
            PosColumn(text: '(${cart.product?.price} x ${cart.quantity})', width: 8, styles: PosStyles(align: PosAlign.left)),
            PosColumn(text: '$recordAmount.-', width: 4, styles: PosStyles(align: PosAlign.right)),
          ]);
          totalAmount += recordAmount;
        }
        bytes += generator.text('------------------------------', styles: PosStyles(align: PosAlign.center));
        bytes += generator.row([
          PosColumn(text: 'Total', width: 9, styles: PosStyles(align: PosAlign.left)),
          PosColumn(text: "$totalAmount .-", width: 3, styles: PosStyles(align: PosAlign.right)),
        ]);
        return bytes;
      }

      bytes = await printBody(bytes);
      bytes += generator.text('------------------------------', styles: PosStyles(align: PosAlign.center));
      bytes += generator.textEncoded((await byteThaiChar('ขอบพระคุณที่มาอุดหนุนค่ะ')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('โอกาสหน้าเชิญชวนอีกครั้งนะคะ')), styles: PosStyles(align: PosAlign.left));
      bytes += generator.textEncoded((await byteThaiChar('ติดต่อร้าน')), styles: PosStyles(align: PosAlign.left));
      for (var contact in shop.contacts ?? []) {
        if (contact['contact'].toString().isNotEmpty) {
          bytes += generator.textEncoded((await byteThaiChar('${contact['contact'] ?? ''} ${contact['phone'] ?? ''}')), styles: PosStyles(align: PosAlign.left));
        }
      }
      bytes += generator.emptyLines(1);
      bytes += generator.text('-------THANK YOU!---------', styles: PosStyles(align: PosAlign.center));
      bytes += generator.emptyLines(3);

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
