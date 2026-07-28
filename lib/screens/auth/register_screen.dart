import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/route_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'staff_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRouteId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure routes are loaded
      if (context.read<RouteProvider>().routes.isEmpty) {
        // Accessing the provider will trigger fetch if not already done, 
        // but RouteProvider constructor already calls _fetchRoutes.
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final authProvider = context.read<AuthProvider>();
      
      bool success = await authProvider.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopAddress: _addressController.text.trim(),
        role: 'customer',
        routeId: _selectedRouteId,
      );

      if (success && mounted) {
        // Pop register screen to go back or auth wrapper will handle navigation automatically
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffRegisterScreen(role: value),
                ),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'rep',
                child: Text('Register as Rep'),
              ),
              const PopupMenuItem<String>(
                value: 'admin',
                child: Text('Register as Admin'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Join SalePro',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please fill the details below to register your shop.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Error Message
                    if (authProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),

                    CustomTextField(
                      controller: _shopNameController,
                      labelText: 'Shop Name',
                      prefixIcon: Icons.store,
                      validator: (value) => 
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    CustomTextField(
                      controller: _ownerNameController,
                      labelText: 'Owner Name',
                      prefixIcon: Icons.person,
                      validator: (value) => 
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => 
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Shop Address',
                      prefixIcon: Icons.location_on,
                      validator: (value) => 
                          value == null || value.isEmpty ? 'Required' : null,
                    ),

                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    // Route Selection Dropdown
                    Consumer<RouteProvider>(
                      builder: (context, routeProvider, _) {
                        if (routeProvider.isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Route',
                              prefixIcon: const Icon(Icons.map),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            value: _selectedRouteId.isEmpty ? null : _selectedRouteId,
                            items: routeProvider.routes.map((route) {
                              return DropdownMenuItem(
                                value: route.routeId,
                                child: Text(route.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRouteId = value ?? '';
                              });
                            },
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Please select a route' : null,
                          ),
                        );
                      },
                    ),

                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    PrimaryButton(
                      text: 'REGISTER',
                      isLoading: authProvider.isActionLoading,
                      onPressed: _register,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
