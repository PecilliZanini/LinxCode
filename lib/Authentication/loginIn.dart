import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linxflutter/Authentication/google_sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final navigatorKey = GlobalKey<NavigatorState>();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  runApp(
    MaterialApp(
      supportedLocales: [Locale('en'), Locale('it'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: LoginPage(
        onClickedSignUp: () {},
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginPage({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String email = "";
  String psswd = "";
  final emailController = TextEditingController();
  final psswdController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void dispose() {
    super.dispose();
  }

  var obscureText = true;
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.white,
    // ));

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(statusBarColor: Colors.white),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: SafeArea(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Center(
                        child: SizedBox(
                            height: 200,
                            child: Image.asset('assets/images/login3.png')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.login,
                              style: GoogleFonts.poppins(
                                  fontSize: 37,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromARGB(255, 33, 54, 90)),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 30),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    hintText:
                                        AppLocalizations.of(context)!.email),
                                validator: (email) => email != null &&
                                        !EmailValidator.validate(email)
                                    ? AppLocalizations.of(context)!.valid_email
                                    : null,
                                controller: emailController,
                              ),
                            ),
                            TextFormField(
                                obscureText: obscureText,
                                validator: (psswd) => psswd != null &&
                                        !EmailValidator.validate(psswd) &&
                                        psswd.length < 5
                                    ? AppLocalizations.of(context)!
                                        .valid_password
                                    : null,
                                controller: psswdController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_rounded),
                                    suffixIcon: GestureDetector(
                                      child: obscureText
                                          ? Icon(Icons.visibility_off)
                                          : Icon(Icons.visibility),
                                      onTap: () {
                                        setState(() {
                                          obscureText = !obscureText;
                                        });
                                      },
                                    ),
                                    hintText:
                                        AppLocalizations.of(context)!.password))
                          ],
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.fromLTRB(0, 23, 30, 0),
                        child: GestureDetector(
                          child: Text(
                            AppLocalizations.of(context)!.forgot_password,
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Color.fromARGB(255, 0, 101, 255),
                                fontWeight: FontWeight.w500),
                          ),
                          onTap: resetPsswd,
                        )),
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                            child: Column(
                              children: [
                                SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final isValidForm =
                                            formKey.currentState!.validate();
                                        if (isValidForm) {
                                          signIn();
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.login,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromARGB(
                                                      255, 0, 101, 255)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13))),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent)),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.or,
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: Image.network(
                                        "https://img.icons8.com/?size=512&id=17949&format=png",
                                        height: 23,
                                      ),
                                      onPressed: () {
                                        final provider =
                                            Provider.of<GoogleSignInProvider>(
                                                context,
                                                listen: false);
                                        provider.googleLogin();
                                      },
                                      label: Text(
                                        AppLocalizations.of(context)!
                                            .loginGoogle,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromARGB(
                                                      255, 241, 245, 246)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13))),
                                          shadowColor:
                                              MaterialStateProperty.all(
                                                  Colors.transparent)),
                                    ))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.new_to_linx,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: GestureDetector(
                                    child: Text(
                                      AppLocalizations.of(context)!.register,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(255, 0, 101, 255)),
                                    ),
                                    onTap: widget.onClickedSignUp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
              ),
            ),
          );
        });
  }

  Future resetPsswd() async {
    try {
      if (emailController.text.isNotEmpty) {
        print("Prova");
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim());
        Navigator.of(context).popUntil((route) => route.isFirst);
        Fluttertoast.showToast(msg: 'Check your spam');
      }
    } on FirebaseAuthException catch (e) {
      print(e);

      Navigator.of(context).pop();
      return SnackBar(content: Text(e.toString()));
    }
  }

  Future signIn() async {
    //showDialog(context: context,barrierDismissible: false, builder: (context) => Center(child: CircularProgressIndicator()));

    try {
      print("email:" +
          emailController.text.toString() +
          "pwd " +
          psswdController.text.toString());
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: psswdController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'wrong-password');
      }
      if (e.code == 'invalid-email') {
        Fluttertoast.showToast(msg: 'invalid-email');
      }
      if (e.code == 'user-disabled') {
        Fluttertoast.showToast(msg: 'user-disabled');
      }
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'user-not-found');
      }

      return Center(child: Text("Error"));
    }
  }
}
