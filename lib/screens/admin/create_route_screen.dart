import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/route_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

class CreateRouteScreen extends StatefulWidget {
  final String? routeId;
  final String? initialName;
  final String? initialDescription;

  const CreateRouteScreen({
    super.key,
    this.routeId,
    this.initialName,
    this.initialDescription,
  });

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveRoute() async {
    if (_formKey.currentState!.validate()) {
      final routeProvider = context.read<RouteProvider>();
      final isEditing = widget.routeId != null;
      
      bool success;
      if (isEditing) {
        success = await routeProvider.updateRoute(
          routeId: widget.routeId!,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
        );
      } else {
        success = await routeProvider.createRoute(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
        );
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Route updated successfully!' : 'Route created successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routeId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Route' : 'Create New Route'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.map, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Route Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Route Name (e.g. Colombo 03)',
                prefixIcon: Icons.route,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a route name';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _descController,
                labelText: 'Description (Optional)',
                prefixIcon: Icons.description,
                // maxLines: 3, // CustomTextField might not support maxLines easily if it's not passed down, but let's assume it doesn't break. 
                // Actually CustomTextField doesn't have maxLines defined. I will omit it.
              ),
              const SizedBox(height: 32),
              Consumer<RouteProvider>(
                builder: (context, routeProvider, _) {
                  return PrimaryButton(
                    text: isEditing ? 'UPDATE ROUTE' : 'CREATE ROUTE',
                    isLoading: routeProvider.isLoading,
                    onPressed: _saveRoute,
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
