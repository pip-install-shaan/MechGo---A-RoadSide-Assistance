import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_login.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/OTP/auth_state.dart';
import 'package:mech_go/User/UserAccount/u_login.dart';

class MechanicForgot extends StatefulWidget {
  const MechanicForgot({super.key});

  @override
  State<MechanicForgot> createState() => _MechanicForgotState();
}

class _MechanicForgotState extends State<MechanicForgot> {

    final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);
  bool rememberPassword=false;
  
  final TextEditingController emailController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void recoverPassword(BuildContext context) {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          ForgotPasswordRequested(
            email: email,
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
          if (state.status ==
              AuthStatus.passwordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Password reset email sent. Check your inbox.',
                ),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UserLogin(),
              ),
            );
          }

          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Unable to recover password.',
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.09,
                      ),

                      Text(
                        'Recover your Password',
                        style: GoogleFonts.lobsterTwo(
                          color: Colors.black,
                          fontSize: size.height * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                       Icon(
                        Icons.get_app,
                        size: 80,
                        color: primaryRed,
                      ),

                      SizedBox(
                        height: size.height * 0.03,
                      ),

                      Container(
                        width: size.width - 25,
                        height: size.height * 0.37,
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(11),
                          boxShadow:  [
                            BoxShadow(
                              color: primaryRed,
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

                            Padding(
                              padding:
                                  const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: primaryRed,
                                  ),
                                  hintText: 'Mechanic@gmail.com',
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading =
                                    state.status ==
                                        AuthStatus.loading;

                                return GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () =>
                                          recoverPassword(
                                            context,
                                          ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                      8.0,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      height:
                                          size.height * 0.06,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius
                                                .circular(8),
                                        color:primaryRed,
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 25,
                                                height: 25,
                                                child:
                                                    CircularProgressIndicator(
                                                  color:
                                                      Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Recover Password',
                                                style: TextStyle(
                                                  color:
                                                      Colors.white,
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

                            SizedBox(
                              height: size.height*0.04,
                            ),

                            Row(
                              children: const [
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'Or Signin with',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height*0.03,
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
                                    color: const Color.fromARGB(255, 219, 24, 10)
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

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MechanicLogin(),
                                ),
                              );
                            },
                            child: Text(
                              ' Login',
                              style: TextStyle(
                                color:primaryRed,
                                fontSize:
                                    size.height * 0.02,
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
            ],
          ),
        ),
      ),
    );
  }
}