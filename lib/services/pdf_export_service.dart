import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';

class PdfExportService {
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _numberFormat = NumberFormat('#,##0.00');
  static String _formatCurrency(double amount) => 'Rs. ${_numberFormat.format(amount)}';

  static Future<void> generateSalesReport(List<OrderModel> orders, String title) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => _buildHeader(title),
        build: (pw.Context context) => [
          _buildSalesTable(orders),
        ],
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generateFinancialReport(
      List<OrderModel> orders, List<PaymentModel> payments, String title) async {
    final pdf = pw.Document();

    final totalRevenue = orders.where((o) => o.status != 'cancelled').fold(0.0, (sum, o) => sum + o.totalAmount);
    final totalCollected = payments.fold(0.0, (sum, p) => sum + p.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => _buildHeader(title),
        build: (pw.Context context) => [
          pw.Text('Financial Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard('Total Revenue', totalRevenue),
              _buildSummaryCard('Total Collected', totalCollected),
              _buildSummaryCard('Balance Due', totalRevenue - totalCollected),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Recent Payments', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          _buildPaymentsTable(payments),
        ],
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generateRepReport(
      List<UserModel> reps, List<OrderModel> orders, List<PaymentModel> payments, String title) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) => _buildHeader(title),
        build: (pw.Context context) => [
          _buildRepsTable(reps, orders, payments),
        ],
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${title.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('SalePro Business Report',
            style: pw.TextStyle(color: PdfColors.blue800, fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(title, style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text('Generated on: ${_dateFormat.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey500)),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(color: PdfColors.grey),
      ),
    );
  }

  static pw.Widget _buildSummaryCard(String label, double amount) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text(_formatCurrency(amount),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.blue800)),
        ],
      ),
    );
  }

  static pw.Widget _buildSalesTable(List<OrderModel> orders) {
    final headers = ['Order ID', 'Date', 'Shop Name', 'Status', 'Amount'];
    final data = orders.map((order) {
      return [
        order.orderId.length >= 8 ? order.orderId.substring(0, 8) : order.orderId, // Short ID
        _dateFormat.format(order.timestamp),
        order.shopName,
        order.status.toUpperCase(),
        _formatCurrency(order.totalAmount),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildPaymentsTable(List<PaymentModel> payments) {
    final headers = ['Date', 'Shop Name', 'Route', 'Amount'];
    final data = payments.map((payment) {
      return [
        _dateFormat.format(payment.timestamp),
        payment.shopName,
        payment.routeName,
        _formatCurrency(payment.amount),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildRepsTable(List<UserModel> reps, List<OrderModel> orders, List<PaymentModel> payments) {
    final headers = ['Rep Name', 'Phone', 'Total Sales', 'Collected', 'Balance'];
    final data = reps.map((rep) {
      final repOrders = orders.where((o) => o.repId == rep.uid && o.status != 'cancelled');
      final repPayments = payments.where((p) => p.repId == rep.uid);
      
      final sales = repOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
      final collected = repPayments.fold(0.0, (sum, p) => sum + p.amount);
      
      return [
        rep.name,
        rep.phone,
        _formatCurrency(sales),
        _formatCurrency(collected),
        _formatCurrency(sales - collected),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }
}
