import 'package:equatable/equatable.dart';
import 'package:profitara/models/batch.dart';

abstract class BatchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadBatches extends BatchEvent {}

class AddBatch extends BatchEvent {
  final Batch batch;
  AddBatch(this.batch);
  @override
  List<Object> get props => [batch];
}

class StartProduction extends BatchEvent {
  final int batchId;
  final int multiplier;
  StartProduction(this.batchId, this.multiplier);
  @override
  List<Object> get props => [batchId, multiplier];
}

class LoadProductionRuns extends BatchEvent {}

class UpdateActualSold extends BatchEvent {
  final int runId;
  final int actualSold;
  UpdateActualSold(this.runId, this.actualSold);
  @override
  List<Object> get props => [runId, actualSold];
}
