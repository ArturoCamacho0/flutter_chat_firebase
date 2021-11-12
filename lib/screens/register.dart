import 'package:chat/screens/home.dart';
import 'package:chat/screens/login.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password, String? name)? onSubmitted;

  const RegisterScreen({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String name, email, password, confirmPassword;
  String? emailError, passwordError, nameError;
  Function(String? email, String? password, String? name)? get onSubmitted =>
      widget.onSubmitted;

  final firebase = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    name = "";
    email = "";
    password = "";
    confirmPassword = "";

    emailError = null;
    passwordError = null;
    nameError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
      nameError = null;
    });
  }

  bool validate() {
    resetErrorText();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (name.isEmpty) {
      setState(() {
        nameError = "El nombre es incorrecto.";
      });
      isValid = false;
    }

    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "El email es incorrecto.";
      });
      isValid = false;
    }

    if (password.isEmpty || confirmPassword.isEmpty || password.length < 6) {
      setState(() {
        passwordError =
            "Por favor ingrese una contraseña mayor a 6 caracteres.";
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = "Las contraseñas no coinciden.";
      });
      isValid = false;
    }

    return isValid;
  }

  void submit() async {
    if (validate()) {
      if (onSubmitted != null) {
        onSubmitted!(name, email, password);
      }

      setState(() {
        showSpinner = true;
      });

      try {
        await auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {
                  auth
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .then((_) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Home()));
                  })
                });

        final User? user = auth.currentUser;

        await firebase
            .collection("users")
            .doc(user!.uid)
            .set({'user_id': user.uid, 'name': name});

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
                SizedBox(height: screenHeight * .08),
                const Text(
                  "Crea una cuenta,",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * .01),
                Text(
                  "registrate para ingresar!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(.6),
                  ),
                ),
                SizedBox(height: screenHeight * .12),
                InputField(
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  labelText: "Nombre",
                  errorText: nameError,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autoFocus: true,
                ),
                SizedBox(height: screenHeight * .025),
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
                ),
                SizedBox(height: screenHeight * .025),
                InputField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  labelText: "Contraseña",
                  errorText: passwordError,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: screenHeight * .025),
                InputField(
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                  onSubmitted: (value) => submit(),
                  labelText: "Escribe de nuevo tu contraseña",
                  errorText: passwordError,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(
                  height: screenHeight * .075,
                ),
                FormButton(
                  text: "Registrarse",
                  onPressed: submit,
                ),
                SizedBox(
                  height: screenHeight * .125,
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      text: "Ya tengo cuenta, ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "iniciar sesión",
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
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)
            )
        ),),
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
