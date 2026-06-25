abstract class UseCase<TypeOut, Params> {
  Future<TypeOut> call(Params params);
}

class NoParams {}
