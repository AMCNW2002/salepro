import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/rep_provider.dart';
import '../../../providers/route_provider.dart';

class AdminAssignRepScreen extends StatefulWidget {
  final UserModel rep;

  const AdminAssignRepScreen({super.key, required this.rep});

  @override
  State<AdminAssignRepScreen> createState() => _AdminAssignRepScreenState();
}

class _AdminAssignRepScreenState extends State<AdminAssignRepScreen> {
  String? _selectedRouteId;

  @override
  void initState() {
    super.initState();
    _selectedRouteId = widget.rep.routeId;
  }

  void _assignRoute() async {
    if (_selectedRouteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a route first.')),
      );
      return;
    }

    final success = await context.read<RepProvider>().assignRouteToRep(
      widget.rep.uid,
      _selectedRouteId!,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route assigned to Rep successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<RepProvider>().errorMessage ?? 'Failed to assign route.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Route to ${widget.rep.name}'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rep: ${widget.rep.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Email: ${widget.rep.email}'),
                const SizedBox(height: 8),
                Text(
                  'Current Route ID: ${widget.rep.routeId.isNotEmpty ? widget.rep.routeId : 'Unassigned'}',
                  style: TextStyle(
                    color: widget.rep.routeId.isNotEmpty ? Colors.blue.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<RouteProvider>(
              builder: (context, routeProvider, child) {
                if (routeProvider.isLoading && routeProvider.routes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (routeProvider.routes.isEmpty) {
                  return const Center(child: Text('No routes available. Please create routes first.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: routeProvider.routes.length,
                  itemBuilder: (context, index) {
                    final route = routeProvider.routes[index];
                    final isSelected = _selectedRouteId == route.routeId;

                    return Card(
                      color: isSelected ? Colors.red.shade50 : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? Colors.red.shade800 : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedRouteId = route.routeId;
                          });
                        },
                        leading: Icon(
                          Icons.map,
                          color: isSelected ? Colors.red.shade800 : Colors.grey,
                        ),
                        title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(route.description),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.red.shade800)
                            : const Icon(Icons.radio_button_unchecked),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: context.watch<RepProvider>().isLoading ? null : _assignRoute,
                icon: context.watch<RepProvider>().isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.save),
                label: const Text('Save Assignment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
