import 'package:best_flutter_ui_templates/login/person_registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../navigation_home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  OTPScreen({Key key, @required this.verificationId}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _codeController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  final _firestore = Firestore.instance;

  void returnErrorMsg(String errorMsg) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Container(
          child: AlertDialog(
            title: Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$errorMsg',
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                textColor: Colors.black,
                color: AppTheme.btnColor,
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              child: Container(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 50, right: 50),
                    child: TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        // setState(() {
                        //   mobileNum = value;
                        // });
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Text is empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.phone_iphone,
                          color: AppTheme.btnColor,
                        ),
                        hintText: 'Enter the OTP code',
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
                        // errorText: mobileNumIsValidated
                        //     ? null
                        //     : 'Mobile number can\'t be empty',
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
                        onTap: () async {
                          try {
                            final code = _codeController.text.trim();
                            AuthCredential credential =
                                PhoneAuthProvider.getCredential(
                              verificationId: widget.verificationId,
                              smsCode: code,
                            );

                            AuthResult result =
                                await _auth.signInWithCredential(credential);

                            FirebaseUser user = result.user;

                            if (user != null) {
                              // Navigator.of(context).pop();
                              final userProfile = await _firestore
                                  .collection('user_profile')
                                  .where("user_id", isEqualTo: user.uid)
                                  .getDocuments();

                              // var phonenum = user.phoneNumber;
                              // print('user manually registerd: $phonenum');

                              if (userProfile.documents.length > 0) {
                                if (userProfile.documents[0].data['userType'] ==
                                    'customer') {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  //save user data in to local storage
                                  var firstName = userProfile
                                      .documents[0].data['first_name'];
                                  var lastName = userProfile
                                      .documents[0].data['last_name'];
                                  var nic =
                                      userProfile.documents[0].data['nic'];
                                  var profileImg = userProfile
                                      .documents[0].data['profileImg'];

                                  prefs.setString('fistName', firstName);
                                  prefs.setString('lastName', lastName);
                                  prefs.setString('nic', nic);
                                  prefs.setString('profileImg', profileImg);

                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NavigationHomeScreen()),
                                      (Route<dynamic> route) => false);
                                } else {
                                  //ur not a customer - cant create 2 accounts by same mobile number
                                  returnErrorMsg('OTP code was wrong');
                                }
                              } else {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PersonRegistration()),
                                    (Route<dynamic> route) => false);
                              }
                            } else {
                              returnErrorMsg(
                                  'something is wrong... Try Again...');
                            }
                          } catch (e) {}
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Continue",
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
