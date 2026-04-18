import 'package:flutter/material.dart';
import 'package:iptvmobile/widgets/profileImage.dart';
import 'package:iptvmobile/widgets/textWidgets.dart';


class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  State<Page4> createState() => _Page4State();
}
class _Page4State extends State<Page4> {
  @override
  Widget build(BuildContext context) {
    TextEditingController fullNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const profileImage(),
            TextWidgets(
              textController: fullNameController,
              labelText: "User Name",
              hintText: "Enter Your Name",
              obscureText: false,
            ),
            const SizedBox(
              height: 30,
            ),
            TextWidgets(
                textController: emailController,
                labelText: "User Email",
                hintText: "Enter Your Email",
                obscureText: false),
            const SizedBox(
              height: 30,
            ),
            TextWidgets(
                textController: passwordController,
                labelText: "User Password",
                hintText: "Enter Your Password",
                obscureText: true),
            const SizedBox(
              height: 30,
            ),
            TextWidgets(
                textController: passwordController,
                labelText: "Location",
                hintText: "Enter Your Location",
                obscureText: false),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: MaterialButton(
                      color: Colors.white,
                      textColor: Colors.white,
                      onPressed: () {},
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: MaterialButton(
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                      onPressed: () {},
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}