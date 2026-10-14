import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_forgot.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_login.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/OTP/auth_state.dart';
import 'package:mech_go/OTP/otp_screen.dart';

class MechanicSignUp extends StatelessWidget {
  const MechanicSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: AuthRepository(),
      ),
      child: const _MechanicSignUpView(),
    );
  }
}

class _MechanicSignUpView extends StatefulWidget {
  const _MechanicSignUpView();

  @override
  State<_MechanicSignUpView> createState() => _MechanicSignUpViewState();
}

class _MechanicSignUpViewState extends State<_MechanicSignUpView> {
  final _formKey = GlobalKey<FormState>();

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool rememberPassword = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
          SignupRequested(
            name: '',
            email: emailController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            password: passwordController.text,
            role: 'mechanic',
            rememberMe: rememberPassword,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // OTP successfully sent
        if (state.status == AuthStatus.otpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: OtpScreen(
                  phoneNumber: state.phoneNumber!,
                  verificationId: state.verificationId!,
                ),
              ),
            ),
          );
        }
    
        // Error
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Something went wrong.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/login_cover.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
    
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.32),
              ),
            ),
    
            Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.04,
                      ),
    
                      Text(
                        'SignUp to MechGo',
                        style: GoogleFonts.lobsterTwo(
                          color: Colors.black,
                          fontSize: size.height * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
    
                      const SizedBox(height: 4),
    
                      const Text(
                        'Be a part of MechGo',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Times New Roman',
                          fontSize: 14,
                        ),
                      ),
    
                       Icon(
                        Icons.car_crash_rounded,
                        size: 75,
                        color: primaryRed,
                      ),
                      Expanded(
                        child: Container(
                          width: size.width - 25,
                          margin: const EdgeInsets.only(
                            bottom: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(11),
                            boxShadow:  [
                              BoxShadow(
                                color: primaryRed,
                                blurRadius: 2,
                                offset: Offset(3, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
    
                                // EMAIL
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  child: TextFormField(
                                    controller:
                                        emailController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration:
                                        InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: primaryRed,
                                      ),
                                      hintText:
                                          'Mechanic@gmail.com',
                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Enter your email';
                                      }
    
                                      if (!RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(
                                        value.trim(),
                                      )) {
                                        return 'Enter a valid email';
                                      }
    
                                      return null;
                                    },
                                  ),
                                ),
    
                                // PHONE
                                Padding(
                                  padding:
                                       const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  child: TextFormField(
                                    controller:
                                        phoneController,
                                    keyboardType:
                                        TextInputType.phone,
                                    decoration:
                                        InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.phone,
                                        color: Colors.red,
                                      ),
                                      hintText:
                                          '+923001234567',
                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Enter your phone number';
                                      }
    
                                      if (!value
                                          .trim()
                                          .startsWith('+')) {
                                        return 'Use country code e.g. +923001234567';
                                      }
    
                                      return null;
                                    },
                                  ),
                                ),
    
                                // PASSWORD
                                Padding(
                                  padding:
                                       const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  child: TextFormField(
                                    controller:
                                        passwordController,
                                    obscureText:
                                        obscurePassword,
                                    decoration:
                                        InputDecoration(
                                      hintText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons
                                            .password_outlined,
                                        color: Colors.red,
                                      ),
                                      suffixIcon:
                                          IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscurePassword =
                                                !obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          obscurePassword
                                              ? Icons
                                                  .visibility
                                              : Icons
                                                  .visibility_off,
                                        ),
                                      ),
                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Enter password';
                                      }
    
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
    
                                      return null;
                                    },
                                  ),
                                ),
    
                                // CONFIRM PASSWORD
                                Padding(
                                  padding:
                                     const EdgeInsets.only(left: 8, right: 8, top: 8),
                                  child: TextFormField(
                                    controller:
                                        confirmPasswordController,
                                    obscureText:
                                        obscureConfirmPassword,
                                    decoration:
                                        InputDecoration(
                                      hintText:
                                          'Confirm Password',
                                      prefixIcon: const Icon(
                                        Icons
                                            .password_outlined,
                                        color: Colors.red,
                                      ),
                                      suffixIcon:
                                          IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureConfirmPassword =
                                                !obscureConfirmPassword;
                                          });
                                        },
                                        icon: Icon(
                                          obscureConfirmPassword
                                              ? Icons
                                                  .visibility
                                              : Icons
                                                  .visibility_off,
                                        ),
                                      ),
                                      border:
                                          OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Confirm your password';
                                      }
    
                                      if (value !=
                                          passwordController
                                              .text) {
                                        return 'Passwords do not match';
                                      }
    
                                      return null;
                                    },
                                  ),
                                ),
    
                                // REMEMBER PASSWORD
                                Row(
                                  children: [
                                    Checkbox(
                                      value:
                                          rememberPassword,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberPassword =
                                              value ?? false;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Remember Password',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily:
                                            'Times New Roman',
                                      ),
                                    ),
                                  ],
                                ),
    
                                // FORGOT PASSWORD
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MechanicForgot(),
                                      ),
                                    );
                                  },
                                  child:  Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: primaryRed,
                                      fontFamily:
                                          'Times New Roman',
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
    
                                const SizedBox(height: 3),
    
                                // SIGNUP BUTTON
                                Padding(
                                  padding:
                                      const EdgeInsets.all(8),
                                  child: BlocBuilder<
                                      AuthBloc,
                                      AuthState>(
                                    builder:
                                        (context, state) {
                                      final loading =
                                          state.status ==
                                              AuthStatus
                                                  .loading;
    
                                      return GestureDetector(
                                        onTap: loading
                                            ? null
                                            : signup,
                                        child: Container(
                                          width:
                                              double.infinity,
                                          height:
                                              size.height *
                                                  0.06,
                                          decoration:
                                              BoxDecoration(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              8,
                                            ),
                                            color:primaryRed,
                                          ),
                                          child: Center(
                                            child: loading
                                                ? const CircularProgressIndicator(
                                                    color:
                                                        Colors
                                                            .white,
                                                  )
                                                : const Text(
                                                    'SignUp as Mechanic',
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors
                                                              .white,
                                                      fontSize:
                                                          18,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
    
                                // SOCIAL LOGIN
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        'Or Signin with',
                                        style: TextStyle(
                                          color:
                                              Colors.black54,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                               SizedBox(
                                height: size.height*0.02,
                               ),
                                Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                              child: GestureDetector(
                                onTap: (){
                                  context.read<AuthBloc>().add(
                                      GoogleLoginRequested(
                                        role: 'mechanic',
                                      rememberMe: rememberPassword),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: size.height*0.06,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: primaryRed,
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.google,
                                      color: Colors.white,
                                      size: 37,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                              ],
                            ),
                          ),
                        ),
                      ),
    
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily:
                                  'Times New Roman',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MechanicLogin(),
                                ),
                              );
                            },
                            child: const Text(
                              ' Login',
                              style: TextStyle(
                                color: Color.fromARGB(
                                  255,
                                  215,
                                  20,
                                  6,
                                ),
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
          ],
        ),
      ),
    );
  }
}