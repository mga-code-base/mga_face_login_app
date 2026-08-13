import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mga_face_login_app/screens/auth/admin_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> _pumpAdminLoginPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AdminLoginPage()));
    await tester.pumpAndSettle();
  }

  group('AdminLoginPage — username "admin" is blocked before any login attempt', () {
    testWidgets('shows the restriction message and does not show a loading spinner', (tester) async {
      await _pumpAdminLoginPage(tester);

      await tester.enterText(find.byType(TextField).first, 'admin');
      await tester.enterText(find.byType(TextField).last, 'anypassword');
      await tester.tap(find.text('Authenticate'));
      await tester.pump();

      expect(find.text('Super Admin Login Restricted on this App'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('is case-sensitive — "Admin" is not blocked by this check', (tester) async {
      await _pumpAdminLoginPage(tester);

      await tester.enterText(find.byType(TextField).first, 'Admin');
      await tester.enterText(find.byType(TextField).last, 'anypassword');
      await tester.tap(find.text('Authenticate'));
      await tester.pump();

      expect(find.text('Super Admin Login Restricted on this App'), findsNothing);
    });

    testWidgets('leading/trailing whitespace around "admin" is still blocked', (tester) async {
      await _pumpAdminLoginPage(tester);

      await tester.enterText(find.byType(TextField).first, '  admin  ');
      await tester.enterText(find.byType(TextField).last, 'anypassword');
      await tester.tap(find.text('Authenticate'));
      await tester.pump();

      expect(find.text('Super Admin Login Restricted on this App'), findsOneWidget);
    });

    testWidgets('the empty-fields check still runs before the admin check', (tester) async {
      await _pumpAdminLoginPage(tester);

      await tester.tap(find.text('Authenticate'));
      await tester.pump();

      expect(find.text('Please fill out all fields.'), findsOneWidget);
      expect(find.text('Super Admin Login Restricted on this App'), findsNothing);
    });
  });
}