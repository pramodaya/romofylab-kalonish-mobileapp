import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:best_flutter_ui_templates/hotel_booking/hotel_home_screen.dart';
import 'package:best_flutter_ui_templates/login/model/person_data.dart';
import 'package:best_flutter_ui_templates/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';

import '../app_theme.dart';
import '../navigation_home_screen.dart';

class PersonRegistration extends StatefulWidget {
  static const String id = 'person_registration';
  @override
  _PersonRegistrationState createState() => _PersonRegistrationState();
}

class _PersonRegistrationState extends State<PersonRegistration> {
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  String firstName;
  String lastName;
  String email;
  String address;
  String nic;

  bool isFirstNameValidated = true;
  bool isLastNameValidated = true;
  bool isEmailValidated = true;
  bool isAddressValidated = true;
  bool isNicValidated = true;

  FirebaseUser loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void validateEmailAddress() {
    Pattern pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = new RegExp(pattern);
    var x = email;
    if (email == null || email.isEmpty) {
      setState(() {
        isEmailValidated = false;
      });
    } else {
      if (regex.hasMatch(email)) {
        setState(() {
          isEmailValidated = true;
        });
      } else {
        setState(() {
          isEmailValidated = false;
        });
      }
    }
  }

  bool validateAllField() {
    validateEmailAddress();

    if (firstName == null || firstName.isEmpty) {
      setState(() {
        isFirstNameValidated = false;
      });
    } else {
      setState(() {
        isFirstNameValidated = true;
      });
    }

    if (lastName == null || lastName.isEmpty) {
      setState(() {
        isLastNameValidated = false;
      });
    } else {
      setState(() {
        isLastNameValidated = true;
      });
    }

    if (nic == null || nic.isEmpty) {
      setState(() {
        isNicValidated = false;
      });
    } else {
      setState(() {
        isNicValidated = true;
      });
    }

    if (isFirstNameValidated &&
        isLastNameValidated &&
        isNicValidated &&
        isEmailValidated) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 1,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.left,
                      onChanged: (value) {
                        setState(() {
                          firstName = value;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: AppTheme.btnColor,
                        ),
                        hintText: 'First Name',
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 2.0),
                        ),
                        errorText: isFirstNameValidated
                            ? null
                            : 'First name can\'t be empty',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.left,
                      onChanged: (value) {
                        setState(() {
                          lastName = value;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.person,
                          color: AppTheme.btnColor,
                        ),
                        hintText: 'Enter your last Name',
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 2.0),
                        ),
                        errorText: isLastNameValidated
                            ? null
                            : 'Last name can\'t be empty',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.left,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.email,
                          color: AppTheme.btnColor,
                        ),
                        hintText: 'Enter your email address',
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 2.0),
                        ),
                        errorText: isEmailValidated
                            ? null
                            : 'Enter a valid email address',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      onChanged: (value) {
                        setState(() {
                          nic = value;
                        });
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.receipt,
                          color: AppTheme.btnColor,
                        ),
                        hintText: 'NIC',
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 1.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.btnColor, width: 2.0),
                        ),
                        errorText: isNicValidated
                            ? null
                            : 'NIC number can\'t be empty',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
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
                          var isVaidated = validateAllField();

                          if (isVaidated) {
                            PersonData p1 = PersonData(
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                nic: nic,
                                phone: loggedInUser.phoneNumber,
                                userId: loggedInUser.uid,
                                userType: 'customer',
                                isVerified: true);

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(p1)),
                                (Route<dynamic> route) => false);
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Sign Up',
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
              ),
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ),
    );
  }
}
