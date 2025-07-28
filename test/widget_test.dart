// This is a basic test file that helps resolve the flutter test error
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_gallery/main.dart';

void main() {
  testWidgets('Vehicle Gallery app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VehicleGalleryApp());

    // Verify that our app starts.
    expect(find.text('Vehicle Gallery'), findsOneWidget);
  });
}