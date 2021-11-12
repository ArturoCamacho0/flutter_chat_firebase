// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:chat/screens/home.dart';
import 'package:chat/screens/register.dart';
import 'package:flutter/material.dart';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final Function(String? email, String? password)? onSubmitted;

  const LoginScreen({this.onSubmitted, Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String email, password;
  String? emailError, passwordError;

  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";

    emailError = null;
    passwordError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "El email es incorrecto.";
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Por favor ingrese una contraseña.";
      });
      isValid = false;
    }

    return isValid;
  }

  void submit() async {
    if (validate()) {
      if (onSubmitted != null) {
        onSubmitted!(email, password);
      }

      setState(() {
        showSpinner = true;
      });

      try {
        await auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((_) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Home()));
        });

        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        setState(() {
          showSpinner = false;
        });
        // ignore: invalid_return_type_for_catch_error
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Ha ocurrido un error'),
            content:
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(height: screenHeight * .12),
                const Text(
                  "Bienvenid@,",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * .01),
                Text(
                  "inicia sesión para continuar.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(.6),
                  ),
                ),
                SizedBox(height: screenHeight * .12),
                InputField(
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  labelText: "Correo electrónico",
                  errorText: emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autoFocus: true,
                ),
                SizedBox(height: screenHeight * .025),
                InputField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onSubmitted: (val) => submit(),
                  labelText: "Contraseña",
                  errorText: passwordError,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * .075,
                ),
                FormButton(
                  text: "Iniciar sesión",
                  onPressed: submit,
                ),
                SizedBox(
                  height: screenHeight * .15,
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      text: "¿Eres nuev@?, ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "registrate",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  const FormButton({this.text = "", this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.redAccent;
            }
            return Colors.redAccent.shade100; // Use the component's default.
          },
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: screenHeight * .02)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0))),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String? labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool obscureText;
  const InputField(
      {this.labelText,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.autoFocus = false,
      this.obscureText = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
