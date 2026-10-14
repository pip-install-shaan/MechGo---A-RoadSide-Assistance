import 'package:flutter/material.dart';

class AboutMechGo extends StatefulWidget {
  const AboutMechGo({super.key});

  @override
  State<AboutMechGo> createState() => _AboutMechGoState();
}

class _AboutMechGoState extends State<AboutMechGo> {
  final Color primaryRed = const Color.fromARGB(255, 198, 24, 11);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          'About MechGo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size.height * 0.026,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo or Icon Header Container
            Container(
              width: size.width*0.3,
              height: size.height*0.1,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.car_repair_rounded,
                size: size.height * 0.06,
                color: primaryRed,
              ),
            ),
            SizedBox(height: size.height * 0.01),

            // App Name / Tagline
            Text(
              'MechGo',
              style: TextStyle(
                fontSize: size.height * 0.030,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your Reliable Roadside Partner',
              style: TextStyle(
                fontSize: size.height * 0.015,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.height * 0.01),

            // Main Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryRed, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Who We Are',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'MechGo is an emergency roadside assistance platform designed to bridge the gap between stranded drivers and expert mechanics. '
                      'Whenever your vehicle encounters unexpected mechanical failures or breakdowns on the road where no local repair shops are in sight, '
                      'MechGo connects you swiftly with professional service providers nearby to get you back on track safely and efficiently.',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),

            // Features Row / Highlights
            Row(
              children: [
                Expanded(
                  child: _buildFeatureTile(
                    icon: Icons.flash_on,
                    title: 'Instant Help',
                    subtitle: 'Quick response time',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureTile(
                    icon: Icons.verified_user,
                    title: 'Trusted Pros',
                    subtitle: 'Verified mechanics',
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            // Contact / Support Section
            Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'logitrix.s@gmail.com',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),

            // Footer branding
            Text(
              'Built by Logitrix Solutions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Co-powered by Logitrix',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryRed, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}