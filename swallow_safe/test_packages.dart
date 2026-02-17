import 'package:equatable/equatable.dart';

class TestClass extends Equatable {
  final String name;
  const TestClass(this.name);
  @override
  List<Object?> get props => [name];
}

void main() {
  print('Package test: OK');
  var t = TestClass('test');
  print(t);
}
