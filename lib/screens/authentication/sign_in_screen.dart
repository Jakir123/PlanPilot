import 'package:flutter/material.dart';
import 'package:plan_pilot/screens/authentication/sign_up_screen.dart';
import 'package:provider/provider.dart';
import '../../components/custom_textfield';
import 'auth_viewmodel.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showSignUp;
  final bool isDark;

  const SignInScreen({
    super.key,
    required this.showSignUp,
    required this.isDark,
  });

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
      builder:
          (context, vm, _) => Scaffold(
            body: Center(
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Use your credentials to authorize',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          labelText: 'Email',
                          hintText: "Enter your email",
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
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              vm.loginEmailError!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          labelText: 'Password',
                          hintText: "Enter your password",
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
                              _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          onValueChange: (value) {
                            vm.setLoginPassword(value);
                          },
                        ),
                        if (vm.loginPasswordError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
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
                                // if (success && context.mounted) {
                                //   widget.onSignIn();
                                // }
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
                                : const Text('Sign In'),
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
                          onTap: () {
                            widget.showSignUp();
                          },
                          child: Text(
                            'Sign up.',
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
          ),
    );
  }


}
