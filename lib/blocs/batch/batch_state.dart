import 'package:equatable/equatable.dart';
import 'package:profitara/models/batch.dart';

import '../../models/production_run.dart';

abstract class BatchState extends Equatable {
  @override
  List<Object> get props => [];
}

class BatchLoading extends BatchState {}

class BatchesLoaded extends BatchState {
  final List<Batch> batches;
  BatchesLoaded(this.batches);
  @override
  List<Object> get props => [batches];
}

class BatchError extends BatchState {
  final String message;
  BatchError(this.message);
  @override
  List<Object> get props => [message];
}

class ProductionRunsLoaded extends BatchState {
  final List<ProductionRun> runs;
  ProductionRunsLoaded(this.runs);
  @override
  List<Object> get props => [runs];
}
