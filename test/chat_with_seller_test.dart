import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/chat_message.dart';
import 'package:trentify/model/demodb.dart';
import 'package:trentify/screens/chat/product_chat_page.dart';

// 1x1 transparent PNG
final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = _MockHttpClient();
  return client;
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Chat with Seller Feature Tests', () {
    test('ChatMessage model holds product inquiry metadata accurately', () {
      const inquiry = ProductInquiryData(
        title: 'Urban Blend Long Sleeve Shirt',
        price: 185.0,
        imageUrl: 'https://example.com/shirt.jpg',
        selectedSize: 'M',
        selectedColor: 'Black',
      );

      final message = ChatMessage(
        id: 'msg_001',
        senderId: 'user_1',
        senderName: 'Customer',
        text: 'Is this available in size M?',
        timestamp: DateTime.now(),
        isMe: true,
        productCard: inquiry,
        status: MessageStatus.sent,
      );

      expect(message.isMe, isTrue);
      expect(message.productCard?.selectedSize, 'M');
      expect(message.productCard?.selectedColor, 'Black');
      expect(message.productCard?.price, 185.0);
    });

    test('3-Language Localizations support chat keys', () {
      final en = AppLocalizations(const Locale('en'));
      expect(en.translate('chat_with_seller'), 'Chat with Seller');
      expect(en.translate('ask_seller_placeholder'), 'Ask seller about this item...');
      expect(en.translate('seller_information'), 'Seller Information');

      final km = AppLocalizations(const Locale('km'));
      expect(km.translate('chat_with_seller'), 'ជជែកជាមួយអ្នកលក់');
      expect(km.translate('seller_information'), 'ព័ត៌មានអ្នកលក់');

      final vi = AppLocalizations(const Locale('vi'));
      expect(vi.translate('chat_with_seller'), 'Trò chuyện với người bán');
      expect(vi.translate('seller_information'), 'Thông tin người bán');
    });

    testWidgets('ProductChatPage renders seller header, pinned product card and suggestions', (tester) async {
      final productData = DemoDb.productDetailById('ubl-ss-001')!;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          home: ProductChatPage(
            product: productData,
            selectedSize: 'M',
            selectedColor: 'Black',
          ),
        ),
      );

      await tester.pump();

      // Check header info
      expect(find.text('Maison Trentify Studio'), findsOneWidget);
      expect(find.text('Online • Replies in minutes'), findsOneWidget);

      // Check pinned product summary banner
      expect(find.text('Urban Blend Long Sleeve Shirt'), findsWidgets);
      expect(find.text('Send Item'), findsOneWidget);

      // Check suggestion chips
      expect(find.textContaining('Is size M in stock?'), findsOneWidget);
    });
  });
}
