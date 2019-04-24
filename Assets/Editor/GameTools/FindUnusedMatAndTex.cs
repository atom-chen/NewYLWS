using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class FindUnusedMatAndTex : EditorWindow
{
    class RefInfo
    {
        public string path = string.Empty;
        public Object go = null;
    }

    List<RefInfo> resultInfos = new List<RefInfo>();

    Vector2 scrollPos;

    [MenuItem("Tools/FindUnusedMatAndTex", false, 1)]
    static void AddWindow()
    {
        FindUnusedMatAndTex window = (FindUnusedMatAndTex)EditorWindow.GetWindow(typeof(FindUnusedMatAndTex), true, "FindUnusedMatAndTex");
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("查找模型中未使用的材质和贴图", EditorStyles.boldLabel);

        GUILayout.BeginHorizontal();

        if (GUILayout.Button("查找", GUILayout.Width(70)))
        {
            FindRef();
        }
        GUILayout.EndHorizontal();

        GUILayout.Space(3);
        GUILayout.Label("-------------[查找结果]-------------");
        GUILayout.Space(3);

        if (resultInfos.Count == 0)
        {
            GUILayout.Label("查无结果");
        }
        else
        {
            scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
            for (int j = 0; j < resultInfos.Count; j++)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.Label(resultInfos[j].path, GUILayout.Width(500));
                if (GUILayout.Button("Select", GUILayout.Width(100)))
                {
                    Select(resultInfos[j].go);
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }
    }

    void Select(Object go)
    {
        Selection.activeObject = go;
    }

    private void FindRef()
    {
        FindFromPath(Application.dataPath + "/AssetsPackage/Models");
    }

    private void FindFromPath(string path)
    {
        string[] prefabs = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
        for (int i = 0; i < prefabs.Length; i++)
        {
            prefabs[i] = FileUrlToAssetUrl(prefabs[i]);
        }

        HashSet<string> dependedMatAndTex = new HashSet<string>();
        string[] dependents = AssetDatabase.GetDependencies(prefabs);
        foreach (var dependent in dependents)
        {
            if (dependent.Contains("Texture") || dependent.Contains("Materials")) 
            {
                dependedMatAndTex.Add(dependent);
            }
        }

        string[] textureDirs = Directory.GetDirectories(path, "Texture", SearchOption.AllDirectories);
        foreach (var item in textureDirs)
        {
            string[] textures = Directory.GetFiles(item);
            foreach (var texture in textures)
            {
                if (!texture.EndsWith(".meta"))
                {
                    string texturePath = FileUrlToAssetUrl(texture);
                    if (!dependedMatAndTex.Contains(texturePath))
                    {
                        RefInfo info = new RefInfo();
                        info.path = texturePath;
                        info.go = AssetDatabase.LoadAssetAtPath(texturePath, typeof(Object));
                        resultInfos.Add(info);
                    }
                }
            }
        }

        string[] matDirs = Directory.GetDirectories(path, "Materials", SearchOption.AllDirectories);
        foreach (var item in matDirs)
        {
            string[] mats = Directory.GetFiles(item);
            foreach (var mat in mats)
            {
                if (!mat.EndsWith(".meta"))
                {
                    string matPath = FileUrlToAssetUrl(mat);
                    if (!dependedMatAndTex.Contains(matPath))
                    {
                        RefInfo info = new RefInfo();
                        info.path = matPath;
                        info.go = AssetDatabase.LoadAssetAtPath(matPath, typeof(Object));
                        resultInfos.Add(info);
                    }
                }
            }
        }
    }

    private string Format(string path)
    {
        return path.Replace("\\", "/");
    }

    private string FileUrlToAssetUrl(string path)
    {
        return Format(path.Replace(Application.dataPath, "Assets"));
    }

}
