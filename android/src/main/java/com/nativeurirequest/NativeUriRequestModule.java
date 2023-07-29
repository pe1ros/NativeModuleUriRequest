package com.nativeurirequest;

import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

@ReactModule(name = NativeUriRequestModule.NAME)
public class NativeUriRequestModule extends ReactContextBaseJavaModule {
  public static final String NAME = "NativeUriRequest";

  public NativeUriRequestModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


  @ReactMethod
  public void makeRequest(ReadableMap params, Callback callback) {
    String url = params.getString("uri");
    String type = params.getString("type");
    ReadableMap body = params.getMap("body");
    ReadableMap incomingHeaders = params.getMap("headers");
    if (url == null) {
      callback.invoke(null, this.convertResultToDictionary("ERROR", 501, null, "PLEASE PROVIDE URI"));
      return;
    }
    if (type == null) {
      callback.invoke(null, this.convertResultToDictionary("ERROR", 501, null, "PLEASE PROVIDE TYPE"));
      return;
    }
    if (incomingHeaders == null) {
      callback.invoke(null, this.convertResultToDictionary("ERROR", 501, null, "PLEASE PROVIDE HEADERS"));
      return;
    }

    try {
      URL mUrl = new URL(url);
      HttpURLConnection httpConnection = (HttpURLConnection) mUrl.openConnection();
      ReadableMapKeySetIterator it = incomingHeaders.keySetIterator();
      while (it.hasNextKey()) {
        String key = it.nextKey();
        httpConnection.setRequestProperty(key, incomingHeaders.getString(key));
      }

      if (type.equals("GET")) {
        httpConnection.setRequestMethod("GET");
        try {
          BufferedReader br = new BufferedReader(new InputStreamReader(httpConnection.getInputStream()));
          String inputLine;
          StringBuffer response = new StringBuffer();
          while ((inputLine = br.readLine()) != null) {
            response.append(inputLine);
          }
          br.close();
          callback.invoke(convertResultToDictionary("SUCCESS", httpConnection.getResponseCode(), response.toString(), null), null);
        } catch (IOException e) {
          callback.invoke(null, convertResultToDictionary("ERROR", httpConnection.getResponseCode(), null, e.getLocalizedMessage()));
        } finally {
          if (httpConnection != null) {
            httpConnection.disconnect();
          }
        }
      } else if (type.equals("POST")) {
        if (body == null) {
          callback.invoke(null, convertResultToDictionary("ERROR", 501, null , "PLEASE PROVIDE BODY" ));
          return;
        }
        try {
          ReadableMapKeySetIterator iter = incomingHeaders.keySetIterator();
          httpConnection.setRequestMethod("POST");
          httpConnection.setDoOutput(true);
          BufferedWriter os = new BufferedWriter(new OutputStreamWriter(httpConnection.getOutputStream()));
          os.write(body.toString());
          os.flush();
          os.close();
          BufferedReader in = new BufferedReader(new InputStreamReader(httpConnection.getInputStream()));
          String inputLine;
          StringBuffer response = new StringBuffer();

          while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
          }
          in.close();
          callback.invoke(this.convertResultToDictionary("SUCCESS", 200, response.toString() , null ), null);

        } catch (IOException ex) {
          callback.invoke(null, this.convertResultToDictionary("ERROR", httpConnection.getResponseCode(), null, ex.getLocalizedMessage()));
        } finally {
          httpConnection.disconnect();
        }
      }
    } catch (IOException ex) {
      callback.invoke(null, this.convertResultToDictionary("ERROR", 500, null, "SOMETHING WAS WRONG"));
    }

  }

  public WritableMap convertResultToDictionary(String type, int statusCode, @Nullable String data, @Nullable String error) {
    WritableMap newMap = Arguments.createMap();
    newMap.putString("type", type);
    newMap.putInt("statusCode", statusCode);
    if (data != null) {
      newMap.putString("data", data);
    } else {
      newMap.putString("error", error);
    }
    return newMap;
  }
}

