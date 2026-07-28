import json
import os

with open('extracted_methods.json', 'r', encoding='utf-8') as f:
    extracted = json.load(f)

common_imports = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/route_provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/rep_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../models/route_model.dart';
import '../../../models/user_model.dart';
import '../../../models/visit_model.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_model.dart';
import '../../../models/shop_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/pdf_export_service.dart';
"""

def generate_stateless(filename, class_name, category):
    methods = "\n".join(extracted[category])
    
    # We rename the main method to build
    main_method_name = extracted[category][0].split('Widget ')[1].split('(')[0]
    
    # Actually it's easier to just call the main method from build
    content = f"""{common_imports}

class {class_name} extends StatelessWidget {{
  const {class_name}({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{class_name.replace("Admin", "").replace("Screen", "")}'),
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
                {main_method_name}(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }}

{methods}
}}
"""
    with open(f"lib/screens/admin/{filename}", 'w', encoding='utf-8') as f:
        f.write(content)

def generate_stateful(filename, class_name, category, extra_state):
    methods = "\n".join(extracted[category])
    main_method_name = extracted[category][0].split('Widget ')[1].split('(')[0]
    
    content = f"""{common_imports}

class {class_name} extends StatefulWidget {{
  const {class_name}({{super.key}});

  @override
  State<{class_name}> createState() => _{class_name}State();
}}

class _{class_name}State extends State<{class_name}> {{
{extra_state}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(
        title: const Text('{class_name.replace("Admin", "").replace("Screen", "")}'),
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
                {main_method_name}(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }}

{methods}
}}
"""
    with open(f"lib/screens/admin/{filename}", 'w', encoding='utf-8') as f:
        f.write(content)

# 1. Sales (Stateless)
generate_stateless('admin_sales_report_screen.dart', 'AdminSalesReportScreen', 'sales')

# 2. Routes (Stateless)
generate_stateless('admin_route_analytics_screen.dart', 'AdminRouteAnalyticsScreen', 'route')

# 3. Export (Stateless)
generate_stateless('admin_export_center_screen.dart', 'AdminExportCenterScreen', 'export')

# 4. Rep (Stateful)
rep_state = """
  List<VisitModel> _allVisits = [];
  bool _visitsLoaded = false;
  static const double defaultMonthlyTarget = 500000.0;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('visits').get();
      if (mounted) {
        setState(() {
          _allVisits = snapshot.docs
              .map((doc) => VisitModel.fromMap(doc.data(), doc.id))
              .toList();
          _visitsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching visits: $e');
      if (mounted) {
        setState(() => _visitsLoaded = true);
      }
    }
  }
"""
generate_stateful('admin_rep_analytics_screen.dart', 'AdminRepAnalyticsScreen', 'rep', rep_state)

# 5. Financial (Stateful)
fin_state = """
  String _selectedFinancialPeriod = 'This Month';
  String _selectedFinancialRoute = 'All';
  String _selectedFinancialRep = 'All';
"""
generate_stateful('admin_financial_analytics_screen.dart', 'AdminFinancialAnalyticsScreen', 'financial', fin_state)

print('Generated 5 screens')
