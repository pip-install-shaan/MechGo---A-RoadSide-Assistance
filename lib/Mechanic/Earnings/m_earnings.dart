import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/Earnings/earning_bloc.dart';
import 'package:mech_go/Mechanic/Earnings/earning_event.dart';
import 'package:mech_go/Mechanic/Earnings/earning_state.dart';


class MechanicEarnings extends StatefulWidget {
  const MechanicEarnings({super.key});

  @override
  State<MechanicEarnings> createState() => _MechanicEarningsState();
}

class _MechanicEarningsState extends State<MechanicEarnings> {
  final Color primaryRed = const Color.fromARGB(255, 198, 24, 11);

  String selectedPeriod = 'Monthly';


  void changePeriod(String period) {
    setState(() {
      selectedPeriod = period;
    });
  }

  /// Returns earnings according to selected period.
  List<Map<String, dynamic>> _getFilteredEarnings(
    List<Map<String, dynamic>> earnings,
  ) {
    final now = DateTime.now();

    DateTime startDate;

    if (selectedPeriod == 'Daily') {
      startDate = DateTime(
        now.year,
        now.month,
        now.day,
      );
    } else if (selectedPeriod == 'Weekly') {
      // Monday is the first day of the week.
      final daysFromMonday = now.weekday - 1;

      startDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(days: daysFromMonday),
      );
    } else {
      // Monthly
      startDate = DateTime(
        now.year,
        now.month,
        1,
      );
    }

