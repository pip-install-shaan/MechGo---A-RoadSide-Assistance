import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_forgot.dart';
import 'package:mech_go/Mechanic/MechanicAccount/m_signup.dart';
import 'package:mech_go/Mechanic/mechanic_main.dart';
import 'package:mech_go/OTP/auth_bloc.dart';
import 'package:mech_go/OTP/auth_event.dart';
import 'package:mech_go/OTP/auth_repo.dart';
import 'package:mech_go/OTP/auth_state.dart';

class MechanicLogin extends StatefulWidget {
  const MechanicLogin({super.key});

  @override
  State<MechanicLogin> createState() => _MechanicLoginState();
}

class _MechanicLoginState extends State<MechanicLogin> {
  
  final TextEditingController emailContoller=TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  
  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);


  bool rememberPassword=false;
  bool obsecurePassword=true;

  @override
  void dispose(){
    emailContoller.dispose();
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
            builder: (_) => const MechanicMain(),
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
        body:Stack(
          children: [
            Positioned.fill(
              child: Opacity(opacity: 
              0.25, child: Image.asset('assets/login_cover.jpg', fit: BoxFit.cover,),)),
            Positioned.fill(child: Container(
              color: Colors.white.withOpacity(0.32),
            )),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            
                      SizedBox(
                        height: 13,
                      ),
                            
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
                       
                       Icon(Icons.car_repair, size: 100, 
                       color: primaryRed,),
                      SizedBox(
                        height: size.height*0.03,
                      ),
                      Container(
                            width: size.width-25,
                            height: size.height * 0.52,
                          
                            margin: const EdgeInsets.only(
                              bottom: 20,
                            ),
                          
                            decoration: BoxDecoration(
                              color: Colors.white
                              ,
                              borderRadius: BorderRadius.circular(11),
                          
                              boxShadow:  [
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
                            SizedBox(
                              height: size.height*0.03,
                            ),
                             Padding(
                               padding: const EdgeInsets.only(left: 8.0),
                               child: Text('Email',
                               style: TextStyle(
                                                       color: Colors.black,
                                                       fontFamily: 'Times New Roman',
                                                       fontWeight: FontWeight.bold
                                                     ),),
                             ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: emailContoller,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Mechanic@gmail.com',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)
                                )
                              ),
                            ),
                          ),
                          SizedBox(
                              height: size.height*0.01,
                            ),
                             Padding(
                               padding: const EdgeInsets.only(left:8.0),
                               child: Text('Password',style: TextStyle(
                                                       color: Colors.black,
                                                       fontFamily: 'Times New Roman',
                                                       fontWeight: FontWeight.bold
                                                     ),),
                             ),
                           Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                            child: TextField(
                              controller: passwordController,
                              obscureText: obsecurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                suffixIcon: IconButton(onPressed: (){
                                  setState(() {
                                    obsecurePassword=!obsecurePassword;
                                  });
                                }, 
                                icon: Icon(obsecurePassword ? Icons.visibility_off : Icons.visibility)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)
                                )
                              ),
                            ),
                          ),
                          
                             TextButton(onPressed: (){
                              Navigator.push(context, 
                              MaterialPageRoute(builder: (context)=>MechanicForgot()));
                             }, 
                             child: Text('Forgot Password?',style: TextStyle(
                            color: primaryRed,
                            fontFamily: 'Times New Roman',
                            fontWeight: FontWeight.bold
                          ),),),
                          SizedBox(
                              height: size.height*0.01,
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
                          GestureDetector(
                            onTap: (){
                              final email=emailContoller.text.trim();
                              final password=passwordController.text.trim();
                                
                              if(email.isEmpty || password.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter email and password.')),);
                                return;
                              }
                              context.read<AuthBloc>().add(
                               LoginRequested(email: email, 
                               password: password, 
                               role: 'mechanic', 
                               rememberMe: rememberPassword)
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                height: size.height*0.06,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: primaryRed,
                                ),
                                child: Center(
                                  child: Text('Login', style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                            ),
                          )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Do not have an account?',style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Times New Roman',
                          ),),
                          TextButton(onPressed: (){
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context)=>MechanicSignUp()));
                          }, child: Text(' SignUp',style: TextStyle(
                            color: primaryRed,
                            
                            fontWeight: FontWeight.bold
                          ),),)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    )
    );
  }
}