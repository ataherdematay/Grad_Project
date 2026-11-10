import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Banka dönüşünden sonra sunucunun gösterdiği bitiş sayfasının yolu.
const String kThreeDsDonePath = '/api/payments/3ds/done';

/// Adres bitiş sayfası mı? Yalnız yola bakılır; sonucu her durumda sunucu
/// (`GET /payments/{ref}`) belirler, bu yüzden sahte bir adres hiçbir şey
/// kazandırmaz.
bool isThreeDsDoneUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.path.endsWith(kThreeDsDonePath);
}

/// `NavigationDelegate.onNavigationRequest` mantığı. Bitiş adresinde gezinmeyi
/// engeller ve [onDone]yu bir kez çağırır; diğer adreslere izin verir.
NavigationDecision threeDsNavigationDecision(String url, VoidCallback onDone) {
  if (isThreeDsDoneUrl(url)) {
    onDone();
    return NavigationDecision.prevent;
  }
  return NavigationDecision.navigate;
}

/// Banka formunu çizen widget'ın üreticisi; testlerde sahtesi verilir.
typedef ThreeDsViewBuilder = Widget Function(
  BuildContext context,
  String html,
  VoidCallback onDone,
);

final threeDsViewBuilderProvider = Provider<ThreeDsViewBuilder>(
  (ref) =>
      (context, html, onDone) => ThreeDsWebView(html: html, onDone: onDone),
);

/// `webview_flutter` ile banka formu: `loadHtmlString(html, baseUrl: null)`.
class ThreeDsWebView extends StatefulWidget {
  const ThreeDsWebView({super.key, required this.html, required this.onDone});

  final String html;
  final VoidCallback onDone;

  @override
  State<ThreeDsWebView> createState() => _ThreeDsWebViewState();
}

class _ThreeDsWebViewState extends State<ThreeDsWebView> {
  late final WebViewController _controller;
  var _finished = false;

  void _done() {
    if (_finished) return;
    _finished = true;
    widget.onDone();
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              threeDsNavigationDecision(request.url, _done),
          // Sunucu yönlendirmeleri istek olarak gelmeyebilir: adres
          // değişince de bitiş sayfası yakalanır.
          onUrlChange: (change) {
            final url = change.url;
            if (url != null && isThreeDsDoneUrl(url)) _done();
          },
        ),
      )
      ..loadHtmlString(widget.html, baseUrl: null);
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}
