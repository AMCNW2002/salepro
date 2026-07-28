import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../providers/route_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../models/shop_model.dart';

class AdminAddShopScreen extends StatefulWidget {
  final ShopModel? shopToEdit;

  const AdminAddShopScreen({super.key, this.shopToEdit});

  @override
  State<AdminAddShopScreen> createState() => _AdminAddShopScreenState();
}

class _AdminAddShopScreenState extends State<AdminAddShopScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedRouteId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shopToEdit?.name);
    _ownerController = TextEditingController(text: widget.shopToEdit?.owner);
    _phoneController = TextEditingController(text: widget.shopToEdit?.phone);
    _addressController = TextEditingController(
      text: widget.shopToEdit?.address,
    );
    _selectedRouteId = widget.shopToEdit?.routeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRouteId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a route')));
        return;
      }

      final shopProvider = context.read<ShopProvider>();

      try {
        if (widget.shopToEdit != null) {
          // Update shop
          await shopProvider.updateShop(
            shopId: widget.shopToEdit!.shopId,
            name: _nameController.text.trim(),
            owner: _ownerController.text.trim(),
            phone: _phoneController.text.trim(),
            address: _addressController.text.trim(),
            routeId: _selectedRouteId!,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shop updated successfully')),
            );
            Navigator.pop(context);
          }
        } else {
          // Add shop
          await shopProvider.createShop(
            name: _nameController.text.trim(),
            owner: _ownerController.text.trim(),
            address: _addressController.text.trim(),
            phone: _phoneController.text.trim(),
            routeId: _selectedRouteId!,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shop added successfully')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopToEdit == null ? 'Add Shop' : 'Edit Shop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Shop Name',
                prefixIcon: Icons.store,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _ownerController,
                labelText: 'Owner Name',
                prefixIcon: Icons.person,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                prefixIcon: Icons.location_on,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Consumer<RouteProvider>(
                builder: (context, routeProvider, child) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Route',
                      prefixIcon: const Icon(Icons.map),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    initialValue: _selectedRouteId,
                    items: routeProvider.routes.map((route) {
                      return DropdownMenuItem(
                        value: route.routeId,
                        child: Text(route.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedRouteId = val;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(text: 'Save Shop', onPressed: _saveShop),
            ],
          ),
        ),
      ),
    );
  }
}
