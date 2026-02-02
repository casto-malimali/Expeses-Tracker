import 'dart:io';

import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  // Export PDF
  static Future<void> exportToPDF(List<Map> items, String month) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Income & Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text('Month: $month'),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ['Date', 'Category', 'Note', 'Type', 'Amount'],

                data: items.map((e) {
                  return [
                    e['date'].toString().substring(0, 10),
                    e['category'],
                    e['note'],
                    e['isIncome'] ? 'Income' : 'Expense',
                    e['amount'].toString(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/report_$month.pdf');

    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  // Export Excel
  static Future<void> exportToExcel(List<Map> items, String month) async {
    final excel = Excel.createExcel();

    final sheet = excel['Report'];

    sheet.appendRow([
      'Date' as CellValue?,
      'Category' as CellValue?,
      'Note' as CellValue?,
      'Type' as CellValue?,
      'Amount' as CellValue?,
    ]);

    for (var e in items) {
      sheet.appendRow([
        e['date'].toString().substring(0, 10) as CellValue?,
        e['category'] as CellValue?,
        e['note'] as CellValue?,
        (e['isIncome'] ? 'Income' : 'Expense') as CellValue?,
        e['amount'] as CellValue?,
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/report_$month.xlsx');

    file.writeAsBytesSync(excel.encode()!);

    await OpenFilex.open(file.path);
  }
}
