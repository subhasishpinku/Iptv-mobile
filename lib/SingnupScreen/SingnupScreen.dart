import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                const SizedBox(height: 20),

                Image.asset("assets/images/logo.png", height: 160),

                const SizedBox(height: 30),

                buildTextField("Enter Name", nameController,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                }),

                const SizedBox(height: 15),

                buildTextField("Enter Email", emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return "Enter valid email";
                  }
                  return null;
                }),

                const SizedBox(height: 15),

                buildTextField("Enter Phone Number", phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number required";
                  }
                  if (value.length < 10) {
                    return "Enter valid phone number";
                  }
                  return null;
                }),

                const SizedBox(height: 15),

                /// DOB
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: buildTextField("Enter DOB", dobController,
                        validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "DOB is required";
                      }
                      return null;
                    }),
                  ),
                ),

                const SizedBox(height: 15),

                buildTextField("Enter Password", passwordController,
                    isPassword: true,
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password required";
                  }
                  if (value.length < 6) {
                    return "Minimum 6 characters";
                  }
                  return null;
                }),

                const SizedBox(height: 30),

                /// SIGN UP BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ✅ All fields valid
                        print("Signup Success");
                      } else {
                        // ❌ Validation failed
                        print("Error");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?",
                        style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        " Sign In",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔧 TextField with Validator
  Widget buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        errorStyle: const TextStyle(color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey.shade900,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}