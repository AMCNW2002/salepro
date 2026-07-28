import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../../widgets/primary_button.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart';

class AdminAddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const AdminAddProductScreen({super.key, this.productToEdit});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _minStockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name);
    _priceController = TextEditingController(text: widget.productToEdit?.price.toString());
    _stockController = TextEditingController(text: widget.productToEdit?.stock.toString() ?? '0');
    _categoryController = TextEditingController(text: widget.productToEdit?.category ?? 'General'); 
    _minStockController = TextEditingController(text: widget.productToEdit?.minStock.toString() ?? '10');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final productProvider = context.read<ProductProvider>();
      
      final newProduct = ProductModel(
        productId: widget.productToEdit?.productId ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        minStock: int.tryParse(_minStockController.text.trim()) ?? 5,
        active: widget.productToEdit?.active ?? true,
      );

      bool success = false;
      if (widget.productToEdit == null) {
        success = await productProvider.addProduct(newProduct);
      } else {
        success = await productProvider.updateProduct(newProduct);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product saved successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(productProvider.errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productToEdit == null ? 'Add Product' : 'Edit Product'),
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
                labelText: 'Product Name',
                prefixIcon: Icons.inventory_2,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _categoryController,
                labelText: 'Category',
                prefixIcon: Icons.category,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                labelText: 'Price',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      labelText: 'Initial Stock',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _minStockController,
                      labelText: 'Minimum Stock',
                      prefixIcon: Icons.warning_amber,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return PrimaryButton(
                    text: provider.isLoading ? 'Saving...' : 'Save Product',
                    onPressed: provider.isLoading ? null : () => _saveProduct(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
