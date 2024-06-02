import 'package:BudgetBuddies/Components/customFormField.dart';
import 'package:BudgetBuddies/Services/sign_in_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  final Function() onTap;
  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  void login() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text, password: _password.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'invalid-credential') {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Invalid Credentials!'),
                content: const Text('Please enter valid email and password'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              );
            });
      }
    }
  }

  void resetPassword() async {
    if (_email.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
              const Text('Please enter your email to reset password'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            );
          });
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text);
      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Password Reset'),
              content:
              const Text('Password reset link has been sent to your email'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            );
          });
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred. Please try again later.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            );
          });
    }
  }

  void signInWithGoogle() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      final user = await SignInWithGoogle().signInWithGoogle();
      Navigator.pop(context);

      if (user != null) {
        // Do something with the signed-in user if needed
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred. Please try again later.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            );
          });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),

                const Image(
                  image: AssetImage('lib/assets/ic_launcher.png'),
                  width: 150,
                ),

                const SizedBox(height: 25),

                const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),

                const SizedBox(
                  height: 50,
                ),

                customFormField(
                  hintText: 'Email',
                  controller: _email,
                  obscureText: false,
                ),

                const SizedBox(
                  height: 10,
                ),

                customFormField(
                  hintText: 'Password',
                  controller: _password,
                  obscureText: true,
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: resetPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        const Size(double.maxFinite, 75)),
                    backgroundColor:
                    MaterialStateProperty.all(Colors.black),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'or Continue with',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                GestureDetector(
                  onTap: signInWithGoogle,
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(8.0)),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: const Row(
                        children: [
                          Image(
                            image: AssetImage('lib/assets/google.png'),
                            width: 70,
                            height: 70,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                                color: Colors.black, fontSize: 18),
                          ),
                        ],
                      )),
                ),

                const SizedBox(
                  height: 25,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a registered user?',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w900),
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
