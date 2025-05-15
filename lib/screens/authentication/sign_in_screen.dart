import 'package:flutter/material.dart';
import 'package:plan_pilot/screens/authentication/sign_up_screen.dart';
import 'package:provider/provider.dart';
import '../../components/custom_textfield';
import 'auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscurePassword = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          color: Colors.grey[200], // background color
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: FlutterLogo(
                              size: 72,
                            ), // Replace with your logo if needed
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
                                  vm.setLoginEmail(value);
                                },
                              ),
                              if (vm.loginEmailError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    vm.loginEmailError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              CustomTextField(
                                labelText: 'Password',
                                textEditingController: _passwordController,
                                isPassword: _obscurePassword,
                                inputAction: TextInputAction.done,
                                leftIcon: const Icon(Icons.lock_outline),
                                rightIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _obscurePassword =
                                                !_obscurePassword,
                                      ),
                                ),
                                onValueChange: (value) {
                                  vm.setLoginPassword(value);
                                },
                              ),
                              if (vm.loginPasswordError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    vm.loginPasswordError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              if (vm.authError != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    vm.authError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed:
                                      vm.isLoading
                                          ? null
                                          : () async {
                                            if (vm.validateLogin()) {
                                              final success = await vm.signIn();
                                              if (success && context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                          },
                                  child:
                                      vm.isLoading
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Login'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have account? "),
                              GestureDetector(
                                onTap:(){
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign up.',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
