import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_series/screens/phone_auth/otp_verify_screen.dart';
import 'package:flutter/material.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  void sendOtp() async {
    String phoneNumber = phoneNumberController.text.trim();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: (verificationId, forceResendingToken) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(
                      verificationId: verificationId,
                    )));
      },
      verificationCompleted: (credential) {},
      verificationFailed: (ex) {
        print('Error: ${ex.code.toString()}');
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: Duration(seconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number Login"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Enter your phone number",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  sendOtp();
                },
                child: Text("Log In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
