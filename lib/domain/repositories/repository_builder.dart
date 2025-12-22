import '../../data/datasource/api_account_data_source.dart';
import '../../data/datasource/api_support_data_source.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/support_repository_impl.dart';

import '../../domain/repositories/support_repository.dart';
import '../../presentation/helpers/logger.dart';
import '../patterns/decorators/logging_account_repository.dart';
import '../patterns/decorators/error_handling_account_repository.dart';
import '../patterns/decorators/caching_account_repository.dart';
import 'account_repository.dart';

class RepositoryBuilder {
  static AccountRepository buildAccountRepository() {
    final apiDataSource = ApiAccountDataSource();
    final baseRepository = AccountRepositoryImpl(dataSource: apiDataSource);

    AccountRepository decoratedRepository = ErrorHandlingAccountRepository(baseRepository);
    decoratedRepository = CachingAccountRepository(
      decoratedRepository,
      cacheDuration: const Duration(minutes: 10),
    );
    decoratedRepository = LoggingAccountRepository(decoratedRepository, Logger());

    return decoratedRepository;
  }

  static SupportRepositoryImpl buildSupportRepository() {
    final apiDataSource = ApiSupportDataSource();
    return SupportRepositoryImpl(dataSource: apiDataSource);
  }
}