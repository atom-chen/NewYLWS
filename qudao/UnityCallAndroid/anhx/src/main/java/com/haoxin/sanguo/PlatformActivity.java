package com.haoxin.sanguo;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.FileProvider;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.haoxin.sdk.HaoXinLoginCallback;
import com.haoxin.sdk.HaoXinLogoutCallback;
import com.haoxin.sdk.HaoXinManager;
import com.haoxin.sdk.HaoXinPayCallback;
import com.haoxin.sdk.LoginCallBackData;
import com.haoxin.xylws.R;
import com.tencent.bugly.crashreport.CrashReport;
import com.unity3d.player.UnityPlayer;

public class PlatformActivity extends MainActivity// implements View.OnClickListener
{
	private Handler m_downloadHandler;
    private static final int DOWNLOAD = 1;
    private static final int DOWNLOAD_FINISH = 2;
	private final static int INSTALL_PACKAGES_REQUESTCODE = 0x12;

    private int m_progress;
    private String m_url;
    private String m_savePath;
    private String m_saveName;
    
    private String haoxinAppId = "426707";
    private String haoxinAppKey = "TPD33QXJ3SUYC6KF7JXRKKHW2C4BDS3K";
    private String databaseName = "ANHX";
    
    private static PlatformActivity m_instacne = null;
    
    public static PlatformActivity getInstance()
    {
    	return m_instacne;
    }
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		HaoXinManager.init(this, haoxinAppId, haoxinAppKey, databaseName, true);
		HaoXinManager.setLogoutCallback(new HaoXinLogoutCallback() {
			@Override
			public void run() {
				UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"LogoutCallback\"}");
			}
		});
