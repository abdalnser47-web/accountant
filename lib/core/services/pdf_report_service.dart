import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// خدمة إنشاء تقارير PDF احترافية
class PdfReportService {
  
  /// إنشاء كشف حساب PDF
  static Future<void> generateAccountStatement({
    required String accountName,
    required double openingBalance,
    required double closingBalance,
    required List<Map<String, dynamic>> transactions,
    required String currency,
  }) async {
    final pdf = pw.Document();
    
    // تحميل الخط العربي (اختياري - يحتاج ملف خط)
    // final font = await PdfGoogleFonts.cairoRegular();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // --- الرأس ---
            _buildHeader(accountName, currency),
            
            pw.SizedBox(height: 20),
            
            // --- ملخص الحساب ---
            _buildSummary(
              openingBalance,
              closingBalance,
              currency,
            ),
            
            pw.SizedBox(height: 30),
            
            // --- جدول المعاملات ---
            _buildTransactionsTable(transactions, currency),
            
            pw.SizedBox(height: 20),
            
            // --- التذييل ---
            _buildFooter(),
          ];
        },
      ),
    );
    
    // عرض أو طباعة أو مشاركة الـ PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'كشف_حساب_${accountName}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
    );
  }
  
  /// إنشاء تقرير المصروفات الشهري
  static Future<void> generateMonthlyExpenseReport({
    required String month,
    required double totalExpenses,
    required Map<String, double> categoryBreakdown,
    required String currency,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // العنوان
              pw.Header(
                level: 0,
                child: pw.Text(
                  'تقرير المصروفات الشهري',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 10),
              
              pw.Text(
                'الشهر: $month',
                style: const pw.TextStyle(fontSize: 16),
              ),
              
              pw.SizedBox(height: 30),
              
              // الملخص
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'إجمالي المصروفات:',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      '${totalExpenses.toStringAsFixed(2)} $currency',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // تفصيل التصنيفات
              pw.Text(
                'التفصيل حسب التصنيف:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('التصنيف'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('المبلغ'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('النسبة'),
                      ),
                    ],
                  ),
                  // البيانات
                  ...categoryBreakdown.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses * 100);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${entry.value.toStringAsFixed(2)} $currency'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${percentage.toStringAsFixed(1)}%'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              
              pw.Spacer(),
              
              // التذييل
              _buildFooter(),
            ],
          );
        },
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'تقرير_المصروفات_$month.pdf',
    );
  }
  
  /// بناء الرأس
  static pw.Widget _buildHeader(String accountName, String currency) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'كشف حساب',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            accountName,
            style: pw.TextStyle(
              fontSize: 20,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'العملة: $currency',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  /// بناء ملخص الحساب
  static pw.Widget _buildSummary(
    double openingBalance,
    double closingBalance,
    String currency,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(
            children: [
              pw.Text(
                'الرصيد الافتتاحي',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${openingBalance.toStringAsFixed(2)} $currency',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Container(
            width: 1,
            height: 50,
            color: PdfColors.grey400,
          ),
          pw.Column(
            children: [
              pw.Text(
                'الرصيد الختامي',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${closingBalance.toStringAsFixed(2)} $currency',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: closingBalance >= 0 ? PdfColors.green700 : PdfColors.red700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// بناء جدول المعاملات
  static pw.Widget _buildTransactionsTable(
    List<Map<String, dynamic>> transactions,
    String currency,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // رأس الجدول
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('التاريخ'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('البيان'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('نوع العملية'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المبلغ', textAlign: pw.TextAlign.right),
            ),
          ],
        ),
        // المعاملات
        ...transactions.map((transaction) {
          final isIncome = transaction['type'] == 'income';
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(transaction['date']),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(transaction['description'] ?? '-'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(isIncome ? 'دخل' : 'مصروف'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${transaction['amount'].toStringAsFixed(2)} $currency',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    color: isIncome ? PdfColors.green700 : PdfColors.red700,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  /// بناء التذييل
  static pw.Widget _buildFooter() {
    return pw.Align(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'تم إنشاء هذا التقرير إلكترونياً بواسطة تطبيق مدير الحسابات',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
