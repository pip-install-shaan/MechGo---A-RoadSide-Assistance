import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'payment_bloc.dart';
import 'payment_event.dart';
import 'payment_model.dart';
import 'payment_repo.dart';
import 'payment_state.dart';

class UserPaymentMethod
    extends StatelessWidget {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final double amount;

  const UserPaymentMethod({
    super.key,
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentBloc(
        repository: PaymentRepository(),
      )..add(
          LoadPayment(
            requestId: requestId,
          ),
        ),
      child: _PaymentView(
        requestId: requestId,
        mechanicId: mechanicId,
        mechanicName: mechanicName,
        amount: amount,
      ),
    );
  }
}

class _PaymentView
    extends StatefulWidget {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final double amount;

  const _PaymentView({
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.amount,
  });

  @override
  State<_PaymentView> createState() =>
      _PaymentViewState();
}

class _PaymentViewState
    extends State<_PaymentView> {
  final Color primaryRed =
      const Color.fromARGB(
    255,
    198,
    24,
    11,
  );

  PaymentMethod? selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),

      body: BlocConsumer<PaymentBloc,
          PaymentState>(
        listener: (context, state) {
          if (state.status ==
              PaymentStateStatus.failure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Payment failed.',
                ),
              ),
            );
          }

          if (state.status ==
              PaymentStateStatus.success) {
            if (state.payment != null &&
                state.payment!.status ==
                    PaymentStatus.pending) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cash payment selected. Complete payment with the mechanic.',
                  ),
                ),
              );
            }
          }
        },

        builder: (context, state) {
          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // PAYMENT SUMMARY
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08),
                        blurRadius: 10,
                        offset:
                            const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons
                            .account_balance_wallet,
                        size: 45,
                        color:
                            Colors.green,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        'Amount to Pay',
                        style: TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'PKR ${widget.amount.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'Mechanic: ${widget.mechanicName}',
                        style:
                            const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==================================================
                // JAZZCASH
                // ==================================================

                _paymentCard(
                  context: context,
                  method:
                      PaymentMethod.jazzCash,
                  icon:
                      Icons.account_balance_wallet,
                  title: 'JazzCash',
                  subtitle:
                      'Pay using JazzCash',
                ),

                // ==================================================
                // EASYPAISA
                // ==================================================

                _paymentCard(
                  context: context,
                  method:
                      PaymentMethod.easyPaisa,
                  icon:
                      Icons.account_balance_wallet,
                  title: 'Easypaisa',
                  subtitle:
                      'Pay using Easypaisa',
                ),

                // ==================================================
                // CARD
                // ==================================================

                _paymentCard(
                  context: context,
                  method:
                      PaymentMethod.card,
                  icon: Icons.credit_card,
                  title:
                      'Debit / Credit Card',
                  subtitle:
                      'Pay securely using your card',
                ),

                // ==================================================
                // CASH
                // ==================================================

                _paymentCard(
                  context: context,
                  method:
                      PaymentMethod.cash,
                  icon: Icons.payments,
                  title: 'Cash',
                  subtitle:
                      'Pay the mechanic in cash',
                ),

                const SizedBox(
                  height: 25,
                ),

                if (selectedMethod != null)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryRed,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      onPressed:
                          state.status ==
                                  PaymentStateStatus
                                      .processing
                              ? null
                              : () {
                                  context
                                      .read<
                                          PaymentBloc>()
                                      .add(
                                    CreatePayment(
                                      requestId:
                                          widget
                                              .requestId,
                                      mechanicId:
                                          widget
                                              .mechanicId,
                                      mechanicName:
                                          widget
                                              .mechanicName,
                                      amount:
                                          widget
                                              .amount,
                                      method:
                                          selectedMethod!,
                                    ),
                                  );
                                },
                      child:
                          state.status ==
                                  PaymentStateStatus
                                      .processing
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                )
                              : Text(
                                  selectedMethod ==
                                          PaymentMethod
                                              .cash
                                      ? 'Confirm Cash Payment'
                                      : 'Continue to Payment',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _paymentCard({
    required BuildContext context,
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected =
        selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });

        context.read<PaymentBloc>().add(
              SelectPaymentMethod(
                method: method,
              ),
            );
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
            const EdgeInsets.all(16),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? primaryRed
                : Colors.grey.shade300,
            width: selected
                ? 2
                : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  primaryRed
                      .withOpacity(0.1),
              child: Icon(
                icon,
                color: primaryRed,
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Radio<PaymentMethod>(
              value: method,
              groupValue:
                  selectedMethod,
              activeColor:
                  primaryRed,
              onChanged:
                  (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedMethod =
                      value;
                });

                context
                    .read<
                        PaymentBloc>()
                    .add(
                      SelectPaymentMethod(
                        method: value,
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}