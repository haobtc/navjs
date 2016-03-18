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
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;
import com.haobtc.navjsdemo.R;

import java.io.IOException;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NavJsActivity extends AppCompatActivity {
    public static final String PARAM_URL = "com.haobtc.navjs.IndentParam.URL";
    public static final String PARAM_TITLE = "com.haobtc.navjs.IndentParam.TITLE";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        WebView webView = (WebView) findViewById(R.id.content_webview);
        setupWebView(webView);

        String pageTitle = getIntent().getStringExtra(PARAM_TITLE);
        if(pageTitle != null && !pageTitle.equals("")) {
            setTitle(pageTitle);
        }
        //Uri uri = getIntent().toUri(Intent.ACTION_VIEW);
        String urlString = getIntent().getStringExtra(PARAM_URL);
        if (urlString != null && !urlString.equals("")) {
            ActionBar actionBar = getSupportActionBar();
            actionBar.setDisplayHomeAsUpEnabled(true);
            webView.loadUrl(urlString);
        } else {
            webView.loadUrl("file:///android_res/raw/index.html");
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
                view.evaluateJavascript("document.title",
                        new ValueCallback<String>() {
                            @Override
                            public void onReceiveValue(String value) {
                                JsonReader reader = new JsonReader(new StringReader(value));
                                reader.setLenient(true);
                                try {
                                    if(reader.peek() != JsonToken.NULL) {
                                        if(reader.peek() == JsonToken.STRING) {
                                            String title = reader.nextString();
                                            self.setTitle(title);
                                        }
                                    }
                                } catch(IOException e) {
                                    Log.e("TAG", "MainActivity IOException", e);
                                }


                            }
                        });
            }
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith("navjs://")) {
                    // NS
                    Uri uri = Uri.parse(url);
                    List<String> cmds = uri.getPathSegments();

                    Log.i("Uri", uri.toString());
                    Map<String, List<String>> params = getUrlParams(uri.getQuery());
                    if (cmds.size() == 2 && cmds.get(0).equals("url") && cmds.get(1).equals("open")) {
                        String urlString = params.get("u").get(0);
                        Intent intent = new Intent(self, self.getActivityClass(urlString));
                        intent.putExtra(PARAM_URL, urlString);
                        String title = params.get("title").get(0);
                        if (title != null) {
                            intent.putExtra(PARAM_TITLE, title);
                        }

                        startActivity(intent);
                    }
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
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return params;
    }

    // Overridable
    public Class getActivityClass(String urlString) {
        return  this.getClass();
    }
}
