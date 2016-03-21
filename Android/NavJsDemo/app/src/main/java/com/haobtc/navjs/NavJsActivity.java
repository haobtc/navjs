package com.haobtc.navjs;

import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.net.Uri;
import android.support.v7.widget.Toolbar;
import android.util.JsonReader;
import android.util.JsonToken;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;
import com.haobtc.navjsdemo.R;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NavJsActivity extends AppCompatActivity {
    public static final String PARAM_URL = "com.haobtc.navjs.IndentParam.URL";
    public static final String PARAM_TITLE = "com.haobtc.navjs.IndentParam.TITLE";

    NavJsWebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //setContentView(R.layout.activity_main);

        mWebView = new NavJsWebView(this);
        setContentView(mWebView);
        final NavJsActivity self = this;

        mWebView.setClient(new NavJsClient(){
            @Override
            public void onOpenUrl(NavJsWebView webView, String urlString, BridgeParams params) {
                self.openUrl(webView, urlString, params);
            }

            @Override
            public void onEvent(NavJsWebView webView, String action, BridgeParams params) {
                self.onEvent(webView, action, params);
            }

            @Override
            public void onPageTitleChanged(NavJsWebView webView, String title) {
                self.setTitle(title);
            }
        });

        String pageTitle = getIntent().getStringExtra(PARAM_TITLE);
        if(pageTitle != null && !pageTitle.equals("")) {
            setTitle(pageTitle);
        }
        //Uri uri = getIntent().toUri(Intent.ACTION_VIEW);
        String urlString = getIntent().getStringExtra(PARAM_URL);
        if (urlString != null && !urlString.equals("")) {
            ActionBar actionBar = getSupportActionBar();
            actionBar.setDisplayHomeAsUpEnabled(true);
            mWebView.loadUrl(urlString);
        } else {
            mWebView.loadUrl("file:///android_res/raw/index.html");
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
        }
        return false;
    }


    protected void openUrl(NavJsWebView webView, String urlString, BridgeParams params) {
        Intent intent = new Intent(this, this.getActivityClass(urlString));
        intent.putExtra(PARAM_URL, urlString);
        String title = params.get("title");
        if (title != null) {
            intent.putExtra(PARAM_TITLE, title);
        }
        startActivity(intent);
    }

    public void onEvent(NavJsWebView webView, String action, BridgeParams params) {
        // TODO: add event handlers
        Log.i("RECEIVENAVJS", action + " " + params);
    }

    // Overridable
    public Class getActivityClass(String urlString) {
        return this.getClass();
    }
}
