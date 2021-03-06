import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegistrasiScreen extends StatefulWidget {
  @override
  _RegistrasiScreenState createState() => _RegistrasiScreenState();
}

class _RegistrasiScreenState extends State<RegistrasiScreen> {
  bool _isLoading = false;
  String _email, _password, _nama;
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  FirebaseMessaging fcm = new FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 150,
                      width: 150,
                      child: Center(
                        child: Image(
                          image: AssetImage("asset/logo.png"),
                        ),
                      ),
                    ),
                    Text(
                      "NGOBROL KUY",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Registrasi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      color: Colors.grey[100],
                      elevation: 0.5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (newValue) {
                            _nama = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Nama harus di isi";
                            }

                            return null;
                          },
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Nama",
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Colors.grey[100],
                      elevation: 0.5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (newValue) {
                            _email = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Email harus di isi";
                            }
                            if (!EmailValidator.validate(value)) {
                              return "Format email salah";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Colors.grey[100],
                      elevation: 0.5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextFormField(
                          onSaved: (newValue) {
                            _password = newValue;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Password harus di isi";
                            }
                            return null;
                          },
                          obscureText: true,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      minWidth: double.infinity,
                      height: 60,
                      child: (_isLoading)
                          ? CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                          : Text(
                              "REGISTRASI",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                      onPressed: () async {
                        if (_form.currentState.validate()) {
                          _form.currentState.save();
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await UserServices.signup(
                              email: _email,
                              password: _password,
                              nama: _nama,
                              token: await fcm.getToken(),
                            );
                            Get.back();
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            Alert(
                              context: context,
                              title: "Gagal Registrasi",
                              type: AlertType.error,
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Tutup",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  color: Colors.red,
                                ),
                              ],
                            ).show();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
