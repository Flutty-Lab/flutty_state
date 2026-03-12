part of 'submit_cubit.dart';

sealed class SubmitState extends Equatable {
  const SubmitState();

  @override
  List<Object> get props => [];
}

class SubmitInitial extends SubmitState {}

class Submitting extends SubmitState {}

class SubmitSucceed extends SubmitState {
  const SubmitSucceed(this.successMessage);

  final String successMessage;

  @override
  List<Object> get props => [successMessage];
}

class SubmitFailed extends SubmitState {
  const SubmitFailed(this.failedMessage, {this.exception});

  final String failedMessage;
  final dynamic exception;

  @override
  List<Object> get props => [failedMessage];
}
