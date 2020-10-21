import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  String _email;
  GlobalKey<FormState> _form = GlobalKey<FormState>();
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
                      "Lupa Password",
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
                          onSaved: (v) {
                            _email = v;
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
                      height: 20,
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      minWidth: double.infinity,
                      height: 60,
                      child: (_isLoading)
                          ? CircularProgressIndicator()
                          : Text(
                              "PROSES",
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
                            await UserServices.auth
                                .sendPasswordResetEmail(email: _email);
                            Alert(
                              context: context,
                              title: "Sukses",
                              desc:
                                  "Cek email anda, untuk mendapatkan link reset password",
                              type: AlertType.success,
                              closeFunction: () {
                                Get.back();
                                Get.back();
                              },
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Tutup",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Get.back();
                                  },
                                  width: 120,
                                )
                              ],
                            ).show();
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            Alert(
                              context: context,
                              title: "Gagal",
                              desc: "Cek email terlebih dahulu",
                              type: AlertType.error,
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Tutup",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                  width: 120,
                                )
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
