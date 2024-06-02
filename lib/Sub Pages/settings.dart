import 'package:BudgetBuddies/Components/profileFormField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _username = TextEditingController();
  final _pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20,),
              const Text('Profile', style: TextStyle(
                fontSize: 20,
              )),
              const SizedBox(height: 20,),
              profileformfield(
                labelName: "Username",
                controller: _username,
                hintText: (FirebaseAuth.instance.currentUser!.displayName != null) ? '${FirebaseAuth.instance.currentUser!.displayName}' : 'Enter Username',
                obscureText: false,
              ),
              const SizedBox(height: 20,),
              profileformfield(
                labelName: "Password",
                controller: _pwd,
                hintText: '********',
                obscureText: true,
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(double.maxFinite, 75)),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  backgroundColor: WidgetStateProperty.all(Colors.black),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                onPressed: () {
                  DatabaseReference ref = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/');
                  if(_username.text.isNotEmpty) {
                    FirebaseAuth.instance.currentUser!.updateDisplayName(_username.text);
                    ref.update({
                      'username': _username.text
                    });
                  }
                  if(_pwd.text.isNotEmpty) {
                    FirebaseAuth.instance.currentUser!.updatePassword(_pwd.text);
                  }
                  showDialog(
                    context: context,
                    builder: (context) {
                      if(_username.text.isNotEmpty || _pwd.text.isNotEmpty) {
                        return const AlertDialog(
                          contentPadding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          content: Text('Profile Updated'),
                        );
                      }
                      else {
                        return const AlertDialog(
                          contentPadding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          content: Text('No changes have been made!'),
                        );
                      }
                    },
                  );
                },
                child: const Text('Update Profile'),
              ),
              const SizedBox(height: 20,),
              const Text(
                'Your Current Location',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              // Here you can add the map widget or any other location-related functionality.
              // For demonstration purposes, I'm adding a simple placeholder widget.
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    'Map Placeholder',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to share location here.
                },
                style: ButtonStyle(
                  fixedSize: WidgetStateProperty.all(const Size(double.maxFinite, 50)),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  backgroundColor: WidgetStateProperty.all(Colors.black),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text('Share Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
