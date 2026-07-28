import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/rep_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../services/pdf_export_service.dart';

class AdminExportCenterScreen extends StatelessWidget {
  const AdminExportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExportCenter'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildExportCenter(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCenter(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final payments = context.watch<PaymentProvider>().payments;
    final reps = context.watch<RepProvider>().reps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Center',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate and export beautifully formatted PDF reports for your business data.',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 900
                ? 3
                : (MediaQuery.of(context).size.width >= 600 ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildExportCard(
                'Sales Report',
                'Export a comprehensive list of all recent sales orders.',
                Icons.shopping_bag_outlined,
                Colors.blue,
                () => PdfExportService.generateSalesReport(
                  orders,
                  'Sales Report',
                ),
              ),
              _buildExportCard(
                'Financial Report',
                'Export revenue, collections, and balance summary.',
                Icons.account_balance_wallet_outlined,
                Colors.green,
                () => PdfExportService.generateFinancialReport(
                  orders,
                  payments,
                  'Financial Report',
                ),
              ),
              _buildExportCard(
                'Rep Performance',
                'Export sales and collection performance for all representatives.',
                Icons.groups_outlined,
                Colors.purple,
                () => PdfExportService.generateRepReport(
                  reps,
                  orders,
                  payments,
                  'Rep Performance Report',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onExport,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
