import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/User/Payment/payment_event.dart';
import 'package:mech_go/User/Payment/payment_model.dart';
import 'package:mech_go/User/Payment/payment_repo.dart';
import 'package:mech_go/User/Payment/payment_state.dart';


class PaymentBloc
    extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  StreamSubscription<PaymentModel?>?
      _paymentSubscription;

  PaymentBloc({
    required PaymentRepository repository,
  })  : _repository = repository,
        super(
          const PaymentState(),
        ) {
    on<LoadPayment>(
      _onLoadPayment,
    );

    on<SelectPaymentMethod>(
      _onSelectPaymentMethod,
    );

    on<CreatePayment>(
      _onCreatePayment,
    );

    on<ConfirmCashPayment>(
      _onConfirmCashPayment,
    );

    on<PaymentUpdated>(
      _onPaymentUpdated,
    );

    on<PaymentFailed>(
      _onPaymentFailed,
    );

    on<PaymentNotFound>(
  _onPaymentNotFound,
   );
  }

  // ==========================================================
  // LOAD PAYMENT
  // ==========================================================

  Future<void> _onLoadPayment(
    LoadPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PaymentStateStatus.loading,
        clearError: true,
      ),
    );

    await _paymentSubscription?.cancel();

    _paymentSubscription =
        _repository
            .watchPayment(event.requestId)
            .listen(
      (payment) {
        if (payment != null) {
          add(
            PaymentUpdated(payment),
          );
        } else {
          emit(
            state.copyWith(
              status: PaymentStateStatus.ready,
              clearError: true,
            ),
          );
        }
      },
      onError: (error) {
        add(
          PaymentFailed(
            error.toString(),
          ),
        );
      },
    );
  }
  

  void _onPaymentNotFound(
  PaymentNotFound event,
  Emitter<PaymentState> emit,
) {
  emit(
    state.copyWith(
      status: PaymentStateStatus.ready,
      clearError: true,
    ),
  );
}

  // ==========================================================
  // SELECT METHOD
  // ==========================================================

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<PaymentState> emit,
  ) {
    emit(
      state.copyWith(
        status: PaymentStateStatus.ready,
        selectedMethod: event.method,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // CREATE PAYMENT
  // ==========================================================

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            PaymentStateStatus.processing,
        clearError: true,
        clearCheckoutUrl: true,
      ),
    );

    try {
      // CASH
      if (event.method ==
          PaymentMethod.cash) {
        final payment =
            await _repository
                .createCashPayment(
          requestId: event.requestId,
          mechanicId: event.mechanicId,
          mechanicName: event.mechanicName,
          amount: event.amount,
        );

        emit(
          state.copyWith(
            status:
                PaymentStateStatus.success,
            payment: payment,
            selectedMethod:
                PaymentMethod.cash,
            clearError: true,
          ),
        );

        return;
      }

      // ONLINE PAYMENT
      final checkoutUrl =
          await _repository
              .createOnlinePayment(
        requestId: event.requestId,
        mechanicId: event.mechanicId,
        mechanicName: event.mechanicName,
        amount: event.amount,
        method: event.method,
      );

      emit(
        state.copyWith(
          status:
              PaymentStateStatus.success,
          selectedMethod: event.method,
          checkoutUrl: checkoutUrl,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              PaymentStateStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // CASH
  // ==========================================================

  Future<void> _onConfirmCashPayment(
    ConfirmCashPayment event,
    Emitter<PaymentState> emit,
  ) async {
    add(
      CreatePayment(
        requestId: event.requestId,
        mechanicId: event.mechanicId,
        mechanicName: event.mechanicName,
        amount: event.amount,
        method: PaymentMethod.cash,
      ),
    );
  }

  // ==========================================================
  // PAYMENT UPDATED
  // ==========================================================

  void _onPaymentUpdated(
    PaymentUpdated event,
    Emitter<PaymentState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            PaymentStateStatus.success,
        payment: event.payment,
        selectedMethod:
            event.payment.method,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // PAYMENT FAILED
  // ==========================================================

  void _onPaymentFailed(
    PaymentFailed event,
    Emitter<PaymentState> emit,
  ) {
    emit(
      state.copyWith(
        status:
            PaymentStateStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  // ==========================================================
  // CLOSE
  // ==========================================================

  @override
  Future<void> close() async {
    await _paymentSubscription?.cancel();

    return super.close();
  }
}