import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pain_record.dart';
import '../repositories/pain_repository.dart';

class GetPainHistory extends UseCaseNoParams<List<PainRecord>> {
  final PainRepository repository;
  GetPainHistory(this.repository);

  @override
  Future<Either<Failure, List<PainRecord>>> call() {
    return repository.getPainHistory();
  }
}
