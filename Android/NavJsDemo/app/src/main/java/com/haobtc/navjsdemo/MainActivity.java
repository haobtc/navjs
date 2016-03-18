package com.haobtc.navjsdemo;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.net.Uri;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends AppCompatActivity {
    //public String urlString;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        //Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        //setSupportActionBar(myToolbar);
        getSupportActionBar()

        WebView webView = (WebView)findViewById(R.id.content_webview);
        setupWebView(webView);
        //webView.loadUrl("https://haobtc.com");
        //Uri uri = getIntent().toUri(Intent.ACTION_VIEW);
        String urlString = getIntent().getStringExtra("xxxurl");
        if (urlString != null && !urlString.equals("")) {
            webView.loadUrl(urlString);
        } else {
            webView.loadUrl("file:///android_res/raw/index.html");
        }
    }

    protected void setupWebView(WebView webView) {
        final MainActivity self = this;
        webView.getSettings().setJavaScriptEnabled(true);
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Log.i("xxxxxx", "should override url " + url);
                if (url.startsWith("navjs://")) {
                    // NS
                    Uri uri = Uri.parse(url);
                    Log.i("Uri", uri.toString());
                    Map<String, List<String>> params = getUrlParams(uri.getQuery());
                    String urlString = params.get("u").get(0);
                    Intent intent = new Intent(self, MainActivity.class);
                    intent.putExtra("xxxurl", urlString);
                    startActivity(intent);
                    return true;
                }
                //view.loadUrl(url);

                return false;
            }
        });
    }

    public static Map<String, List<String>> getUrlParams(String query) {
        Map<String, List<String>> params = new HashMap<String, List<String>>();
        try {
            for (String param : query.split("&")) {
                String pair[] = param.split("=");
                String key = URLDecoder.decode(pair[0], "UTF-8");
                String value = "";
                if (pair.length > 1) {
                    value = URLDecoder.decode(pair[1], "UTF-8");
                }
                List<String> values = params.get(key);
                if (values == null) {
                    values = new ArrayList<String>();
                    params.put(key, values);
                }
                values.add(value);
            }
        } catch(UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return params;
    }

}
