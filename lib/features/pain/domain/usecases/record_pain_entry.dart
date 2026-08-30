import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pain_record.dart';
import '../repositories/pain_repository.dart';

class RecordPainEntry extends UseCase<String, PainRecord> {
  final PainRepository repository;
  RecordPainEntry(this.repository);

  @override
  Future<Either<Failure, String>> call(PainRecord params) {
    return repository.recordPainEntry(params);
  }
}
