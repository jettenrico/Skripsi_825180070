import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:harusnyabisa/screens/landing.dart';
import 'package:harusnyabisa/screens/register.dart';
import 'package:harusnyabisa/utility/repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var name = preferences.getString('namauser');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: name == null ? WelcomePage() : HomePage(),
    themeMode: ThemeMode.light,
  ));
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Colors.blue.shade100, Colors.blue.shade400])),
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "Welcome",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Automatic identity verification which enables you to verify your identity",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/loginimage.png'))),
          ),
          Column(
            children: <Widget>[
              MaterialButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                height: 45,
                color: Colors.black,
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupPage()));
                },
                height: 45,
                color: Colors.grey,
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}

Url listurl = Url();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '', password = '';
  bool _secureText = true;
  TextEditingController uname = TextEditingController();
  TextEditingController pass = TextEditingController();
  final _key = new GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      print("$username, $password, ");
      login();
    }
  }

  showPassword() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  Future login() async {
    var response = await http.post(Uri.parse(listurl.ceklogin), body: {
      "username": username,
      "password": generateMd5(password),
    });

    var data = json.decode(response.body);
    var tipeUser = data['tipeuser'];
    var nama = data['user_fullname'];
    var userNumber = data['user_number'];
    var userNik = data['user_nik'];
    var resp = data['message'];
    var email = data['user_email'];
    var phone = data['user_phone'];

    if (resp == "Success") {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('namauser', nama);
      preferences.setString('usernumber', userNumber);
      preferences.setString('tipeuser', tipeUser);
      preferences.setString('usernik', userNik);
      preferences.setString('useremail', email);
      preferences.setString('userphone', phone);
      preferences.setString('pass', password);

      Fluttertoast.showToast(
          msg: "Selamat Datang " + nama + "!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: "Login Gagal!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Colors.blue.shade100, Colors.blue.shade400])),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Login to your account",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _key,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: uname,
                            validator: (e) {
                              if (e!.isEmpty) {
                                return "Username Tidak Boleh Kosong!";
                              }
                            },
                            onSaved: (e) => username = e!,
                            textInputAction: TextInputAction.next,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black54,
                              ),
                              labelText: "Username",
                              labelStyle: TextStyle(color: Colors.black54),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.00)),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: pass,
                            validator: (e) {
                              if (e!.isEmpty) {
                                return "Password Tidak Boleh Kosong!";
                              }
                            },
                            onSaved: (e) => password = e!,
                            obscureText: _secureText,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.black54,
                              ),
                              suffixIcon: IconButton(
                                onPressed: showPassword,
                                icon: Icon(_secureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.black54),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8.00)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LupaPassword()));
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () {
                      check();
                      // login();
                    },
                    height: 45,
                    color: Colors.black,
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignupPage()));
                        },
                        child: Text(
                          " Sign Up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
