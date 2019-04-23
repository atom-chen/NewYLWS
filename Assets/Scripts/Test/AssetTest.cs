using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssetTest : MonoBehaviour
{
    private GUIStyle fontStype = null;
    void Start()
    {
        fontStype = new GUIStyle();
        fontStype.fontSize = 22;
    }

    void OnGUI()
    {
        GUI.skin.button.fontSize = 24;
        GUILayout.Space(100);
        if (GUILayout.Button("All Texture", GUILayout.Width(200), GUILayout.Height(60)))
        {
            Texture2D[] texArray = Resources.FindObjectsOfTypeAll<Texture2D>();
            for (int i = 0; i < texArray.Length; i++)
            {
                Texture2D tex = texArray[i];
                if (tex.name.Contains("1004") || tex.name.Contains("1003") || tex.name.Contains("1002"))
                {
                    Debug.LogError("===========TexName : " + tex.name);
                }
            }
        }

        GUILayout.Space(100);
        if (GUILayout.Button("All GameObject", GUILayout.Width(200), GUILayout.Height(60)))
        {
            GameObject[] goArray = Resources.FindObjectsOfTypeAll<GameObject>();
            for (int i = 0; i < goArray.Length; i++)
            {
                GameObject go = goArray[i];
                if (go.name.Contains("1004") || go.name.Contains("1003") || go.name.Contains("1002"))
                {
                    Debug.LogError("===========GOName : " + go.name);
                }
            }
        }
    }
}
