import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mech_go/role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Role(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: 
            0.28, child: Image.asset('assets/login_cover.jpg', fit: BoxFit.cover,),)),
          Positioned.fill(child: Container(
            color: Colors.white.withOpacity(0.32),
          )),
          Padding(
            padding: const EdgeInsets.all(8),
                    
            child: Center(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.26,
              ),
          Icon(Icons.car_repair, color: primaryRed,
          size: size.height*0.28,),
          
              const SizedBox(height: 13),
          
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Mech',
                      style: GoogleFonts.lobsterTwo(
                        fontSize: size.height*0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'Go',
                      style: GoogleFonts.lobsterTwo(
                        fontSize:size.height*0.09,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 236, 25, 9),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height*0.02,
              ),

          
              Text(
                'Roadside Assistance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: const Color.fromARGB(255, 12, 11, 11),
                ),
              ),
          
              const SizedBox(height: 25),
            ],
          ),
        ),
          ),
        ]
      ),
    );
  }
}