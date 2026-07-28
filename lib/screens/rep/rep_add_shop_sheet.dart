import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/shop_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

class RepAddShopSheet extends StatefulWidget {
  final String routeId;

  const RepAddShopSheet({super.key, required this.routeId});

  @override
  State<RepAddShopSheet> createState() => _RepAddShopSheetState();
}

class _RepAddShopSheetState extends State<RepAddShopSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

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
      setState(() => _isLoading = true);
      try {
        final success = await context.read<ShopProvider>().createShop(
              name: _nameController.text.trim(),
              owner: _ownerController.text.trim(),
              address: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
              routeId: widget.routeId,
            );
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shop created and added to your route!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.read<ShopProvider>().errorMessage ?? 'Failed to add shop'), backgroundColor: Colors.red),
            );
          }
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Shop',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Shop Name',
                prefixIcon: Icons.store,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _ownerController,
                labelText: 'Owner Name',
                prefixIcon: Icons.person,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                prefixIcon: Icons.location_on,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Create & Assign to Route',
                      onPressed: _saveShop,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
