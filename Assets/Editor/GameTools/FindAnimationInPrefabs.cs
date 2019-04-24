using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class FindAnimationInPrefabs : EditorWindow
{
    class RefInfo
    {
        public string path = string.Empty;
        public Object go = null;
    }

    List<RefInfo> resultInfos = new List<RefInfo>();

    private string findWhat = "";

    Vector2 scrollPos;

    [MenuItem("Tools/FindAnimationInPrefabs", false, 1)]
    static void Init()
    {
        FindAnimationInPrefabs window = EditorWindow.GetWindow<FindAnimationInPrefabs>("FindAnimationInPrefabs");
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("查找", EditorStyles.boldLabel);



        //findWhat = GUILayout.TextField(findWhat, GUILayout.Width(200));

        GUILayout.BeginHorizontal();

        if (GUILayout.Button("查找", GUILayout.Width(70)))
        {
            FindFromPath(findWhat);
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

    private void FindFromPath(string findWhat)
    {
        Debug.Log("Now find " + findWhat);

        resultInfos.Clear();

        string[] ids = AssetDatabase.FindAssets("t:Prefab", new string[] { "Assets/AssetsPackage/Models" });
        for (int i = 0; i < ids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(ids[i]);
            GameObject go = AssetDatabase.LoadAssetAtPath(path, typeof(GameObject)) as GameObject;

            bool got = false;

            Animation[] animations = go.GetComponentsInChildren<Animation>(true);
            for (int j = 0; j < animations.Length; j++)
            {
                if (animations[j] )      // && animations[j].gameObject.name.EndsWith("_BTN") == false
                {

                    Debug.Log("------ " + animations[j].name + " -- " + go.name + " , " + animations[j].gameObject.name);


                    got = true;
                }
            }

            if (got)
            {
                RefInfo info = new RefInfo();
                info.path = path;
                info.go = go;
                resultInfos.Add(info);
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
