import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iptvmobile/OtpScreen.dart/providers/auth_provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? mobileNumber;

  const OtpScreen({super.key, this.mobileNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> with CodeAutoFill {
  final List<TextEditingController> controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  late String mobileNumber;

  String _otpCode = '';
  bool _isListening = false;
  int? _apiOtp;
  bool _isAutoSubmitScheduled = false; // ✅ Track if auto-submit is scheduled

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get mobile number from widget or arguments
    if (widget.mobileNumber != null) {
      mobileNumber = widget.mobileNumber!;
    } else {
      mobileNumber = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    }

    print("📱 Mobile Number in OTP Screen: $mobileNumber");

    // Get OTP from provider state (API response)
    final authState = ref.read(authStateProvider);
    if (authState.lastSentOtp != null && _apiOtp == null) {
      _apiOtp = authState.lastSentOtp;
      print("🎯 Got OTP from API Response: $_apiOtp");
      // Auto-fill OTP from API response
      // _fillOtpFromApi(_apiOtp.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _requestSMSPermission();
    _startSmsListener();

    // Auto-submit করার জন্য listener
    SmsAutoFill().listenForCode;

    // Check again after build for API OTP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.lastSentOtp != null && _apiOtp == null) {
          _apiOtp = authState.lastSentOtp;
          print("🎯 Post-frame - Got OTP from API: $_apiOtp");
          // _fillOtpFromApi(_apiOtp.toString());
        }
      }
    });
  }

  @override
  void dispose() {
    _stopSmsListener();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _requestSMSPermission() async {
    final status = await Permission.sms.status;
    if (!status.isGranted) {
      final result = await Permission.sms.request();
      if (result.isGranted) {
        print("✅ SMS Permission Granted");
      } else {
        print("❌ SMS Permission Denied");
      }
    } else {
      print("✅ SMS Permission Already Granted");
    }
  }

  Future<void> _startSmsListener() async {
    if (!_isListening) {
      try {
        await SmsAutoFill().listenForCode;
        _isListening = true;
        print("✅ SMS Listener Started");
      } catch (e) {
        print("❌ Error starting SMS listener: $e");
      }
    }
  }

  Future<void> _stopSmsListener() async {
    if (_isListening) {
      await SmsAutoFill().unregisterListener();
      _isListening = false;
      print("✅ SMS Listener Stopped");
    }
  }

  @override
  void codeUpdated() {
    // This method is called when SMS is detected
    print("📨 SMS Detected: $code");

    if (code != null && code!.isNotEmpty) {
      _otpCode = code!;

      // Extract 4-digit OTP from SMS
      final RegExp regex = RegExp(r'\d{4}');
      final match = regex.firstMatch(_otpCode);

      if (match != null) {
        final otpDigits = match.group(0)!;
        print("🔢 Extracted OTP from SMS: $otpDigits");
        _fillOtpFields(otpDigits);
      } else {
        // If no 4-digit found, try to extract any digits
        final allDigits = RegExp(r'\d+').firstMatch(_otpCode);
        if (allDigits != null) {
          final digits = allDigits.group(0)!;
          if (digits.length >= 4) {
            final otpDigits = digits.substring(0, 4);
            print("🔢 Extracted OTP from SMS (alternative): $otpDigits");
            _fillOtpFields(otpDigits);
          }
        }
      }
    }
  }

  void _fillOtpFromApi(String otp) {
    print("📝 Filling OTP from API Response: $otp");

    // Make sure OTP is 4 digits
    String otpDigits = otp;
    if (otpDigits.length > 4) {
      otpDigits = otpDigits.substring(0, 4);
    } else if (otpDigits.length < 4) {
      otpDigits = otpDigits.padLeft(4, '0');
    }

    _fillOtpFields(otpDigits);
  }

  void _fillOtpFields(String otp) {
    if (!mounted) return; // ✅ Check if widget is still mounted
    
    print("📝 Filling OTP fields with: $otp");

    // Clear existing text
    for (var controller in controllers) {
      controller.clear();
    }

    // Fill OTP in the 4 boxes
    for (int i = 0; i < otp.length && i < 4; i++) {
      controllers[i].text = otp[i];
    }

    // Auto-submit if all 4 digits are filled (without delay)
    if (otp.length >= 4 && !_isAutoSubmitScheduled) {
      _isAutoSubmitScheduled = true;
      print("🚀 Auto-submitting OTP immediately...");
      
      // Small delay for UI to update
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) {
           submitOtp();
            print(" Auto-submitting OTP start...");
        }
        _isAutoSubmitScheduled = false;
      });
    }
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(color: Colors.white, fontSize: 20),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          // Auto move to next field
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }

          // Auto-submit when all fields are filled
          if (index == 3 && value.isNotEmpty) {
            final allFilled = controllers.every((c) => c.text.isNotEmpty);
            if (allFilled && !_isAutoSubmitScheduled) {
              _isAutoSubmitScheduled = true;
              print("🚀 All fields filled manually, auto-submitting...");
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  submitOtp();
                }
                _isAutoSubmitScheduled = false;
              });
            }
          }
        },
      ),
    );
  }

  void submitOtp() async {
    String otp = controllers.map((e) => e.text).join();

    print("🔐 Submitting OTP: $otp for mobile: $mobileNumber");

    if (otp.length < 4) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter complete OTP")),
        );
      }
      return;
    }

    if (mobileNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mobile number not found! Please go back and try again."),
          ),
        );
      }
      return;
    }

    // Call verify API
    final success = await ref
        .read(authStateProvider.notifier)
        .verifyOtp(mobileNumber, otp);

    if (success && mounted) {
      print("✅ OTP Verified Successfully!");
      Navigator.pushReplacementNamed(context, RouteNames.planScreen);
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      print("❌ OTP Verification Failed: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "OTP verification failed"),
          backgroundColor: Colors.red,
        ),
      );

      // Clear OTP fields on failure
      for (var controller in controllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
      _isAutoSubmitScheduled = false; // Reset auto-submit flag
    }
  }

  void resendOtp() async {
    if (mobileNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mobile number not found!")),
        );
      }
      return;
    }

    print("🔄 Resending OTP to: $mobileNumber");

    // Clear OTP fields
    for (var controller in controllers) {
      controller.clear();
    }
    
    _isAutoSubmitScheduled = false; // Reset flag

    // Focus on first field
    FocusScope.of(context).requestFocus(focusNodes[0]);

    // Resend OTP
    await ref.read(authStateProvider.notifier).sendOtp(mobileNumber);

    if (mounted && ref.read(authStateProvider).error == null) {
      // Get the new OTP from response
      final newOtp = ref.read(authStateProvider).lastSentOtp;
      if (newOtp != null) {
        print("🎯 New OTP received: $newOtp");
        _fillOtpFromApi(newOtp.toString());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP resent successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/images/logo.png", height: 150),
                        const SizedBox(height: 60),

                        // OTP Boxes Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (index) => buildOtpBox(index),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Mobile number display
                        Text(
                          mobileNumber.isEmpty
                              ? "OTP sent to your mobile number"
                              : "OTP sent to $mobileNumber",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        // Show OTP from API (for debugging/development)
                        if (_apiOtp != null)
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 12,
                          //     vertical: 6,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: Colors.green.shade900,
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       const Icon(
                          //         Icons.check_circle,
                          //         size: 16,
                          //         color: Colors.green,
                          //       ),
                          //       const SizedBox(width: 8),
                          //       Text(
                          //         "OTP: $_apiOtp (Auto-filled)",
                          //         style: const TextStyle(
                          //           color: Colors.green,
                          //           fontSize: 12,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                        const SizedBox(height: 10),

                        // Auto-detection status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sms,
                                size: 16,
                                color: _isListening
                                    ? Colors.green.shade400
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isListening
                                    ? "Auto-detecting SMS..."
                                    : "Enter OTP manually",
                                style: TextStyle(
                                  color: _isListening
                                      ? Colors.green.shade400
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Error message
                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              authState.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : submitOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authState.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Verify & Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resend button
                        TextButton(
                          onPressed: authState.isLoading ? null : resendOtp,
                          child: const Text(
                            "Resend OTP",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Manual entry hint
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter the OTP you received via SMS",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          label: const Text(
                            "Didn't receive OTP?",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
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