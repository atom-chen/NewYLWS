using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System;

public class TextFinder : EditorWindow
{
    private Vector2 scrollPos;
    private List<string> tmpList = new List<string>(8);

    [MenuItem("Tools/UIText Finder")]
    static void Init()
    {
        TextFinder window = EditorWindow.GetWindow<TextFinder>("UIText Finder");
        window.Show();
    }

    TextFinder()
    {
    }

    void OnGUI()
    {
        if (Selection.activeObject == null)
        {
            GUI.color = Color.red;
            GUILayout.Label("Please select an object", EditorStyles.wordWrappedLabel);
            return;
        }

        GUI.color = Color.white;

        GameObject uiPrefab = (GameObject)Selection.activeObject;

        if (GUILayout.Button("Find Text"))
        {
            //List<string> objectsPath = ListUpAllObjectPath();
            //List<UnityEngine.Object> referencers = FindReferencersForObject(Selection.activeObject, objectsPath);
            //referencesByTypes = AggregateReferencerByAssetType(referencers);

            UnityEngine.UI.Text[] textArray = uiPrefab.GetComponentsInChildren<UnityEngine.UI.Text>(true);

            string str = "";

            for (int i = 0; i < textArray.Length; i++)
            {
                string path = GetPath(textArray[i].gameObject, uiPrefab);

                str += textArray[i].gameObject.name + " : " + path;
                str += "\n";
            }

            Debug.Log(str);
            return;
        }

        if (GUILayout.Button("Find Path"))
        {
            GameObject currGo = (GameObject)Selection.activeObject;
            string path = GetPath(currGo, null);

            Debug.Log(currGo.name + " : " + path);
            return;
        }

        if (GUILayout.Button("Replace empty.png"))
        {
            GameObject currGo = (GameObject)Selection.activeObject;

            UnityEngine.UI.Image[] imgArray = currGo.GetComponentsInChildren<UnityEngine.UI.Image>(true);

            UnityEngine.Sprite realempty = (UnityEngine.Sprite)AssetDatabase.LoadAssetAtPath("Assets/AssetsPackage/UI/Atlas/DynamicLoad/realempty.tga", typeof(UnityEngine.Sprite));

            if (realempty == null)
            {
                Debug.LogError("no realempty");
                return;
            }

            for (int i = 0; i < imgArray.Length; i++)
            {
                UnityEngine.UI.Image img = imgArray[i];
                if (img.mainTexture.name.Equals("empty"))
                {
                    Debug.Log("got : " + img.gameObject.name + "," + img.mainTexture.name);

                    img.sprite = realempty;
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        if (GUILayout.Button("Off LightProbes"))
        {
            string[] objGuids = AssetDatabase.FindAssets("t:prefab", new string[] { "Assets/AssetsPackage/Models" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (assetPath.IndexOf("_showoff", StringComparison.CurrentCultureIgnoreCase) >= 0)
                {
                    UnityEngine.GameObject asset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.Object)) as GameObject;
                    if (asset != null)
                    {
                        SkinnedMeshRenderer[] smrs = asset.GetComponentsInChildren<SkinnedMeshRenderer>(true);
                        if (smrs != null)
                        {
                            foreach (var item in smrs)
                            {
                                item.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
                                item.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
                            }
                        }
                    }
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }

    private string GetPath(GameObject go, GameObject root)
    {
        tmpList.Clear();

        GameObject cur = go;

        while (cur != null)
        {
            tmpList.Add(cur.name);

            if (cur.transform.parent == null)
            {
                break;
            }

            cur = cur.transform.parent.gameObject;

            if (cur == root)
            {
                break;
            }
        }

        tmpList.Reverse();

        string r = "";

        for (int i = 0; i < tmpList.Count; i++)
        {
            r += tmpList[i];

            if (i < tmpList.Count - 1)
            {
                r += "/";
            }
        }

        return r;
    }

}