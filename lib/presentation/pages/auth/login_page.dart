import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_tes/data/local_data.dart';
import 'package:mobile_tes/presentation/pages/auth/register_page.dart';
import 'package:mobile_tes/presentation/pages/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    checkAuth();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void checkAuth() async {
    final pref = SharedServices();
    String? token = await pref.getToken();
    if (token != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController!.dispose();
    _passwordController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(
                  height: 50.0,
                ),

                // Form Email
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 14),
                  child: TextFormField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email Cannot Be Empty!';
                      }
                      if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                          .hasMatch(value)) {
                        return ('Enter your email correctly!');
                      } else {
                        return null;
                      }
                    },
                  ),
                ),

                // Form Password
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'The password cannot be empty!';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      } else if (!RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])')
                          .hasMatch(value)) {
                        return 'The password must be numbers, uppercase and lowercase letters';
                      }
                      return null;
                    },
                  ),
                ),

                // Button Login
                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final pref = SharedServices();
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: _emailController!.text,
                            password: _passwordController!.text,
                          );
                          pref.saveToken('token');

                          if (mounted) {
                            Fluttertoast.showToast(
                                msg: 'Welcome',
                                backgroundColor: Colors.green,
                                gravity: ToastGravity.TOP);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Fluttertoast.showToast(
                                msg: 'Failed Email & Password',
                                backgroundColor: Colors.red,
                                gravity: ToastGravity.TOP);
                          }
                        }
                      }
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16, letterSpacing: 1.5),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
