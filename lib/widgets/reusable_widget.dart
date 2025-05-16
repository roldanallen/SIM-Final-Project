import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
  );
}

TextField reusableTextField(
    String text,
    IconData icon,
    bool isPasswordType,
    TextEditingController controller, {
      Function(String)? onChanged,
      String? errorText,
    }) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black),
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      labelText: text,
      errorText: errorText?.isNotEmpty == true ? errorText : null,
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.black),
      ),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap,) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOG IN' : 'SIGN UP',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.grey;
          }
          return Colors.black;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ),
  );
}

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final bool isOnline;

  const DeviceCard({super.key, required this.deviceName, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.watch, size: 30, color: Colors.deepPurple),
          const SizedBox(height: 10),
          Text(
            deviceName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: isOnline ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 5),
              Text(isOnline ? "Online" : "Offline", style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}