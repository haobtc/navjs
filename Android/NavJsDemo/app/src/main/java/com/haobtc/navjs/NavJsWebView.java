package com.haobtc.navjs;

import android.content.Context;
import android.net.Uri;
import android.util.JsonReader;
import android.util.JsonToken;
import android.util.JsonWriter;
import android.util.Log;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.haobtc.navjsdemo.R;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.io.UnsupportedEncodingException;
import java.util.List;

/**
 * Created by zengke on 16/3/21.
 */
public class NavJsWebView extends WebView {

    private NavJsClient mClient;

    public NavJsWebView(Context context) {
        super(context);
        setUp();
    }

    public void setClient(NavJsClient client) {
        mClient = client;
    }

    protected void setUp() {
        final NavJsWebView self = this;
        this.getSettings().setJavaScriptEnabled(true);

        setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                // Set title
                if (mClient != null) {
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
                                                mClient.onPageTitleChanged(self, title);
                                            }
                                        }
                                    } catch (IOException e) {
                                        Log.e("TAG", "MainActivity IOException", e);
                                    }
                                }
                            });
                }

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
                            if (mClient != null && params.get("href") != null) {
                                mClient.onOpenUrl(self, params.get("href"), params);
                            }
                        } else if (obj.equals("console") && action.equals("log")) {
                            Log.i("NavJsConsole", params.get("msg"));
                        } else if (obj.equals("event")) {
                            if (mClient != null) {
                                mClient.onEvent(self, action, params);
                            }
                        }  else if (obj.equals("call")) {
                            if (mClient != null) {
                                String callId = cmds.get(2);
                                if (callId == null || callId.equals("")) {
                                    Log.w("Call", "No callId");
                                } else {
                                    mClient.onCall(self, action, callId, params);
                                }
                            }
                        }
                    }
                    return true;
                }
                return false;
            }
        });
    } // End of setUp

    protected String readRawResource(int rawId) throws IOException {
        BufferedReader in = new BufferedReader(new InputStreamReader(getResources().openRawResource(rawId)));
        StringWriter writer = new StringWriter();
        String inputLine;
        while ((inputLine = in.readLine()) != null) {
            writer.append(inputLine).append("\n");
        }
        in.close();
        return writer.toString();
    }

    public void sendEvent(String action, BridgeParams params) {
        String json = params.encodeJson();
        evaluateJavascript("navjs.dispatch(\'" + action + "\'," + json + ")", null);
    }

    public void callReturn(String callId, BridgeParams params) {
        String json = params.encodeJson();
        evaluateJavascript("navjs.callReturn(\'" + callId + "\'," + json + ")", null);
    }
}
