import 'package:flutter_test/flutter_test.dart';
import 'package:campusflowstu/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    expect(const CampusFlowApp(), isNotNull);
  });
}
