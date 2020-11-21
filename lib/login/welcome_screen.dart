import 'package:best_flutter_ui_templates/login/login_with_phone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../app_theme.dart';
import '../navigation_home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  FirebaseUser loggedInUser;
  bool showSpinner = false;
  bool showLogInButton = false;

  @override
  void initState() {
    setState(() {
      showSpinner = false;
      print(showSpinner);
    });
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        final userProfile = await _firestore
            .collection('user_profile')
            .where("user_id", isEqualTo: loggedInUser.uid)
            .getDocuments();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        //save user data in to local storage
        var firstName = userProfile.documents[0].data['first_name'];
        var lastName = userProfile.documents[0].data['last_name'];
        var profileImg = userProfile.documents[0].data['profileImg'];

        prefs.setString('fistName', firstName);
        prefs.setString('lastName', lastName);
        prefs.setString('profileImg', profileImg);

        if (userProfile.documents.length > 0) {
          print(userProfile.documents.length);
        } else {
          print('no user exist');
        }

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
            (Route<dynamic> route) => false);
        setState(() {
          showSpinner = false;
        });
        print(loggedInUser.phoneNumber);
      } else {
        setState(() {
          showSpinner = false;
          print(showSpinner);
          showLogInButton = true;
        });
        // Toast.show('Something is wrong', context,
        //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

        showLogInButton = true;
      }
    } catch (e) {
      Toast.show('Something is wrong', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

      showLogInButton = true;
    }
  }

  // void getUserProfile() async {
  //   final userProfile = await _firestore
  //       .collection('user_profile')
  //       .where('user_id' == 'S9myWXb1JHZw1mLqCIouyYMfTmG2')
  //       .getDocuments();

  //   for (var userProfile in userProfile.documents) {
  //     print(userProfile.data);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: Center(
                    // heightFactor: 0.2,
                    child: Image.asset(
                      'assets/images/Kalonish002.png',
                      color: AppTheme.appBar,
                      height: MediaQuery.of(context).size.height * 0.12,
                    ),
                  ),
                  // height: MediaQuery.of(context).size.height * 0.12,
                  // width: 100,
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: showLogInButton == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.btnColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.8),
                                    offset: const Offset(4, 4),
                                    blurRadius: 8.0),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, LoginPhoneScreen.id);
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Sign In / Sign Up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ),
              SizedBox(
                height: 25,
              )
            ],
          ),
        ),
      ),
    );
  }
}