    return earnings.where((earning) {
      final DateTime? date =
          earning['completedAt'] as DateTime? ??
          earning['createdAt'] as DateTime?;

      if (date == null) {
        return false;
      }

      return !date.isBefore(startDate) &&
          date.isBefore(
            DateTime(
              now.year,
              now.month,
              now.day,
            ).add(
              const Duration(days: 1),
            ),
          );
    }).toList();
  }

  /// Calculates total earnings for selected period.
  double _calculateTotal(
    List<Map<String, dynamic>> earnings,
  ) {
    double total = 0;

    for (final earning in earnings) {
      final amount = earning['amount'];

      if (amount is num) {
        total += amount.toDouble();
      } else {
        total += double.tryParse(
              amount?.toString() ?? '0',
            ) ??
            0;
      }
    }

    return total;
  }

  String _formatAmount(double amount) {
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '--';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  String _getPeriodTitle() {
    if (selectedPeriod == 'Daily') {
      return 'Today';
    }

    if (selectedPeriod == 'Weekly') {
      return 'This Week';
    }

    return 'This Month';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: primaryRed,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        centerTitle: true,

        title: const Text(
          'Earnings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 15,
          ),

          child: Column(
            children: [
              // ----------------------------------------------------------
              // PERIOD SELECTOR
              // ----------------------------------------------------------

              Container(
                height: 48,

                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: periodButton(
                        title: 'Daily',
                        isSelected:
                            selectedPeriod == 'Daily',
                        onTap: () {
                          changePeriod('Daily');
                        },
                      ),
                    ),

                    Expanded(
                      child: periodButton(
                        title: 'Weekly',
                        isSelected:
                            selectedPeriod == 'Weekly',
                        onTap: () {
                          changePeriod('Weekly');
                        },
                      ),
                    ),

                    Expanded(
                      child: periodButton(
                        title: 'Monthly',
                        isSelected:
                            selectedPeriod == 'Monthly',
                        onTap: () {
                          changePeriod('Monthly');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ----------------------------------------------------------
              // BLOC
              // ----------------------------------------------------------

              Expanded(
                child: BlocBuilder<
                    MechanicEarningsBloc,
                    MechanicEarningsState>(
                  builder: (context, state) {
                    // ----------------------------------------------------
                    // LOADING
                    // ----------------------------------------------------

                    if (state.status ==
                        MechanicEarningsStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // ----------------------------------------------------
                    // FAILURE
                    // ----------------------------------------------------

                    if (state.status ==
                        MechanicEarningsStatus.failure) {
                      return Column(
                        children: [
                          const SizedBox(height: 50),

                          const Icon(
                            Icons.error_outline,
                            size: 55,
                            color: Colors.red,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Unable to load earnings',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              state.errorMessage ??
                                  'Something went wrong.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<MechanicEarningsBloc>()
                                  .add(
                                    const WatchMechanicEarnings(),
                                  );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              foregroundColor: Colors.white,
                            ),

                            child: const Text(
                              'Retry',
                            ),
                          ),
                        ],
                      );
                    }

                    // ----------------------------------------------------
                    // FILTER EARNINGS
                    // ----------------------------------------------------

                    final filteredEarnings =
                        _getFilteredEarnings(
                      state.earnings,
                    );

                    final total =
                        _calculateTotal(
                      filteredEarnings,
                    );

                    return Column(
                      children: [
                        // ------------------------------------------------
                        // TOTAL
                        // ------------------------------------------------

                        Text(
                          _formatAmount(total),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * 0.075,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          _getPeriodTitle(),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Divider(
                          thickness: 1,
                        ),

                        const SizedBox(height: 10),

                        // ----------------------------------------------
                        // EMPTY STATE
                        // ----------------------------------------------

                        if (filteredEarnings.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .account_balance_wallet_outlined,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),

                                  const SizedBox(height: 15),

                                  Text(
                                    'No earnings found',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'No completed requests for $_getPeriodTitle()'
                                        .replaceFirst(
                                      '$_getPeriodTitle()',
                                      _getPeriodTitle()
                                          .toLowerCase(),
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // ----------------------------------------------
                          // EARNINGS LIST
                          // ----------------------------------------------

                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  filteredEarnings.length,

                              itemBuilder:
                                  (context, index) {
                                final earning =
                                    filteredEarnings[index];

                                final DateTime? date =
                                    earning['completedAt']
                                        as DateTime? ??
                                    earning['createdAt']
                                        as DateTime?;

                                final String customerName =
                                    earning['userName']
                                            ?.toString() ??
                                        'Customer';

                                final double amount =
                                    earning['amount'] is num
                                        ? (earning['amount']
                                                as num)
                                            .toDouble()
                                        : double.tryParse(
                                              earning['amount']
                                                      ?.toString() ??
                                                  '0',
                                            ) ??
                                            0;

                                return Padding(
                                  padding:
                                      const EdgeInsets.all(12),

                                  child: Row(
                                    children: [
                                      // ------------------------------
                                      // DATE
                                      // ------------------------------

                                      SizedBox(
                                        width:
                                            size.width * 0.22,

                                        child: Text(
                                          _formatDate(date),

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.black87,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      // ------------------------------
                                      // CUSTOMER NAME
                                      // ------------------------------

                                      Expanded(
                                        child: Text(
                                          customerName,
                                          textAlign:
                                              TextAlign.center,

                                          overflow:
                                              TextOverflow.ellipsis,

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.black87,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),

                                      // ------------------------------
                                      // AMOUNT
                                      // ------------------------------

                                      SizedBox(
                                        width:
                                            size.width * 0.22,

                                        child: Text(
                                          _formatAmount(
                                            amount,
                                          ),

                                          textAlign:
                                              TextAlign.right,

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.black87,
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // ----------------------------------------------------------
              // WITHDRAWAL HISTORY
              // ----------------------------------------------------------

              GestureDetector(
                onTap: () {
                  // TODO:
                  // Navigate to Withdrawal History screen.
                },

                child: Container(
                  width: double.infinity,
                  height: 55,

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(12),

                    border: Border.all(
                      color: primaryRed,
                      width: 1.5,
                    ),
                  ),

                  child: Center(
                    child: Text(
                      'Withdrawal History',

                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // PERIOD BUTTON
  // ----------------------------------------------------------------------

  Widget periodButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),

        margin: const EdgeInsets.all(3),

        decoration: BoxDecoration(
          color: isSelected
              ? primaryRed
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(10),

          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        primaryRed.withOpacity(0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),

        child: Center(
          child: Text(
            title,

            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.black54,

              fontSize: 14,

              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}