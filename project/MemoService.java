package com.alhaj.almudhakira;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.ContextWrapper;
import android.speech.tts.TextToSpeech;
import org.json.JSONArray;
import java.util.ArrayList;
import java.util.Locale;

public class MemoService extends ContextWrapper {
    private static final String PREFS = "almudhakira_service";
    private static final String CLIP = "clipboard_history";
    private static final String FAV = "favorites";
    private final Context host;
    private TextToSpeech tts;

    public MemoService(Context base) { super(base); host = base; }

    private ArrayList<String> readList(String key) {
        ArrayList<String> out = new ArrayList<>();
        try {
            String raw = host.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(key, "[]");
            JSONArray a = new JSONArray(raw);
            for (int i=0; i<a.length(); i++) out.add(a.optString(i, ""));
        } catch (Exception ignored) {}
        return out;
    }

    private void writeList(String key, ArrayList<String> list) {
        try {
            JSONArray a = new JSONArray();
            for (String s : list) a.put(s == null ? "" : s);
            host.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putString(key, a.toString()).apply();
        } catch (Exception ignored) {}
    }

    public ArrayList<String> getClipboardList() { return readList(CLIP); }
    public ArrayList<String> getFavoritesList() { return readList(FAV); }

    public void copy(String text) {
        String value = text == null ? "" : text;
        try {
            ClipboardManager cm=(ClipboardManager)host.getSystemService(Context.CLIPBOARD_SERVICE);
            if (cm != null) cm.setPrimaryClip(ClipData.newPlainText("المذكرة الذكية", value));
        } catch(Exception ignored){}
        ArrayList<String> list=readList(CLIP); list.add(0,value); writeList(CLIP,list);
    }

    public void paste(String text) {
        String value=text==null?"":text;
        try {
            ClipboardManager cm=(ClipboardManager)host.getSystemService(Context.CLIPBOARD_SERVICE);
            if(cm!=null) cm.setPrimaryClip(ClipData.newPlainText("المذكرة الذكية",value));
        } catch(Exception ignored){}
    }

    public void clearClipboard(){ writeList(CLIP,new ArrayList<String>()); }
    public void addFavorites(String text){ ArrayList<String> l=readList(FAV); l.add(0,text==null?"":text); writeList(FAV,l); }
    public void clearFavorites(){ writeList(FAV,new ArrayList<String>()); }

    public void speak(String text){
        final String value=text==null?"":text;
        try{
            if(tts==null){
                tts=new TextToSpeech(host.getApplicationContext(),status->{
                    try{
                        tts.setLanguage(Locale.getDefault());
                        if(android.os.Build.VERSION.SDK_INT>=21) tts.speak(value,TextToSpeech.QUEUE_FLUSH,null,"almudhakira");
                        else tts.speak(value,TextToSpeech.QUEUE_FLUSH,null);
                    }catch(Exception ignored){}
                });
            }else{
                if(android.os.Build.VERSION.SDK_INT>=21) tts.speak(value,TextToSpeech.QUEUE_FLUSH,null,"almudhakira");
                else tts.speak(value,TextToSpeech.QUEUE_FLUSH,null);
            }
        }catch(Exception ignored){}
    }

    public void stopSelf(){ if(host instanceof android.app.Activity) ((android.app.Activity)host).finish(); }
    public void click(Object ignored){}
}