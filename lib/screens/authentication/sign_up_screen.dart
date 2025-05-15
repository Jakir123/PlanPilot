import 'package:flutter/material.dart';
import 'package:plan_pilot/screens/authentication/sign_in_screen.dart';
import 'package:provider/provider.dart';
import '../../components/custom_textfield';
import 'auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) => Scaffold(
          body: Stack(
            children: [
              // Back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: ClipOval(
                    child: Material(
                      color: Colors.grey[200],
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(Icons.arrow_back, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: FlutterLogo(size: 72), // Replace with your logo if needed
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            labelText: 'Email',
                            textEditingController: _emailController,
                            inputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            leftIcon: const Icon(Icons.email_outlined),
                            onValueChange: (value) {
                              vm.setSignUpEmail(value);
                            },
                          ),
                          if (vm.signUpEmailError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(vm.signUpEmailError!, style: const TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 18),
                          CustomTextField(
                            labelText: 'Password',
                            textEditingController: _passwordController,
                            isPassword: _obscurePassword,
                            inputAction: TextInputAction.next,
                            leftIcon: const Icon(Icons.lock_outline),
                            rightIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            onValueChange: (value) {
                              vm.setSignUpPassword(value);
                            },
                          ),
                          if (vm.signUpPasswordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(vm.signUpPasswordError!, style: const TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 18),
                          CustomTextField(
                            labelText: 'Confirm Password',
                            textEditingController: _confirmPasswordController,
                            isPassword: _obscureConfirmPassword,
                            inputAction: TextInputAction.done,
                            leftIcon: const Icon(Icons.lock_outline),
                            rightIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            onValueChange: (value) {
                              vm.setSignUpConfirmPassword(value);
                            },
                          ),
                          if (vm.signUpConfirmPasswordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(vm.signUpConfirmPasswordError!, style: const TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 24),
                          if (vm.authError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(vm.authError!, style: const TextStyle(color: Colors.red)),
                            ),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      if (vm.validateSignUp()) {
                                        final success = await vm.signUp();
                                        if (success && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
