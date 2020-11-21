import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:best_flutter_ui_templates/login/otp_screen.dart';
import 'package:best_flutter_ui_templates/login/person_registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:best_flutter_ui_templates/help_screen.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../navigation_home_screen.dart';

class LoginPhoneScreen extends StatefulWidget {
  static const String id = 'login_phone_screen';

  @override
  _LoginPhoneScreenState createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _firestore = Firestore.instance;

  final _phoneContrller = TextEditingController();
  final _codeController = TextEditingController();
  String mobileNum;
  bool mobileNumIsValidated = true;

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

  Future<bool> loginUser(String phone, BuildContext context) async {
    final _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        // Navigator.of(context).pop();
        AuthResult result = await _auth.signInWithCredential(credential);
        FirebaseUser user = result.user;
        if (user != null) {
          //if user is a new user -> show the prson-registration page
          final userProfile = await _firestore
              .collection('user_profile')
              .where("user_id", isEqualTo: user.uid)
              .getDocuments();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          //save user data in to local storage

          var phonenum = user.phoneNumber;
          print(
              'user automatically registerd:-------------------------------------------------------------------------- $phonenum');

          if (userProfile.documents.length > 0) {
            if (userProfile.documents[0].data['userType'] == 'customer') {
              var firstName = userProfile.documents[0].data['first_name'];
              var lastName = userProfile.documents[0].data['last_name'];
              var nic = userProfile.documents[0].data['nic'];
              var profileImg = userProfile.documents[0].data['profileImg'];

              prefs.setString('fistName', firstName);
              prefs.setString('lastName', lastName);
              prefs.setString('nic', nic);
              prefs.setString('profileImg', profileImg);

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => NavigationHomeScreen()),
                  (Route<dynamic> route) => false);
            } else {
              //ur not a customer - cant create 2 accounts by same mobile number
              returnErrorMsg('You\'re already registered with this number');
            }
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => PersonRegistration()),
                (Route<dynamic> route) => false);
          }

          //else just pass to the home page

          //Navigator.pushNamed(context, PersonRegistration.id);

        } else {
          print('auto error');
        }
        //this callback gets called when verification is done automatically
      },
      verificationFailed: (AuthException exception) {
        print(
            '--------------------------varification error--------------------------------------');
        print(exception.message);
        returnErrorMsg(exception.message.toString() +
            "--------phone num: " +
            phone.toString());
      },
      codeSent: (String verificationId, [int forceResendtionToken]) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      verificationId: verificationId,
                    )));

        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) {
        //     return Container(
        //       child: AlertDialog(
        //         title: Text('Enter the code'),
        //         content: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: <Widget>[
        //             TextFormField(
        //               textAlign: TextAlign.center,
        //               controller: _codeController,
        //               validator: (text) {
        //                 if (text == null || text.isEmpty) {
        //                   return 'Text is empty';
        //                 }
        //                 return null;
        //               },
        //               decoration: InputDecoration(
        //                 icon: Icon(
        //                   Icons.phone_iphone,
        //                   color: AppTheme.btnColor,
        //                 ),
        //                 hintText: 'Enter the OTP code',
        //                 border: UnderlineInputBorder(
        //                   borderSide:
        //                       BorderSide(color: AppTheme.btnColor, width: 1.0),
        //                 ),
        //                 enabledBorder: UnderlineInputBorder(
        //                   borderSide:
        //                       BorderSide(color: AppTheme.btnColor, width: 1.0),
        //                 ),
        //                 focusedBorder: UnderlineInputBorder(
        //                   borderSide:
        //                       BorderSide(color: AppTheme.btnColor, width: 2.0),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         actions: <Widget>[
        //           //cancel button
        //           FlatButton(
        //             child: Text('Cancel'),
        //             textColor: Colors.black,
        //             color: AppTheme.btnColor,
        //             onPressed: () async {
        //               Navigator.of(context).pop();
        //             },
        //           ),
        //           FlatButton(
        //             child: Text('Confirm'),
        //             textColor: Colors.black,
        //             color: AppTheme.btnColor,
        //             onPressed: () async {
        //               try {
        //                 final code = _codeController.text.trim();
        //                 AuthCredential credential =
        //                     PhoneAuthProvider.getCredential(
        //                   verificationId: verificationId,
        //                   smsCode: code,
        //                 );

        //                 AuthResult result =
        //                     await _auth.signInWithCredential(credential);

        //                 FirebaseUser user = result.user;

        //                 if (user != null) {
        //                   // Navigator.of(context).pop();
        //                   final userProfile = await _firestore
        //                       .collection('user_profile')
        //                       .where("user_id", isEqualTo: user.uid)
        //                       .getDocuments();

        //                   // var phonenum = user.phoneNumber;
        //                   // print('user manually registerd: $phonenum');

        //                   if (userProfile.documents.length > 0) {
        //                     if (userProfile.documents[0].data['userType'] ==
        //                         'customer') {
        //                       SharedPreferences prefs =
        //                           await SharedPreferences.getInstance();
        //                       //save user data in to local storage
        //                       var firstName =
        //                           userProfile.documents[0].data['first_name'];
        //                       var lastName =
        //                           userProfile.documents[0].data['last_name'];
        //                       var nic = userProfile.documents[0].data['nic'];
        //                       var profileImg =
        //                           userProfile.documents[0].data['profileImg'];

        //                       prefs.setString('fistName', firstName);
        //                       prefs.setString('lastName', lastName);
        //                       prefs.setString('nic', nic);
        //                       prefs.setString('profileImg', profileImg);

        //                       Navigator.of(context).pushAndRemoveUntil(
        //                           MaterialPageRoute(
        //                               builder: (context) =>
        //                                   NavigationHomeScreen()),
        //                           (Route<dynamic> route) => false);
        //                     } else {
        //                       //ur not a customer - cant create 2 accounts by same mobile number
        //                       returnErrorMsg(
        //                           'You\'re already registered with this number');
        //                     }
        //                   } else {
        //                     Navigator.of(context).pushAndRemoveUntil(
        //                         MaterialPageRoute(
        //                             builder: (context) => PersonRegistration()),
        //                         (Route<dynamic> route) => false);
        //                   }
        //                 } else {
        //                   returnErrorMsg('something is wrong... Try Again...');
        //                 }
        //               } catch (e) {}
        //             },
        //           ),
        //         ],
        //       ),
        //     );
        //   },
        // );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = verificationId;
        print(verificationId);
        print("Timout");
      },
    );
  }

  //FirebaseUser loggedInUser;
  String mobileNumber;

  @override
  void initState() {
    super.initState();
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
                      controller: _phoneContrller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          mobileNum = value;
                        });
                      },
                      validator: (value) {
                        Pattern pattern = r'^+94(\+\d{1,3}[- ]?)?\d{9}$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(value))
                          return 'Enter Valid Number';
                        else
                          return null;
                      },
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.phone_iphone,
                          color: AppTheme.btnColor,
                        ),
                        hintText: '(+94) Mobile Number',
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
                        errorText: mobileNumIsValidated
                            ? null
                            : 'Mobile number can\'t be empty',
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
                          if (mobileNum == null || mobileNum.isEmpty) {
                            setState(() {
                              mobileNumIsValidated = false;
                            });
                          } else {
                            setState(() {
                              mobileNumIsValidated = true;
                            });
                            final phone = mobileNum.trim();
                            loginUser(phone, context);
                          }
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
