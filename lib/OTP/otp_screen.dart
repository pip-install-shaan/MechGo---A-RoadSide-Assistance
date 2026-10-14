import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/mechanic_main.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_state.dart';
import 'package:mech_go/User/user_main_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_secondsRemaining == 0) {
          timer.cancel();
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  void _verifyOtp() {
    final String code = _otpController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit OTP.'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          VerifyOtpRequested(
            verificationId: widget.verificationId,
            smsCode: code,
          ),
        );
  }

  void _resendOtp() {
    if (_secondsRemaining > 0) {
      return;
    }

    context.read<AuthBloc>().add(
          ResendOtpRequested(
            phoneNumber: widget.phoneNumber,
          ),
        );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ------------------------------------------------------
        // NEW OTP SENT
        // ------------------------------------------------------

        if (state.status == AuthStatus.otpSent &&
            state.verificationId != null) {
          _startTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new OTP has been sent.'),
            ),
          );
        }

        // ------------------------------------------------------
        // SUCCESS
        // ------------------------------------------------------

        if (state.status == AuthStatus.success) {
          if (state.role == 'mechanic') {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MechanicMain(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully!',
              ),
            ),
          );
  } else if (state.role == 'user') {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const UserMain(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully!',
              ),
            ),
          );
  }
        }
          
          

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'OTP verification failed.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Phone'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                const Icon(
                  Icons.sms,
                  size: 70,
                ),

                const SizedBox(height: 25),

                const Text(
                  'Verify Your Phone Number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'We sent a 6-digit OTP to\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 20),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final bool verifying =
                        state.status ==
                            AuthStatus.otpVerifying;

                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            verifying ? null : _verifyOtp,
                        child: verifying
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(),
                              )
                            : const Text('Verify OTP'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                          'Resend OTP in $_secondsRemaining seconds',
                        )
                      : TextButton(
                          onPressed: _resendOtp,
                          child: const Text(
                            'Resend OTP',
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}