import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:swarn_abhushan/screens/home_screen.dart';
import 'package:swarn_abhushan/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends ConsumerState<LoginScreen> {
  late FormGroup loginForm;
  late AuthService authService;
  late bool _isVisible = false;
  late bool _isRequesting = false;

  Future<void> _submit() async {
    if (loginForm.valid) {
      setState(() => _isRequesting = true);
      try {
        final response = await authService.login(loginForm.value);
        if(!mounted) return;
        if(response != null) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } catch (e) {
        //
      } finally {
        setState(() => _isRequesting = false);
      }
    } else {
      loginForm.markAllAsTouched();
    }
  }

  @override
  void initState() {
    super.initState();
    loginForm = FormGroup({
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6), Validators.maxLength(30)],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    authService = AuthService(ref);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // minHeight: constraints.maxHeight,
            ),
            child: SafeArea(
              child: ReactiveForm(
                formGroup: loginForm,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12.0,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withAlpha(115),
                          width: 2.0,
                        ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        //     blurRadius: 10,
                        //     spreadRadius: 2,
                        //   ),
                        // ],
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0
                          ]),
                          child: Image.asset('assets/logos/swarn_aabhushan_1.png', fit: BoxFit.cover, height: 120, width: 120,),
                        ),
                      ),
                    ),
                    const Text(
                      'Your Digital Bullion Register',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Where Trust Meets Gold.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary, 
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ReactiveTextField<String>(
                      formControlName: 'email',
                      decoration: InputDecoration(labelText: 'Email'),
                      validationMessages: {
                        ValidationMessage.required: (error) => 'Email is required',
                        ValidationMessage.email: (error) => 'Enter a valid email address',
                      },
                    ),
                    ReactiveTextField<String>(
                      formControlName: 'password',
                      decoration: InputDecoration(
                        labelText: 'Password', 
                        suffixIcon: IconButton(onPressed: () => setState(() => _isVisible = !_isVisible), icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off)),
                      ),
                      
                      obscureText: !_isVisible,
                      maxLength: 30,
                      validationMessages: {
                        ValidationMessage.required: (error) => 'Password is required',
                        ValidationMessage.minLength: (error) => 'Password must be at least 6 characters',
                      },
                    ),
                    const SizedBox(height: 10),
                    ReactiveFormConsumer(builder: (context, formGroup, child) {
                      final isDisabled = loginForm.invalid || _isRequesting;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isDisabled ? null : _submit,
                          icon: _isRequesting ? SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white,),
                          ) : Icon(Icons.login),
                          label: Text(_isRequesting ? 'Loggin in...' : 'Login', style: TextStyle(letterSpacing: 1.0),),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(50)
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}