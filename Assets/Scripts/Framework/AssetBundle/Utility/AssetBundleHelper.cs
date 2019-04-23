using UnityEngine;
using XLua;
using System.Text;
using System.Collections.Generic;

namespace AssetBundles
{
    [Hotfix]
    [LuaCallCSharp]
    public class AssetBundleHelper
    {
        private static Dictionary<string, string> m_abVersionDict = null;

        public static AssetBundleManifest LoadManifestFromAssetbundle(AssetBundle assetbundle, string assetName)
        {
            if (assetbundle == null)
            {
                Logger.LogError("Manifest LoadFromAssetbundle assetbundle null!");
                return null;
            }
            AssetBundleManifest manifest = assetbundle.LoadAsset<AssetBundleManifest>(assetName);
            return manifest;
        }

        public static void ShaderCollectionWarmUp(Object collection)
        {
            if (collection is ShaderVariantCollection)
            {
                ShaderVariantCollection svc = collection as ShaderVariantCollection;
                svc.WarmUp();
                Logger.LogError("Shader WarmUp 11");
            }
        }

        public static TextAsset LoadTextFromAssetbundle(AssetBundle assetbundle, string assetName)
        {
            if (assetbundle == null)
            {
                Logger.LogError("LoadTextFromAssetbundle assetbundle null!");
                return null;
            }
            return assetbundle.LoadAsset<TextAsset>(assetName);
        }

        public static Renderer[] GetRenderersInChildren(Object obj)
        {
            GameObject go = obj as GameObject;
            if (go != null)
            {
                return go.GetComponentsInChildren<Renderer>();
            }
            return null;
        }

        public static void CompareAndSaveABUpdateFile(WWW serverFile, WWW streamFile)
        {
            if (serverFile == null || streamFile == null)
            {
                return;
            }

            string content = serverFile.text.Replace("\r\n", "\n");
            string[] serverList = content.Split('\n');
            content = streamFile.text.Replace("\r\n", "\n");
            string[] streamList = content.Split('\n');
            if (serverList == null || serverList.Length == 0 || streamList == null || streamList.Length == 0)
            {
                return;
            }

            List<string> increaseList = GetDifferentItem(serverList, streamList);
            //List<string> decreaseList = GetDifferentItem(streamList, serverList);

            string persistentFilePath = AssetBundleUtility.GetPersistentDataPath(AssetBundleConfig.ABUpdateFileName);
            string[] persistentArray = GameUtility.SafeReadAllLines(persistentFilePath);

            List<string> persistentList = null;
            if (persistentArray == null || persistentArray.Length == 0)
            {
                persistentList = new List<string>();
                for (int i = 0; i < streamList.Length; i++)
                {
                    if (AssetBundleUtility.CheckPersistentFileExsits(streamList[i]))
                    {
                        continue;
                    }
                    persistentList.Add(streamList[i]);
                }
            }
            else
            {
                persistentList = new List<string>(persistentArray);
            }

            for (int i = 0; i < increaseList.Count; i++)
            {
                if (AssetBundleUtility.CheckPersistentFileExsits(increaseList[i]))
                {
                    continue;
                }
                persistentList.Add(increaseList[i]);
            }

            //for (int i = 0; i < decreaseList.Count; i++)
            //{
            //    if (persistentList.Contains(decreaseList[i]))
            //    {
            //        persistentList.Remove(decreaseList[i]);
            //    }
            //}
            GameUtility.SafeWriteAllLines(persistentFilePath, persistentList.ToArray());
        }

        private static List<string> GetDifferentItem(string[] array1, string[] array2)
        {
            List<string> diffList = new List<string>();
            for (int i = 0; i < array1.Length; i++)
            {
                bool isExist = false;
                for (int j = 0; j < array2.Length; j++)
                {
                    if (array1[i] == array2[j])
                    {
                        isExist = true;
                        break;
                    }
                }
                if (!isExist)
                {
                    diffList.Add(array1[i]);
                }
            }
            return diffList;
        }

        public static void RemoveABFromDontUpdatableFile(string abName)
        {
            string persistentFilePath = AssetBundleUtility.GetPersistentDataPath(AssetBundleConfig.ABUpdateFileName);
            string[] persistentArray = GameUtility.SafeReadAllLines(persistentFilePath);
            if (persistentArray == null || persistentArray.Length == 0)
            {
                Logger.LogError("The file that don't update ab is empty!");
                return;
            }

            List<string> persistentList = new List<string>(persistentArray);
            if (persistentList.Contains(abName))
            {
                persistentList.Remove(abName);
                GameUtility.SafeWriteAllLines(persistentFilePath, persistentList.ToArray());
            }
        }

        //public static void UpdateABVersionFileBegin()
        //{
        //    m_abVersionDict = new Dictionary<string, string>();
        //    string persistentFilePath = AssetBundleUtility.GetPersistentDataPath(AssetBundleConfig.AssetBundlesVersionFileName);
        //    string[] persistentArray = GameUtility.SafeReadAllLines(persistentFilePath);
        //    if (persistentArray == null || persistentArray.Length == 0)
        //    {
        //        return;
        //    }

        //    for (int i = 0; i < persistentArray.Length; i++)
        //    {
        //        string oneLine = persistentArray[i];
        //        string[] pairs = oneLine.Split(',');
        //        if (pairs != null && pairs.Length > 1)
        //        {
        //            m_abVersionDict[pairs[0]] = pairs[1];
        //        }
        //    }
        //}

        //public static void UpdateABVersion(string abName, int version)
        //{
        //    if (!string.IsNullOrEmpty(abName))
        //    {
        //        m_abVersionDict[abName] = version.ToString();
        //    }
        //}

        //public static void UpdateABVersionFileEnd()
        //{
        //    string persistentFilePath = AssetBundleUtility.GetPersistentDataPath(AssetBundleConfig.AssetBundlesVersionFileName);

        //    StringBuilder sb = new StringBuilder();
        //    if (m_abVersionDict != null && m_abVersionDict.Count > 0)
        //    {
        //        foreach (var item in m_abVersionDict)
        //        {
        //            sb.AppendFormat("{0}{1}{2}\n", item.Key, AssetBundleConfig.CommonMapPattren, item.Value);
        //        }
        //        string content = sb.ToString().Trim();
        //        GameUtility.SafeWriteAllText(persistentFilePath, content);
        //        m_abVersionDict = null;
        //    }
        //}

        public static bool IsVersionCached(string abPath, uint version)
        {
            return Caching.IsVersionCached(abPath, new Hash128(0, 0, 0, version));
        }

        public static bool ClearAllCachedVersions(string abName)
        {
            bool ret = Caching.ClearAllCachedVersions(abName);
            if (!ret)
            {
                Logger.LogError("ClearAllCachedVersions fail, ab : " + abName);
            }
            return ret;
        }

        public static bool ClearCache()
        {
            bool ret = Caching.ClearCache();
            if (!ret)
            {
                Logger.LogError("ClearCache fail, maybe some ab didn't unload yet");
            }
            return ret;
        }
    }
}