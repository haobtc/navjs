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

    WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //setContentView(R.layout.activity_main);

        //WebView webView = (WebView) findViewById(R.id.content_webview);
        mWebView = new WebView(this);
        setContentView(mWebView);
        setupWebView(mWebView);

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

    protected void setupWebView(WebView webView) {
        final NavJsActivity self = this;
        webView.getSettings().setJavaScriptEnabled(true);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                // Set title
                view.evaluateJavascript("document.title",
                        new ValueCallback<String>() {
                            @Override
                            public void onReceiveValue(String value) {
                                JsonReader reader = new JsonReader(new StringReader(value));
                                reader.setLenient(true);
                                try {
                                    if (reader.peek() != JsonToken.NULL) {
                                        if (reader.peek() == JsonToken.STRING) {
                                            String title = reader.nextString();
                                            self.setTitle(title);
                                        }
                                    }
                                } catch (IOException e) {
                                    Log.e("TAG", "MainActivity IOException", e);
                                }
                            }
                        });

                // load bootstrap
                try {
                    //String bootstrap = self.readUrl("file:///android_res/raw/index.html");
                    String bootstrap = self.readRawResource(R.raw.navjs_bootstrap);
                    Log.i("Bootstrap", bootstrap);
                    view.evaluateJavascript(bootstrap, null);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("navjs://")) {
                    // NS
                    Uri uri = Uri.parse(url);
                    List<String> cmds = uri.getPathSegments();

                    Log.i("Uri", uri.toString());
                    BridgeParams params = new BridgeParams();
                    params.decodeQuery(uri.getQuery());
                    if (cmds.size() >= 2) {
                        String obj = cmds.get(0);
                        String action = cmds.get(1);
                        if (obj.equals("url") && action.equals("open")) {
                            self.openUrl(params);
                        } else if (obj.equals("console") && action.equals("log")) {
                            Log.i("NavJsConsole", params.get("msg"));
                        } else if (obj.equals("event")) {
                            self.onEvent(action, params);
                        }
                    }
                    return true;
                }
                return false;
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage msg) {
                Log.i("NavJsConsole", msg.messageLevel() + " " + msg.message());
                return true;
            }
        });
    } // End of setupWebView

    protected void openUrl(BridgeParams params) {
        String urlString = params.get("href");
        if (urlString != null) {
            Intent intent = new Intent(this, this.getActivityClass(urlString));
            intent.putExtra(PARAM_URL, urlString);
            String title = params.get("title");
            if (title != null) {
                intent.putExtra(PARAM_TITLE, title);
            }
            startActivity(intent);
        }
    }

    public void onEvent(String action, BridgeParams params) {
        // TODO: add event handlers
        Log.i("RECEIVENAVJS", action + " " + params);
    }

    public void sendEvent(String action, BridgeParams params) {
        String json = params.encodeJson();
        mWebView.evaluateJavascript("navjs.dispatch(\'" + action + "\'," + json + ")", null);
    }

    public String readRawResource(int rawId) throws MalformedURLException, IOException {
        BufferedReader in = new BufferedReader(new InputStreamReader(getResources().openRawResource(rawId)));
        StringWriter writer = new StringWriter();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            writer.append(inputLine).append("\n");
        }
        in.close();
        return writer.toString();
    }

    // Overridable
    public Class getActivityClass(String urlString) {
        return this.getClass();
    }
}
