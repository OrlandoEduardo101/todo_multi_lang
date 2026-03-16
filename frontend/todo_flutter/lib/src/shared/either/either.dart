sealed class Either<L, R> {
  const Either();

  const factory Either.left(L value) = Left<L, R>;

  const factory Either.right(R value) = Right<L, R>;

  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    if (this is Left<L, R>) {
      return leftFn((this as Left<L, R>).value);
    } else if (this is Right<L, R>) {
      return rightFn((this as Right<L, R>).value);
    }
    throw Exception('Invalid Either type');
  }

  bool isLeft() => this is Left<L, R>;

  bool isRight() => this is Right<L, R>;

  L? getLeft() => this is Left<L, R> ? (this as Left<L, R>).value : null;

  R? getRight() => this is Right<L, R> ? (this as Right<L, R>).value : null;
}

class Left<L, R> implements Either<L, R> {
  const Left(this.value);
  final L value;

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(value);
  }

  @override
  L? getLeft() {
    return value;
  }

  @override
  R? getRight() {
    return null;
  }

  @override
  bool isLeft() {
    return true;
  }

  @override
  bool isRight() {
    return false;
  }
}

class Right<L, R> implements Either<L, R> {
  const Right(this.value);
  final R value;

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(value);
  }

  @override
  L? getLeft() {
    return null;
  }

  @override
  R? getRight() {
    return value;
  }

  @override
  bool isLeft() {
    return false;
  }

  @override
  bool isRight() {
    return true;
  }
}
