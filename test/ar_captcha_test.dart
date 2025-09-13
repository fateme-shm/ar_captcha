import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_captcha/ar_captcha.dart';

/// A fake controller to capture callback events without
/// depending on WebView/JS execution.
class FakeArCaptchaController extends ArCaptchaController {
  FakeArCaptchaController() : super(siteKey: 'FAKE_KEY');

  bool showCalled = false;

  @override
  Future<String?> showCaptcha({
    required BuildContext context,
    CaptchaType mode = CaptchaType.dialog,
    required Function(String token) onSuccess,
    required Function(String error) onError,
  }) async {
    showCalled = true;

    // Simulate success callback with fake token
    onSuccess('fake_token_123');

    // Return the same token as the Future result
    return Future.value('fake_token_123');
  }
}

void main() {
  testWidgets('Tapping button opens captcha and triggers success', (
    WidgetTester tester,
  ) async {
    final fakeController = FakeArCaptchaController();

    String? receivedToken;

    // Test widget
    final widget = MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await fakeController.showCaptcha(
                context: tester.element(find.byType(ElevatedButton)),
                mode: CaptchaType.dialog,
                onSuccess: (token) {
                  receivedToken = token;
                },
                onError: (error) {},
              );
            },
            child: const Text("Show Captcha"),
          ),
        ),
      ),
    );

    await tester.pumpWidget(widget);

    // Verify button exists
    expect(find.text("Show Captcha"), findsOneWidget);

    // Tap button
    await tester.tap(find.text("Show Captcha"));
    await tester.pumpAndSettle();

    // Verify fakeController was called
    expect(fakeController.showCalled, isTrue);

    // Verify the fake token callback was triggered
    expect(receivedToken, equals('fake_token_123'));
  });
}
