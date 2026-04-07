import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateStatistics extends StatisticsEvent {}
