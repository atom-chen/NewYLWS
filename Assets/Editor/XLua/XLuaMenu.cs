using UnityEngine;
using UnityEditor;
using System.IO;
using Debug = UnityEngine.Debug;
using System.Diagnostics;
using AssetBundles;

[InitializeOnLoad]
public static class XLuaMenu
{
    private static void processCommand(string command, string argument)
    {
        ProcessStartInfo start = new ProcessStartInfo(command);
        start.Arguments = argument;
        start.CreateNoWindow = false;
        start.ErrorDialog = true;
        start.UseShellExecute = true;

        if (start.UseShellExecute)
        {
            start.RedirectStandardOutput = false;
            start.RedirectStandardError = false;
            start.RedirectStandardInput = false;
        }
        else
        {
            start.RedirectStandardOutput = true;
            start.RedirectStandardError = true;
            start.RedirectStandardInput = true;
            start.StandardOutputEncoding = System.Text.UTF8Encoding.UTF8;
            start.StandardErrorEncoding = System.Text.UTF8Encoding.UTF8;
        }

        Process p = Process.Start(start);

        if (!start.UseShellExecute)
        {
            //printOutPut(p.StandardOutput);
            //printOutPut(p.StandardError);
        }

        p.WaitForExit();
        p.Close();
    }

    [MenuItem("XLua/Copy Lua Files To AssetsPackage", false, 51)]
    public static void CopyLuaFilesToAssetsPackage()
    {
        string destination = Path.Combine(Application.dataPath, AssetBundleConfig.AssetsFolderName);
        destination = Path.Combine(destination, XLuaManager.luaAssetbundleAssetName);
        string source = Path.Combine(Application.dataPath, XLuaManager.luaScriptsFolder);
        string toolpath = Path.Combine(Application.dataPath, "../tools/");
        string tool = Path.Combine(Application.dataPath, "../tools/signture.bat");
        GameUtility.SafeDeleteDir(destination);

        //processCommand(tool, toolpath + " " + source + " " + destination); // 签名并拷贝
        try
        {
            FileUtil.CopyFileOrDirectoryFollowSymlinks(source, destination);
        }
        catch (System.Exception ex)
        {
            if (!Directory.Exists(destination))
            {
                Directory.CreateDirectory(destination);
            }
            Logger.LogError(string.Format("CopyFileOrDirectoryFollowSymlinks failed! path = {0} with err: {1}", destination, ex.Message));
            return;
        }

        var notLuaFiles = GameUtility.GetSpecifyFilesInFolder(destination, new string[] { ".lua" }, true);
        if (notLuaFiles != null && notLuaFiles.Length > 0)
        {
            for (int i = 0; i < notLuaFiles.Length; i++)
            {
                GameUtility.SafeDeleteFile(notLuaFiles[i]);
            }
        }

        var luaFiles = GameUtility.GetSpecifyFilesInFolder(destination, new string[] { ".lua" }, false);
        if (luaFiles != null && luaFiles.Length > 0)
        {
            for (int i = 0; i < luaFiles.Length; i++)
            {
                GameUtility.SafeRenameFile(luaFiles[i], luaFiles[i] + ".bytes");
            }
        }

        AssetDatabase.Refresh();
        Debug.Log("Copy lua files over");
    }
}
