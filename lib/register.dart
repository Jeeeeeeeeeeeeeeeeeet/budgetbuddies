import 'package:Budget_Buddies/Components/custom_form_field.dart';
import 'package:Budget_Buddies/Services/sign_in_with_google.dart';
import 'package:Budget_Buddies/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class Register extends StatefulWidget {
  final void Function()? onTap;
  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _cpassword = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref('users');

  void signup() async{

    showDialog(context: context, builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });

    try{
      if(_password.text == _cpassword.text){
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.text,
            password: _password.text
        );
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }else {
        Navigator.pop(context);
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Password and Confirm Password do not match'),
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
    } on FirebaseAuthException catch(e){
      Navigator.pop(context);
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(e.message.toString()),
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
    _cpassword.dispose();
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
                const SizedBox(height: 50,),

                const Image(image: AssetImage('lib/assets/ic_launcher.png'), width: 150, ),

                const SizedBox(height: 25),

                const Text('Welcome to Budget Buddies!', style: TextStyle(fontSize: 16, color: Colors.black),),

                const SizedBox(height: 50,),

                CustomFormField(hintText: 'Email', controller: _email, obscureText: false,),

                const SizedBox(height: 10,),

                CustomFormField(hintText: 'Password', controller: _password, obscureText: true,),

                const SizedBox(height: 10,),

                CustomFormField(hintText: 'Confirm Password', controller: _cpassword, obscureText: true,),

                const SizedBox(height: 25,),

                ElevatedButton(
                  onPressed: () {
                    signup();
                  },
                  style: ButtonStyle(
                    fixedSize: WidgetStateProperty.all(const Size(double.maxFinite, 75)),
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 20),),
                ),

                const SizedBox(height: 25,),

                Row(
                  children: [
                    Expanded(child:
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade800,
                    ),
                    ),
                    const SizedBox(width: 5,),
                    Text('or Continue with', style: TextStyle(color: Colors.grey.shade800),),
                    const SizedBox(width: 5,),
                    Expanded(child:
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade800,
                    ),
                    ),
                  ],
                ),

                const SizedBox(height: 25,),

                GestureDetector(
                  onTap: () {
                    SignInWithGoogle().signInWithGoogle();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: const Row(
                        children: [
                          Image(image: AssetImage('lib/assets/google.png'), width: 70, height: 70,),
                          SizedBox(width: 20,),
                          Text('Sign in with Google', style: TextStyle(color: Colors.black, fontSize: 18),),
                        ],
                      )
                  ),
                ),

                const SizedBox(height: 25,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: Colors.black),),
                    const SizedBox(width: 5,),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900),
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