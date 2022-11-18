import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _logo(),
            _logoText(),
            _inputField(
                const Icon(Icons.person_outline,
                    size: 30, color: Color(0xffA6B0BD)),
                "Username",
                false),
            _inputField(
                const Icon(Icons.lock_outline,
                    size: 30, color: Color(0xffA6B0BD)),
                "Password",
                true),
            _loginBtn()
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      child: Stack(
        children: [
          Positioned(
              left: -50,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff00bfdb),
                ),
              )),
          Positioned(
              child: Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff008FFF),
            ),
          )),
          Positioned(
            left: 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff00227E),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _logoText() {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      child: Text(
        "microtest",
        style: GoogleFonts.nunito(
          textStyle: const TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w800,
            color: Color(0xff000912),
            letterSpacing: 10,
          ),
        ),
      ),
    );
  }

  Widget _inputField(Icon prefixIcon, String hintText, bool isPassword) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 25,
            offset: Offset(0, 5),
            spreadRadius: -25,
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.montserrat(
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xff000912),
          ),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 25),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xffA6B0BD),
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 75,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _loginBtn() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, bottom: 50),
      decoration: const BoxDecoration(
          color: Color(0xff008FFF),
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: Color(0x60008FFF),
              blurRadius: 10,
              offset: Offset(0, 5),
              spreadRadius: 0,
            ),
          ]),
      child: TextButton(
        onPressed: () => {print('Sign in pressed.')},
        // padding: EdgeInsets.symmetric(vertical: 25),
        child: Text(
          "SIGN IN",
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
