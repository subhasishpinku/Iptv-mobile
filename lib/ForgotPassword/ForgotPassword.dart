import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Form(
                      key: _formKey, // ✅ FORM KEY
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔴 LOGO
                          Image.asset("assets/images/logo.png", height: 180),

                          const SizedBox(height: 40),

                          /// 📱 PHONE INPUT WITH VALIDATION
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter phone number",
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),

                            /// ✅ VALIDATION LOGIC
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Phone number is required";
                              } else if (value.length < 10) {
                                return "Enter valid phone number";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 50),

                          /// 🔴 BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // ✅ VALID → NEXT STEP
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Processing..."),
                                    ),
                                  );

                                  // এখানে API call / OTP send করবে
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Forgot Password",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}