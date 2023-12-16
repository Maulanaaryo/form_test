import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_tes/presentation/pages/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  bool isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
                  'Sign Up',
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

                Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          await _auth.createUserWithEmailAndPassword(
                            email: _emailController!.text.toString().trim(),
                            password: _passwordController!.text,
                          );

                          // print('Registration successful!');
                          // print('Email: ${_emailController!.text}');
                          // print('Password: ${_passwordController!.text}');

                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          Fluttertoast.showToast(
                            msg: e.message.toString(),
                            gravity: ToastGravity.TOP,
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Sign Up',
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
                                builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        "Sign In",
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
