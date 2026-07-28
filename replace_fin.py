import re

file_path = r'c:\Users\User\Desktop\New folder\salepro\lib\screens\admin\admin_reports_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = "  Widget _buildSleekFinancialKPIs("
end_marker = "  Widget _buildModernIncomeExpense("

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("Could not find markers.")
    exit(1)

new_content = """  Widget _buildSleekFinancialKPIs(
    double totalRev,
    double totalCollected,
    double income,
    double profit,
    double profitPct,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      bool isDesktop = constraints.maxWidth >= 900;
      return GridView.count(
        crossAxisCount: isDesktop ? 4 : (constraints.maxWidth >= 600 ? 2 : 1),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isDesktop ? 2.0 : 2.6,
        children: [
          _buildSleekMetricCard('Gross Revenue', 'Rs. ${totalRev.toStringAsFixed(0)}', Icons.monetization_on, [Colors.blue.shade300, Colors.blue.shade400]),
          _buildSleekMetricCard('Total Collected', 'Rs. ${totalCollected.toStringAsFixed(0)}', Icons.payments, [Colors.green.shade300, Colors.green.shade400]),
          _buildSleekMetricCard('Pending', 'Rs. ${(totalRev - totalCollected > 0 ? totalRev - totalCollected : 0).toStringAsFixed(0)}', Icons.receipt_long, [Colors.orange.shade300, Colors.orange.shade400]),
          _buildSleekMetricCard('Net Profit Margin', '${profitPct.toStringAsFixed(1)}%', Icons.pie_chart, [Colors.purple.shade300, Colors.purple.shade400]),
        ],
      );
    });
  }

"""

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content[:start_idx] + new_content + content[end_idx:])
print("Successfully replaced Financial KPIs section!")
