using UnityEngine;
using System;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.XCodeEditor;
#endif
using System.IO;
using System.Collections.Generic;

public static class XCodePostProcess
{

#if UNITY_EDITOR
	[PostProcessBuild(999)]
	public static void OnPostProcessBuild( BuildTarget target, string pathToBuiltProject )
	{
		if (target != BuildTarget.iOS) 
		{
			Debug.LogWarning("Target is not iPhone. XCodePostProcess will not run");
			return;
		}
		
		string path = Path.GetFullPath(pathToBuiltProject);
		XCProject project = new XCProject( pathToBuiltProject );
		
        string outputPath = Path.Combine(Application.streamingAssetsPath, "AssetBundles/" + "package_name.bytes");
        string packageName = File.ReadAllText(outputPath);
        project.ApplyMod(Application.dataPath + "/Editor/XUPorter/Mods/" + packageName + ".projmods");

		EditPlist(path);

        project.AddOtherLinkerFlags("-lstdc++");
        project.AddOtherLinkerFlags("-lsqlite3");
        project.AddOtherLinkerFlags("-lz");
        project.AddOtherLinkerFlags("-lxml2");
		project.AddOtherLinkerFlags("-ObjC");
		project.overwriteBuildSetting("ENABLE_BITCODE", "NO");
		
		FixKeyboardBug(path);
		
		HiddenIphoneXHomeIndicator(path);

		project.Save();
	}

#endif

    private static void EditPlist(string filePath)
	{
		XCPlist list = new XCPlist(filePath);
		
		string PlistAdd = @"  
            <key>NSAppTransportSecurity</key>
            <dict>
                <key>NSAllowsArbitraryLoads</key>
                <true/>
            </dict>

            <key>UIRequiresFullScreen</key>
            <true/>

            <key>NSLocationWhenInUseUsageDescription</key>
	        <string></string>
	        <key>NSCameraUsageDescription</key>
	        <string>Need to access your photo camera</string>
	        <key>NSMicrophoneUsageDescription</key>
	        <string>Need to access your micro phone</string>
	        <key>NSPhotoLibraryUsageDescription</key>
	        <string>Need to access your photo camera</string>
        ";
		list.AddKey(PlistAdd);
		
		list.Save();
	}
	
	private static void FixKeyboardBug(string filePath)
	{
		XClass code = new XClass(filePath + "/Classes/UI/Keyboard.mm");
		code.Replace ("inputView.frame.origin.x", "textField.frame.origin.x");
		code.Replace ("inputView.frame.origin.y", "textField.frame.origin.y");
		code.Replace ("inputView.frame.size.height", "textField.frame.size.height");
	}
	
	public static void Log(string message)
	{
		UnityEngine.Debug.Log("PostProcess: "+message);
	}
	
	private static void HiddenIphoneXHomeIndicator(string filePath)
	{
		// iphone x home导航条
		XClass code = new XClass(filePath + "/Classes/UI/UnityViewControllerBase+iOS.mm");
		code.Replace(@"UIRectEdge res = UIRectEdgeNone;","");
		code.Replace(@"if (UnityGetDeferSystemGesturesTopEdge())","");
		code.Replace(@"res |= UIRectEdgeTop;","");
		code.Replace(@"if (UnityGetDeferSystemGesturesBottomEdge())","");
		code.Replace(@"res |= UIRectEdgeBottom;","");
		code.Replace(@"if (UnityGetDeferSystemGesturesLeftEdge())","");
		code.Replace(@"res |= UIRectEdgeLeft;","");
		code.Replace(@"if (UnityGetDeferSystemGesturesRightEdge())","");
		code.Replace(@"res |= UIRectEdgeRight;","");
		code.Replace(@"return res;","return UIRectEdgeAll;");
	}
}
