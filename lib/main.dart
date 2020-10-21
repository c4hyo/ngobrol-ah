import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ngobrol_ah/network/model/user_model.dart';
import 'package:ngobrol_ah/network/services/user.dart';
import 'package:ngobrol_ah/view/screen/auth/login.dart';
import 'package:ngobrol_ah/view/screen/home/home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting('id_ID', null).then(
    (_) => runApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: UserServices.checkUser,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Ngobrol Kuy",
        theme: ThemeData(
          primaryColor: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.latoTextTheme(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Wrapper(),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return (user == null)
        ? LoginScreen()
        : FutureBuilder<DocumentSnapshot>(
            future: UserServices.getProfil(user.uid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                  body: SafeArea(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              UserModel model = UserModel.toMaps(snapshot.data);
              return Home(
                user: user,
                userModel: model,
              );
            },
          );
  }
}
