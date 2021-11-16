import 'package:flutter/material.dart';
import 'package:startup_moshe/autentication_notifier.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Consumer<AuthRepository>(
        builder: (context, auth, _) => Row(
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: auth.isAuthenticated ? MediaQuery.of(context).size.height * 0.05: 0,
                backgroundImage: auth.isAuthenticated && auth.avatar!=null
                    ? NetworkImage(
                        auth.avatar!,
                      )
                    : null,
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.isAuthenticated ? auth.user!.email! : "",
                      style: TextStyle(
                        fontSize: 22
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                          if(value == null){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'No picture was selected')),
                            );
                          } else {
                              auth.avatarPicutre = io.File(value.path);
                          }
                        });
                      },
                      child: Text("Change Avatar"),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
