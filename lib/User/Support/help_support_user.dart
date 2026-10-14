import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportUser extends StatefulWidget {
  const HelpSupportUser({super.key});

  @override
  State<HelpSupportUser> createState() => _HelpSupportUserState();
}

class _HelpSupportUserState extends State<HelpSupportUser> {
  int characterCount = 0;
  bool _isSending = false;

  final TextEditingController descriptionController =
      TextEditingController();

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  // Admin contact
  static const String adminEmail = 'logitrix.s@gmail.com';

  // WhatsApp number
  // IMPORTANT:
  // WhatsApp number must NOT contain +, spaces or dashes.
  static const String whatsappNumber = '923093391591';

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN GMAIL
  // ============================================================

  Future<void> _openGmail({
    String? body,
  }) async {
    final String subject = 'MechGo Support Request';

    final String emailBody = body?.trim().isNotEmpty == true
        ? body!.trim()
        : 'Hello MechGo Support,\n\n';

    // Gmail web compose URL.
    //
    // This is more reliable than mailto on Android because
    // it can open Gmail in the browser even when no email
    // application is registered for mailto.
    final Uri gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm'
      '&fs=1'
      '&to=${Uri.encodeComponent(adminEmail)}'
      '&su=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(emailBody)}',
    );

    try {
      final bool launched = await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open Gmail.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gmail compose opened successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('GMAIL ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open Gmail: $e',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // SEND ISSUE TO ADMIN
  // ============================================================

  Future<void> _emailToAdmin() async {
    final String issueText =
        descriptionController.text.trim();

    if (issueText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your issue before sending.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _openGmail(
        body:
            'Hello MechGo Support,\n\n'
            'I am facing the following issue:\n\n'
            '$issueText\n\n'
            'Thank you.',
      );

      if (mounted) {
        descriptionController.clear();

        setState(() {
          characterCount = 0;
        });
      }
    } catch (e) {
      debugPrint('SEND SUPPORT ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // OPEN WHATSAPP
  // ============================================================

  Future<void> _openWhatsApp() async {
    const String message =
        'Hello MechGo Support, I need help regarding my MechGo account/request.';

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$whatsappNumber'
      '?text=${Uri.encodeComponent(message)}',
    );

    try {
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open WhatsApp.');
      }
    } catch (e) {
      debugPrint('WHATSAPP ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open WhatsApp: $e',
            ),
          ),
        );
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        Theme.of(context).scaffoldBackgroundColor;

    final Color cardColor =
        Theme.of(context).cardColor;

    final Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
            (isDark ? Colors.white : Colors.black87);

    final Color secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
            (isDark ? Colors.white70 : Colors.black54);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        centerTitle: true,

        title: Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size.height * 0.026,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.03,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [

            // ==================================================
            // SUPPORT ICON
            // ==================================================

            Container(
              width: size.width * 0.25,
              height: size.height * 0.09,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.support_agent,
                size: size.height * 0.05,
                color: primaryRed,
              ),
            ),

            SizedBox(
              height: size.height * 0.015,
            ),

            Text(
              'Here to Assist You!',
              style: TextStyle(
                fontSize: size.height * 0.028,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Facing trouble with your request? '
              'Let us know below.',
              style: TextStyle(
                fontSize: 13.5,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: size.height * 0.025,
            ),

            // ==================================================
            // ISSUE TEXT FIELD
            // ==================================================

            Container(
              height: size.height * 0.2,

              decoration: BoxDecoration(
                color: cardColor,

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  color: isDark
                      ? Colors.white24
                      : Colors.black26,
                ),
              ),

              child: Stack(
                children: [

                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      25,
                    ),

                    child: TextField(
                      controller:
                          descriptionController,

                      maxLength: 250,

                      maxLines: null,

                      expands: true,

                      textAlignVertical:
                          TextAlignVertical.top,

                      style: TextStyle(
                        color: textColor,
                      ),

                      onChanged: (value) {
                        setState(() {
                          characterCount =
                              value.length;
                        });
                      },

                      decoration:
                          InputDecoration(
                        border:
                            InputBorder.none,

                        counterText: '',

                        hintText:
                            'I am facing issue while sending request.....',

                        hintStyle: TextStyle(
                          color:
                              secondaryTextColor,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 12,
                    bottom: 8,

                    child: Text(
                      '$characterCount/250',

                      style: TextStyle(
                        color:
                            secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: size.height * 0.02,
            ),

            // ==================================================
            // SEND TO ADMIN
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: size.height * 0.06,

              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),

                  elevation: 1,
                ),

                onPressed:
                    _isSending
                        ? null
                        : _emailToAdmin,

                child: _isSending
                    ? const SizedBox(
                        height: 24,
                        width: 24,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Send to Admin',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(
              height: size.height * 0.035,
            ),

            Divider(
              color: isDark
                  ? Colors.white24
                  : Colors.black12,
            ),

            SizedBox(
              height: size.height * 0.015,
            ),

            // ==================================================
            // OTHER WAYS
            // ==================================================

            Text(
              'Other Ways to Reach Us',

              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            SizedBox(
              height: size.height * 0.015,
            ),

            // ==================================================
            // EMAIL TILE
            // ==================================================

            InkWell(
              onTap: () => _openGmail(),

              borderRadius:
                  BorderRadius.circular(10),

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius:
                      BorderRadius.circular(10),

                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.email_outlined,
                      color: primaryRed,
                      size: 20,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        adminEmail,

                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // WHATSAPP TILE
            // ==================================================

            InkWell(
              onTap: _openWhatsApp,

              borderRadius:
                  BorderRadius.circular(10),

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius:
                      BorderRadius.circular(10),

                  border: Border.all(
                    color: isDark
                        ? Colors.white24
                        : Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.chat_outlined,
                      color: primaryRed,
                      size: 20,
                    ),

                    const SizedBox(width: 12),

                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'WhatsApp Support',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        Text(
                          '+92 309 3391591',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}