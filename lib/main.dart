import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(KasirApp());
}

class KasirApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kasir Sederhana',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KasirHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KasirHomePage extends StatefulWidget {
  @override
  _KasirHomePageState createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _addItem() {
    final String itemName = _itemController.text;
    final double itemPrice = double.parse(_priceController.text);

    setState(() {
      _items.add({'name': itemName, 'price': itemPrice});
    });

    _itemController.clear();
    _priceController.clear();
  }

  void _editItem(int index) {
    final TextEditingController editItemController =
        TextEditingController(text: _items[index]['name']);
    final TextEditingController editPriceController =
        TextEditingController(text: _items[index]['price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editItemController,
              decoration: InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: editPriceController,
              decoration: InputDecoration(labelText: 'Harga Barang'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Simpan'),
            onPressed: () {
              setState(() {
                _items[index]['name'] = editItemController.text;
                _items[index]['price'] = double.parse(editPriceController.text);
              });
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _resetItems() {
    setState(() {
      _items.clear();
    });
  }

  double _calculateTotal() {
    return _items.fold(0, (sum, item) => sum + item['price']);
  }

  Future<void> _printReceipt() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('==== Struk Pembelian ====',
                    style: pw.TextStyle(fontSize: 24)),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                },
                children: _items.map((item) {
                  return pw.TableRow(
                    children: [
                      pw.Text(item['name'], style: pw.TextStyle(fontSize: 18)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(_currencyFormat.format(item['price']),
                            style: pw.TextStyle(fontSize: 18)),
                      ),
                    ],
                  );
                }).toList(),
              ),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    'Total: ${_currencyFormat.format(_calculateTotal())}',
                    style: pw.TextStyle(fontSize: 18)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showReceiptDialog() {
    final StringBuffer receipt = StringBuffer();
    receipt.writeln('==== Struk Pembelian ====');
    _items.forEach((item) {
      receipt.writeln(
          '${item['name']} - ${_currencyFormat.format(item['price'])}');
    });
    receipt.writeln('=========================');
    receipt.writeln('Total: ${_currencyFormat.format(_calculateTotal())}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Struk Pembelian'),
        content: SingleChildScrollView(child: Text(receipt.toString())),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _printReceipt();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print), // Ikon print
                SizedBox(width: 8), // Spasi horizontal antara ikon dan teks
                Text('Print PDF'), // Teks tombol
              ],
            ),
          ),
          TextButton(
            child: Text('Tutup'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.wallet), // Icon cashier
            SizedBox(width: 8), // Spasi antara ikon dan teks
            Text('Kasir'), // Judul aplikasi
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _itemController,
                        decoration: InputDecoration(labelText: 'Nama Barang'),
                      ),
                      TextField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Harga Barang'),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Tambahkan Barang',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (ctx, index) {
                    final item = _items[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(item['name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_currencyFormat.format(item['price'])),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editItem(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _resetItems,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.white), // Ikon reset
                        SizedBox(
                            width: 8), // Spasi horizontal antara ikon dan teks
                        Text(
                          'Reset Data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showReceiptDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, color: Colors.white),
                        SizedBox(
                            width: 8), // Spasi horizontal antara ikon dan teks
                        Text(
                          'Lihat Struk',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
