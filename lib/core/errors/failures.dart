/// فئات الأخطاء والاستثناءات في التطبيق

/// فئة أساسية للأخطاء في طبقة البيانات
abstract class Failure {
  final String message;
  final int? code;
  
  const Failure({required this.message, this.code});
  
  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// فشل بسبب الخادم
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// فشل بسبب الاتصال بالشبكة
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code = -1});
}

/// فشل بسبب التخزين المحلي
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({required super.message, super.code});
}

/// فشل بسبب عدم الصلاحية
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code = 401});
}

/// فشل بسبب عدم العثور على العنصر
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code = 404});
}

/// فشل عام
class GeneralFailure extends Failure {
  const GeneralFailure({required super.message, super.code});
}

/// فشل بسبب التحقق من صحة البيانات
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 400});
}

/// استثناءات الطبقة الأساسية
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  
  const AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });
  
  @override
  String toString() => '$runtimeType: $message';
}

/// استثناء الخادم
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء الشبكة
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء قاعدة البيانات المحلية
class LocalDatabaseException extends AppException {
  const LocalDatabaseException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء المصادقة
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء العنصر غير موجود
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء التحقق من الصحة
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// استثناء عام
class GeneralException extends AppException {
  const GeneralException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}
