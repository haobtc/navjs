package com.haobtc.navjs;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by zengke on 16/3/20.
 */
public class BridgeParams {
    protected Map<String, List<String>> params = new HashMap<String, List<String>>();

    public void add(String key, String value) {
        List<String> s = params.get(key);
        if(s == null) {
            s = new ArrayList<String>();
            params.put(key, s);
        }
        s.add(value);
    }

    public String get(String key) {
        List<String> s = params.get(key);
        if (s == null) {
            return null;
        } else {
            return s.get(0);
        }
    }

    public List<String> getList(String key) {
        return params.get(key);
    }

    public void decodeQuery(String query) {
        try {
            for (String param : query.split("&")) {
                String pair[] = param.split("=");
                String key = URLDecoder.decode(pair[0], "UTF-8");
                String value = "";
                if (pair.length > 1) {
                    value = URLDecoder.decode(pair[1], "UTF-8");
                }
                add(key, value);
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

}
