package com.androlua;

import android.content.Intent;
import android.os.Bundle;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class Main extends LuaActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        prepareBundledProject();
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null && getIntent().getData() != null)
            runFunc("onNewIntent", getIntent());
        if (getIntent().getBooleanExtra("isVersionChanged", false) && savedInstanceState == null)
            onVersionChanged(getIntent().getStringExtra("newVersionName"), getIntent().getStringExtra("oldVersionName"));
    }

    private void prepareBundledProject() {
        try {
            LuaApplication app = (LuaApplication) getApplication();
            File root = new File(app.getLocalDir());
            if (!root.exists()) root.mkdirs();
            copyAsset("main.lua", new File(root, "main.lua"));
            copyAsset("init.lua", new File(root, "init.lua"));
        } catch (Exception ignored) {}
    }

    private void copyAsset(String name, File target) throws Exception {
        InputStream in = getAssets().open(name);
        FileOutputStream out = new FileOutputStream(target, false);
        byte[] buffer = new byte[8192];
        int n;
        while ((n = in.read(buffer)) > 0) out.write(buffer, 0, n);
        out.close();
        in.close();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        runFunc("onNewIntent", intent);
        super.onNewIntent(intent);
    }

    @Override
    public String getLuaDir() { return getLocalDir(); }

    @Override
    public String getLuaPath() {
        initMain();
        return getLocalDir() + "/main.lua";
    }

    private void onVersionChanged(String newVersionName, String oldVersionName) {
        runFunc("onVersionChanged", newVersionName, oldVersionName);
    }
}