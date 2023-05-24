import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isRegister = false;

  final TextEditingController _conName = TextEditingController();
  final TextEditingController _conEmail = TextEditingController();
  final TextEditingController _conPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _conEmail.text,
        password: _conPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _conEmail.text,
        password: _conPassword.text,
      );

      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _conName.text,
          'email': _conEmail.text,
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text(
      'CRUD',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController con,
  ) {
    return TextField(
      controller: con,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _errorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        errorMessage == '' ? '' : 'Hmm? $errorMessage',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isRegister
          ? createUserWithEmailAndPassword
          : signInWithEmailAndPassword,
      child: Text(
        isRegister ? 'Register' : 'Login',
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _registerOrLoginButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isRegister = !isRegister;
        });
      },
      child: Text(
        isRegister ? 'Login' : 'Register',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 60),
            if (isRegister) _entryField('Name', _conName),
            SizedBox(height: 20),
            _entryField('Email', _conEmail),
            SizedBox(height: 20),
            _entryField('Password', _conPassword),
            SizedBox(height: 20),
            _errorMessage(),
            SizedBox(height: 20),
            _submitButton(),
            SizedBox(height: 10),
            _registerOrLoginButton(),
          ],
        ),
      ),
    );
  }
}
