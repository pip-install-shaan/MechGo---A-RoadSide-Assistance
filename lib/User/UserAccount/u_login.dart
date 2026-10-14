import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/OTP/auth_state.dart';
import 'package:mech_go/User/UserAccount/u_forgot.dart';
import 'package:mech_go/User/UserAccount/u_signup.dart';
import 'package:mech_go/User/user_main_screen.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);


  bool rememberPassword = false;
  bool obsecurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => AuthBloc(
        authRepository: AuthRepository(),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.loginSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const UserMain(),
              ),
              (route) => false,
            );
          }

          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Login failed',
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
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
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 11),

                        // Heading
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: size.height * 0.032,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Subtitle
                        const Text(
                          'Login to Continue',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Times New Roman',
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Icon(
                          Icons.car_crash_rounded,
                          size: 70,
                          color:primaryRed,
                        ),

                        const SizedBox(height: 18),

                        // Form Container (auto-sizing instead of fixed height percentage)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: size.width - 25,
                          ),
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            top: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: primaryRed,
                                blurRadius: 2,
                                offset: Offset(1, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 12.0, top: 15),
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'User@gmail.com',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Times New Roman',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8,
                                  top: 8,
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: obsecurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obsecurePassword = !obsecurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        obsecurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserForgot(),
                                      ),
                                    );
                                  },
                                  child:  Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color:primaryRed,
                                      fontFamily: 'Times New Roman',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<AuthBloc>().add(
                                          GoogleLoginRequested(
                                            role: 'user',
                                            rememberMe: rememberPassword,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: primaryRed,
                                    ),
                                    child: const Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter email and password.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                        LoginRequested(
                                          email: email,
                                          password: password,
                                          role: 'user',
                                          rememberMe: rememberPassword,
                                        ),
                                      );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: primaryRed,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Do not have an account?',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Times New Roman',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserSignUp(),
                                  ),
                                );
                              },
                              child: Text(
                                ' SignUp',
                                style: TextStyle(
                                  color: primaryRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
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
      ),
    );
  }
}