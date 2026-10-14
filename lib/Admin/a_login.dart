import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/a_forgot.dart';
import 'package:mech_go/Admin/admin_bottom_nav.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/OTP/auth_state.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}


class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    blocContext.read<AuthBloc>().add(
          AdminLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          ),
        );
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
          // Login successful
          if (state.status == AuthStatus.loginSuccess &&
              state.role == 'admin') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin login successful!'),
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminBottomNav(),
              ),
              (route) => false,
            );
          }

          // Login failed
          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Admin login failed.',
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
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.07,
                          ),

                          Icon(
                            Icons.admin_panel_settings,
                            size: size.height * 0.19,
                            color: const Color.fromARGB(
                              255,
                              213,
                              21,
                              7,
                            ),
                          ),

                          // Heading
                          Text(
                            'Admin Login!',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.034,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Subtitle
                          const Text(
                            'Login to your admin account',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Times New Roman',
                              fontSize: 13,
                            ),
                          ),

                          SizedBox(
                            height: size.height * 0.02,
                          ),

                          Container(
                            width: size.width - 25,
                            padding: const EdgeInsets.only(
                              bottom: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(11),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.red,
                                  blurRadius: 2,
                                  offset: Offset(1, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 0.03,
                                ),

                                // Email
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily:
                                          'Times New Roman',
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.all(8),
                                  child: TextFormField(
                                    controller:
                                        _emailController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    decoration:
                                        InputDecoration(
                                      hintText:
                                          'admin@gmail.com',
                                      prefixIcon: const Icon(
                                        Icons.email,
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
                                          value.trim().isEmpty) {
                                        return 'Enter admin email';
                                      }

                                      if (!value.contains('@')) {
                                        return 'Enter a valid email';
                                      }

                                      return null;
                                    },
                                  ),
                                ),

                                SizedBox(
                                  height: size.height * 0.01,
                                ),

                                // Password
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Text(
                                    'Password',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily:
                                          'Times New Roman',
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    top: 8,
                                  ),
                                  child: TextFormField(
                                    controller:
                                        _passwordController,
                                    obscureText:
                                        _obscurePassword,
                                    decoration:
                                        InputDecoration(
                                      hintText: '*********',
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons
                                                  .visibility_off
                                              : Icons.visibility,
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

                                      return null;
                                    },
                                  ),
                                ),

                                // Remember Me
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    left: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        activeColor:
                                            const Color.fromARGB(
                                          255,
                                          219,
                                          24,
                                          10,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      const Text(
                                        'Remember Me',
                                        style: TextStyle(
                                          fontFamily:
                                              'Times New Roman',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Forgot Password
                                Align(
                                  alignment:
                                      Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminForgot(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(
                                          255,
                                          230,
                                          25,
                                          10,
                                        ),
                                        fontFamily:
                                            'Times New Roman',
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: size.height * 0.01,
                                ),

                                // Login Button
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder:
                                      (context, state) {
                                    final bool isLoading =
                                        state.status ==
                                            AuthStatus.loading;

                                    return GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () => _login(context),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(
                                          8,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height:
                                              size.height * 0.06,
                                          decoration:
                                              BoxDecoration(
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                            color:
                                                const Color
                                                    .fromARGB(
                                              255,
                                              219,
                                              24,
                                              10,
                                            ),
                                          ),
                                          child: Center(
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors
                                                          .white,
                                                      strokeWidth:
                                                          2,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Login',
                                                    style:
                                                        TextStyle(
                                                      color: Colors
                                                          .white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                               
                              ],
                            ),
                          ),
                        ],
                      ),
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