//
//		setContentView(R.layout.activity_main_test);
//		btnTestJavaCrash = (Button) findViewById(R.id.btnTestJavaCrash);
//		btnTestANRCrash = (Button) findViewById(R.id.btnTestANRCrash);
//		btnTestNativeCrash = (Button)findViewById(R.id.btnTestNativeCrash);
//		btnTestJavaCrash.setOnClickListener(this);
//		btnTestANRCrash.setOnClickListener(this);
//		btnTestNativeCrash.setOnClickListener(this);

		m_instacne = this;
	}
	
	public void onDestroy() {
		super.onDestroy();
	}
	
	@Override
	protected void onResume()
	{
		super.onResume();
	}
	
	@Override
	protected void onPause()
	{
		super.onPause();
	}
	
	@Override
	protected void onStart()
	{
		super.onStart();
	}
	
	@Override
	protected void onStop()
	{
		super.onStop();
	}
	
	@Override
	protected void onNewIntent(Intent intent)
	{
		super.onNewIntent(intent);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data)
	{
		super.onActivityResult(requestCode, resultCode, data);
		Log.i("HaoXinSDK", "requestCode : " + requestCode + "    resultCode : " + requestCode);
		if (requestCode == INSTALL_PACKAGES_REQUESTCODE) {
            InstallApk();
        }
	}
	
	@Override
	public void onConfigurationChanged(Configuration arg0)
	{
		super.onConfigurationChanged(arg0);
	}
	
	public void HXPay(final String channelUserId, final int moneyAmount, final String productName, final String productId, final String exchangeRate, 
			final String notifyUri, final String appName, final String appUserName, final String appUserId, final String appUserLevel, 
			final String appOrderId, final String serverId, final String payExt1, final String payExt2, final String submitTime)
	{
		HaoXinManager.pay(this, moneyAmount, productName, appOrderId, productId, new HaoXinPayCallback(){

			@Override
			public void run(int arg0, String arg1) {
				if (arg0 == HaoXinPayCallback.SUCCEED){
					UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"PayCallback\",\"ret\":0}");
				}else if(arg0 == HaoXinPayCallback.FAIL){
					UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"PayCallback\",\"ret\":-1}");
				}
			}
			
		});
	}

	public void DownLoadGame(String url, String saveName)
	{
		m_url = url;
		m_saveName = saveName;
		
		runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				runDownLoadGame();
			}
		});
	}
	
	@SuppressLint("HandlerLeak")
	private void runDownLoadGame()
	{
		m_downloadHandler = new Handler()
		{
			public void handleMessage(Message msg)
	        {
	            switch (msg.what)
	            {
	            case DOWNLOAD:
	            	UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"DownLoadGameProgressCallback\",\"progress\":" + String.valueOf(m_progress) + "}");
	                break;
	            case DOWNLOAD_FINISH:
	            	InstallApk();
	                break;
	            default:
	                break;
	            }
	        };
		};
		
		new downloadApkThread().start();
	}
	
	private class downloadApkThread extends Thread
    {
        @Override
        public void run()
        {
            try
            {
                if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED))
                {
                    String sdpath = Environment.getExternalStorageDirectory() + "/";
                    m_savePath = sdpath + "Download";
                    File file = new File(m_savePath);
                    if (!file.exists())
                    {
                        file.mkdir();
                    }
                    
                    File apkFile = new File(m_savePath, m_saveName);
                    
                    if (apkFile.exists())
                    {
                    	m_downloadHandler.sendEmptyMessage(DOWNLOAD_FINISH);
                    	return;
                    }
                    
                    File tmpFile = new File(m_savePath, m_saveName + ".tmp");
                    int loadedLength = (int)tmpFile.length();
                    
                    URL url = new URL(m_url);
                    // ��������
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestProperty("range", "bytes=" + loadedLength + "-");
                    conn.connect();
                    // ��ȡ�ļ���С
                    int length = conn.getContentLength();
                    length += loadedLength;
                    // ����������
                    InputStream is = conn.getInputStream();

                    FileOutputStream fos = new FileOutputStream(tmpFile, tmpFile.exists());
                    int count = loadedLength;
                    // ����
                    byte buf[] = new byte[1024];
                    m_progress = 0;
                    m_downloadHandler.sendEmptyMessage(DOWNLOAD);
                    // д�뵽�ļ���
                    while (true)
                    {
                        int numread = is.read(buf);
                        count += numread;
                        // ���������λ��
                        int newProgress = (int) (((float) count / length) * 100);
                        if (newProgress > m_progress)
                        {
                        	m_progress = newProgress;
                        	m_downloadHandler.sendEmptyMessage(DOWNLOAD);
                        }
                        if (numread <= 0)
                        {
                            // �������
                            break;
                        }
                        // д���ļ�
                        fos.write(buf, 0, numread);
                    }
                    fos.close();
                    is.close();
                    
                    tmpFile.renameTo(apkFile);
                    m_downloadHandler.sendEmptyMessage(DOWNLOAD_FINISH);
                }
                else
                {
                	UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"DownLoadGameCallback\",\"ret\":-1}");
                }
            }
            catch (Exception e)
            {
                e.printStackTrace();
                UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"DownLoadGameCallback\",\"ret\":-1}");
            }
        }
    };
	
	public void InnerInstallApk()
	{
		File apkfile = new File(m_savePath, m_saveName);
        if (!apkfile.exists())
        {
            return;
        }
        
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (Build.VERSION.SDK_INT >= 24){
        	i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        	Uri apkUri = FileProvider.getUriForFile(getApplicationContext(), getPackageName() + ".fileprovider", apkfile);
        	Log.d("HaoXinSdk", "APKURI : " + apkUri.getAuthority());
        	i.setDataAndType(apkUri, "application/vnd.android.package-archive");	
        }else{
        	i.setDataAndType(Uri.fromFile(apkfile), "application/vnd.android.package-archive");
        }
        
        this.startActivity(i);

        UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"DownLoadGameCallback\",\"ret\":0}");
	}
	
	  /**
     * 判断是否是8.0系统,是的话需要获取此权限，判断开没开，没开的话处理未知应用来源权限问题,否则直接安装
     */
    public void InstallApk() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //PackageManager类中在Android Oreo版本中添加了一个方法：判断是否可以安装未知来源的应用
            boolean bRet = getPackageManager().canRequestPackageInstalls();
            if (bRet) {
                InnerInstallApk();
            } else {
                //请求安装未知应用来源的权限
                ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.REQUEST_INSTALL_PACKAGES}, INSTALL_PACKAGES_REQUESTCODE);
            }
        } else {
			InnerInstallApk();
        }

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case INSTALL_PACKAGES_REQUESTCODE:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    InnerInstallApk();
                } else {
                    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
                    startActivityForResult(intent, 0x12);
                }
                break;

        }
    }
	
	public void StartWebView(String url)
	{
		Log.d("debug", "start open webview");
		Intent intent = new Intent(this, WebViewActivity.class);
		intent.putExtra("url", url);
		this.startActivity(intent);
	}
	
	public void HXInit()
	{
		UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"InitSDKComplete\",\"packageName\":\"ANHX\"}");
	}
	
	public void HXLogin()
	{
		runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				runLogin();
			}
		});
	}
	
	private void runLogin()
	{
		HaoXinManager.login(this, new HaoXinLoginCallback(){

			@Override
			public void run(int arg0, String arg1, LoginCallBackData arg2) {
				if (arg0 == HaoXinLoginCallback.SUCCEED){
					//CrashReport.testJavaCrash();
					UnityPlayer.UnitySendMessage("SDKHelper", "SDKCallLua", "{\"methodName\":\"LoginCallback\",\"platform_id\":\""+arg2.userId+"\",\"token\":\""+arg2.sessionId+"\"}");
				}
				else{
					//CrashReport.testANRCrash();
				}
			}
			
		});
	}
	
	public void HXSwitchAccount()
	{
		runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				runSwitchAccount();
			}
		});
	}
	
	private void runSwitchAccount()
	{
		HaoXinManager.logout(this);
	}
	
	public void HXSubmitUserConfig(String roleId, String roleName, String roleLevel, int zoneId, String zoneName, int registerTime, int currentTime, String type)
	{
		/*Log.d("debug", "HJLoginSubmitExtendData start");
		Log.d("debug", "roleId:" + roleId);
		Log.d("debug", "roleName:" + roleName);
		Log.d("debug", "roleLevel:" + roleLevel);
		Log.d("debug", "zoneId:" + zoneId);
		Log.d("debug", "zoneName:" + zoneName);
		Log.d("debug", "registerTime:" + registerTime);
		Log.d("debug", "currentTime:" + currentTime);
		Log.d("debug", "type:" + type);
		
		try
		{
			JSONObject json = new JSONObject();
			json.put("roleId", roleId);
			json.put("roleName", roleName);
			json.put("roleLevel", roleLevel);
			json.put("zoneId", zoneId);
			json.put("zoneName", zoneName);
			json.put("roleCTime", registerTime);
			json.put("roleLevelMTime", currentTime);
			HXWrapper.getInstance().SubmitUserConfig(this, type, json);
		}
		catch (Exception e)
		{
			
		}*/
	}
	
	public void HXExitGame()
	{
		runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				runExitGame();
			}
		});
	}
	
	private void runExitGame()
	{
		//HXWrapper.getInstance().exitGame(this);
	}

	@Override
	public void MainHandleUnityCall(String msg)
	{
		try {
			JSONObject json = new JSONObject(msg);
			String methodName = json.getString("methodName");
			switch(methodName)
			{
				case "HXInit":
					HXInit();
				break;
				case "HXLogin":
					HXLogin();
				break;
				case "HXSwitchAccount":
					HXSwitchAccount();
				break;
				case "HXPay":
				{
					String channelUserId = json.getString("channelUserId");
					int moneyAmount = json.getInt("moneyAmount");
					String productName = json.getString("productName");
					String productId = json.getString("productId");
					String exchangeRate = json.getString("exchangeRate");
					String notifyUri = json.getString("notifyUri");
					String appName = json.getString("appName");
					String appUserName = json.getString("appUserName");
					String appUserId = json.getString("appUserId");
					String appUserLevel = json.getString("appUserLevel");
					String appOrderId = json.getString("appOrderId");
					String serverId = json.getString("serverId");
					String payExt1 = json.getString("payExt1");
					String payExt2 = json.getString("payExt2");
					String submitTime = json.getString("submitTime");
					HXPay(channelUserId, moneyAmount, productName, productId, exchangeRate, 
							notifyUri, appName, appUserName, appUserId, appUserLevel, 
						    appOrderId, serverId, payExt1, payExt2, submitTime);
				}
				break;
				case "DownLoadGame":
				{
					String url = json.getString("url");
					String saveName = json.getString("saveName");
					DownLoadGame(url, saveName);
				}
				break;
				case "InstallApk":
				{
					InstallApk();
				}
				break;
			}
		} catch (JSONException e) {
			e.printStackTrace();
			Log.e("UnityCallAndroid", "HandleUnityCall error : " + e.getMessage());
		}
	}

//	private Button btnTestJavaCrash;
//	private Button btnTestANRCrash;
//	private Button btnTestNativeCrash;
//
//	@Override
//	public void onClick(View v) {
//		int viewID = v.getId();
//		if(viewID == R.id.btnTestJavaCrash) {
//			CrashReport.testJavaCrash();
//		}
//		else if(viewID == R.id.btnTestANRCrash) {
//			CrashReport.testANRCrash();
//		}
//		else if(viewID == R.id.btnTestNativeCrash) {
//			CrashReport.testNativeCrash();
//		}
//	}
}
