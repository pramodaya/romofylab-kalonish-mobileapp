import 'dart:io';

import 'package:best_flutter_ui_templates/app_theme.dart';
import 'package:best_flutter_ui_templates/login/model/person_data.dart';
import 'package:best_flutter_ui_templates/login/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'navigation_home_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';
  final PersonData personObj;
  const ProfileScreen(this.personObj);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
  }

  File _image;
  final picker = ImagePicker();
  bool showErrorMsg = false;
  final _firestore = Firestore.instance;

  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 300,
      maxWidth: 300,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _image == null
                        ? Image.asset(
                            'assets/images/cam.png',
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.85,
                          )
                        : Image.file(
                            _image,
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.85,
                          ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: showErrorMsg == true
                        ? Text(
                            'No image selected.',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Text(
                            '',
                          ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FloatingActionButton(
                    backgroundColor: Colors.pink[100],
                    onPressed: getImage,
                    tooltip: 'Pick Image',
                    child: Icon(
                      Icons.add_a_photo,
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
                              if (_image != null) {
                                final StorageReference firebaseStorageRef =
                                    FirebaseStorage.instance.ref().child(
                                        '/profile_images/${widget.personObj.phone}');

                                StorageUploadTask uploadTask =
                                    firebaseStorageRef.putFile(_image);

                                StorageTaskSnapshot storageSnapshot =
                                    await uploadTask.onComplete;

                                var downloadUrl =
                                    await storageSnapshot.ref.getDownloadURL();

                                String profileImg = '';
                                if (uploadTask.isComplete) {
                                  var url = downloadUrl.toString();
                                  print('uploaded');
                                  profileImg = url;
                                  print(url);
                                }

//save all in db
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => WelcomeScreen()),
                                    (Route<dynamic> route) => false);

                                var success = await _firestore
                                    .collection('user_profile')
                                    .add({
                                  'first_name': widget.personObj.firstName,
                                  'last_name': widget.personObj.lastName,
                                  'email': widget.personObj.email,
                                  'nic': widget.personObj.nic,
                                  'phone': widget.personObj.phone,
                                  'user_id': widget.personObj.userId,
                                  'userType': widget.personObj.userType,
                                  'isVerified': widget.personObj.isVerified,
                                  'profileImg': profileImg,
                                });
                              } else {
                                setState(() {
                                  showErrorMsg = true;
                                });
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print(' could not launch $command');
    }
  }
}
