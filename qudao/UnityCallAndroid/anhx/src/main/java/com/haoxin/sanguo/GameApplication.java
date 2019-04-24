package com.haoxin.sanguo;

import android.app.Application;

import com.tencent.bugly.crashreport.CrashReport;

public class GameApplication extends Application
{
	@Override
	public void onCreate()
	{
		super.onCreate();
		CrashReport.initCrashReport(getApplicationContext());
	}
}
