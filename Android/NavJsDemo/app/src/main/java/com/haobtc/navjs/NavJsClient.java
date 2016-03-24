package com.haobtc.navjs;

/**
 * Created by zengke on 16/3/21.
 */
public class NavJsClient {
    public void onPageTitleChanged(NavJsWebView webView, String title) {}
    public void onOpenUrl(NavJsWebView webView, String urlString, BridgeParams params){}
    public void onEvent(NavJsWebView webView, String action, BridgeParams params) {}
    public void onCall(NavJsWebView webView, String action, String callId, BridgeParams params) {}
}
