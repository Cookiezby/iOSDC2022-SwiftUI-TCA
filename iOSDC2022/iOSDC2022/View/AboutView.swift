import SwiftUI
import WebKit

#if os(iOS)
struct WebView : UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    
}
#endif

#if os(macOS)
struct WebView : NSViewRepresentable {
    let request: URLRequest
    var webView: WKWebView?
    init(request: URLRequest) {
        self.request = request
        self.webView = WKWebView()
    }
    
    func makeNSView(context: Context) -> WKWebView  {
        return webView!
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        webView?.load(request)
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
}

#endif
struct AboutView: View {
    let webView = WebView(request: URLRequest(url: URL(string: "https://iosdc.jp/2022/")!))
    var body: some View {
            webView
            .toolbar {
                Button {
                    webView.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                }
                Button {
                    webView.goForward()
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
