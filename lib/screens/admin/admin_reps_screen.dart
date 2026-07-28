import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../widgets/rep_card.dart';
import 'admin_assign_rep_screen.dart';
import 'admin_rep_performance_screen.dart';
import '../../../providers/route_provider.dart';

class AdminRepsScreen extends StatefulWidget {
  const AdminRepsScreen({super.key});

  @override
  State<AdminRepsScreen> createState() => _AdminRepsScreenState();
}

class _AdminRepsScreenState extends State<AdminRepsScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-load routes just in case the user wants to assign a route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD32F2F), // Match the Red color
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Sales Team',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'rep')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No Sales Reps found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a rep to see them here.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // We convert the Firestore document into our UserModel
              final rep = UserModel.fromMap(data, doc.id);

              return RepCard(
                rep: rep,
                onAssignRoute: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAssignRepScreen(rep: rep),
                    ),
                  );
                },
                onViewPerformance: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminRepPerformanceScreen(rep: rep),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
