import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class StaffRegisterScreen extends StatefulWidget {
  final String role; // 'rep' or 'admin'
  const StaffRegisterScreen({super.key, required this.role});

  @override
  State<StaffRegisterScreen> createState() => _StaffRegisterScreenState();
}

class _StaffRegisterScreenState extends State<StaffRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
        ownerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        shopName: '', // Staff doesn't need a shop name
        shopAddress: '', // Staff doesn't need a shop address
        role: widget.role,
      );

      if (success && mounted) {
        // Pop screen to go back or auth wrapper will handle navigation automatically
        Navigator.pop(context); // close this screen
        Navigator.pop(context); // close customer register screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayRole = widget.role == 'rep' ? 'Rep' : 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('Create $displayRole Account'),
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
                    Text(
                      'Register as $displayRole',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please fill the details below to register a staff account.',
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
                      controller: _nameController,
                      labelText: 'Full Name',
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
                        if (!value.trim().endsWith('@m.lk')) {
                          return 'Staff must use an @m.lk email';
                        }
                        return null;
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
                      text: 'CREATE ACCOUNT',
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
