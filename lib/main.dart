import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/src/capability_profile.dart';
import 'package:esc_pos_utils/src/enums.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart' as flueP;
import 'package:esc_pos_utils/esc_pos_utils.dart' as pos;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ThermalPrinterScreen(),
    );
  }
}

class ThermalPrinterScreen extends StatefulWidget {
  @override
  _ThermalPrinterScreenState createState() => _ThermalPrinterScreenState();
}

class _ThermalPrinterScreenState extends State<ThermalPrinterScreen> {
  final TextEditingController _ipController = TextEditingController();

  void _printSampleReceipt() async {
    final String printerIp = _ipController.text;
    final profile = await pos.CapabilityProfile.load();
    final printer = flueP.NetworkPrinter(PaperSize.mm80, profile as CapabilityProfile);
    final PosPrintResult res = await printer.connect(printerIp, port: 9100);
    if (res == PosPrintResult.success) {
      await _generateReceipt(printer);
      printer.disconnect();
    } else {
      print('Could not connect to printer: $res');
    }
  }

  Future<void> _generateReceipt(NetworkPrinter printer) async {
    printer.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
    );
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: const pos.PosStyles(codeTable: 'CP1252'));
    printer.text('Special 2: blåbærgrød',
        styles: const pos.PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: const pos.PosStyles(bold: true));
    printer.text('Reverse text', styles: const pos.PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: const pos.PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: const pos.PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: const pos.PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: const pos.PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.row([
      pos.PosColumn(
        text: 'col3',
        width: 3,
        styles: const pos.PosStyles(align: PosAlign.center, underline: true),
      ),
      pos.PosColumn(
        text: 'col6',
        width: 6,
        styles: const pos.PosStyles(align: PosAlign.center, underline: true),
      ),
      pos.PosColumn(
        text: 'col3',
        width: 3,
        styles: const pos.PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    printer.text('Text size 200%',
        styles: const pos.PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    printer.barcode(pos.Barcode.upcA(barData));

    printer.feed(2);
    printer.cut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thermal Printer App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Printer IP Address',
                hintText: 'e.g., 192.168.0.100',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printSampleReceipt,
              child: Text('Print Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}
