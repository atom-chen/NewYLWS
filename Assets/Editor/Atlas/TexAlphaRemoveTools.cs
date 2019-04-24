using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
using System.Collections.Generic;

public class TexAlphaRemoveTools : EditorWindow
{
    public enum A_SIZE_REDUCE
    {
        EQUAL,
        HALF,
        QUARTER,
    }

    A_SIZE_REDUCE alphaSize = A_SIZE_REDUCE.HALF;

    [MenuItem("Tools/TexAlphaRemove")]
    static void Init()
    {
        EditorWindow.GetWindow(typeof(TexAlphaRemoveTools));
    }

    void OnGUI()
    {
        GUILayout.Label("-------------[技能纹理alpha]-------------", EditorStyles.boldLabel);

        GUILayout.Space(3);
        if (GUILayout.Button("技能纹理", GUILayout.Width(70)))
        {
            RemoveFolderTextureAlpha(Application.dataPath + "/AssetsPackage/UI/Image/Packaged/SkillIcon");
        }
        GUILayout.Space(10);

        if (GUILayout.Button("当前选中技能纹理", GUILayout.Width(100)))
        {
            RemoveTextureAlpha(Selection.activeObject as Texture2D);
        }

        GUILayout.Space(3);
        GUILayout.Label("-------------[当前选中纹理]-------------");
        GUILayout.Space(3);

        alphaSize = (A_SIZE_REDUCE)EditorGUILayout.EnumPopup("选择Alpha纹理压缩率: ", alphaSize);
        if (GUILayout.Button("Alpha分离", GUILayout.Width(70)))
        {
            SeparateAlpha(Selection.activeObject as Texture2D, alphaSize, true);
        }
    }

    void OnInspectorUpdate()
    {
        Repaint();
    }

    public void RemoveFolderTextureAlpha(string folderPath)
    {
        string[] texPathList = Directory.GetFiles(folderPath, "*.png", SearchOption.TopDirectoryOnly);
        foreach (string texPath in texPathList)
        {
            string fileName = Path.GetFileName(texPath);
            fileName = fileName.Substring(0, fileName.IndexOf("."));
            int resID;
            if (int.TryParse(fileName, out resID))
            {
                Debug.LogError(fileName);
                string texAssetPath = GetRelativeAssetPath(texPath);
                Texture2D obj = (Texture2D)AssetDatabase.LoadAssetAtPath(texAssetPath, typeof(Texture2D));
                RemoveTextureAlpha(obj);
            }
        }
        AssetDatabase.SaveAssets();
    }

    public void RemoveTextureAlpha(Texture2D mainTex)
    {
        string mainTexPath = AssetDatabase.GetAssetPath(mainTex.GetInstanceID());
        TextureImporter sourceAssetImporter = AssetImporter.GetAtPath(mainTexPath) as TextureImporter;
        if (sourceAssetImporter == null || !sourceAssetImporter.DoesSourceTextureHaveAlpha())
        {
            return;
        }

        sourceAssetImporter.isReadable = true;
        sourceAssetImporter.textureFormat = TextureImporterFormat.RGBA32;
        sourceAssetImporter.SaveAndReimport();

        DORemoveTextureAlpha(mainTex);
    }

    public void DORemoveTextureAlpha(Texture2D tex)
    {
        string path = Application.dataPath.Replace("Assets", "");
        string rgbPath = path + AssetDatabase.GetAssetPath(tex);
        Texture2D rgbTex = new Texture2D(tex.width, tex.height);
        Color[] colors = tex.GetPixels();
        Color[] rgbColors = new Color[colors.Length];
        Color tempColor = new Color(0.8588f, 0.8078f, 0.6549f);
        for (int i = 0; i < colors.Length; i++)
        {
            Color c = colors[i];
            rgbColors[i] = Color.Lerp(tempColor, new Color(c.r, c.g, c.b), c.a);
        }
        rgbTex.SetPixels(rgbColors);
        rgbTex.Apply();
        File.WriteAllBytes(rgbPath, rgbTex.EncodeToPNG());
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        TextureImporter textureImporter = AssetImporter.GetAtPath(rgbPath.Replace(path, "")) as TextureImporter;
        textureImporter.isReadable = false;
        textureImporter.alphaIsTransparency = false;
        textureImporter.maxTextureSize = 2048;
        textureImporter.textureType = TextureImporterType.Sprite;
        textureImporter.mipmapEnabled = false;
        textureImporter.textureCompression = TextureImporterCompression.Uncompressed;

        TextureImporterPlatformSettings defaultSettings = textureImporter.GetDefaultPlatformTextureSettings();
        defaultSettings.textureCompression = TextureImporterCompression.Uncompressed;
        textureImporter.SetPlatformTextureSettings(defaultSettings);

        TextureImporterPlatformSettings androidSettings = textureImporter.GetPlatformTextureSettings("Android");
        androidSettings.textureCompression = TextureImporterCompression.Uncompressed;
        textureImporter.SetPlatformTextureSettings(androidSettings);

        TextureImporterPlatformSettings iphoneSettings = textureImporter.GetPlatformTextureSettings("iPhone");
        iphoneSettings.textureCompression = TextureImporterCompression.Uncompressed;
        textureImporter.SetPlatformTextureSettings(iphoneSettings);

        textureImporter.SaveAndReimport();
    }

    private string GetRelativeAssetPath(string _fullPath)
    {
        _fullPath = _fullPath.Replace("\\", "/");
        int idx = _fullPath.IndexOf("Assets");
        return _fullPath.Substring(idx);
    }

    private string GetRGBATexPath(string _texPath)
    {
        string result = _texPath.Replace("_RGB", "");
        result = result.Replace("_Alpha", "");
        return result;
    }
    private string GetRGBTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_RGB.");
    }

    private string GetAlphaTexPath(string _texPath)
    {
        return GetTexPath(_texPath, "_Alpha.");
    }

    private string GetTexPath(string _texPath, string _texRole)
    {
        string result = _texPath.Replace(".", _texRole);
        return result;
    }

    public void SeparateAlpha(Texture2D mainTex, A_SIZE_REDUCE size, bool useAlpha8)
    {
        string mainTexPath = AssetDatabase.GetAssetPath(mainTex.GetInstanceID());
        string rgbaTexPath = GetRGBATexPath(mainTexPath);
        string rgbTexPath = GetRGBTexPath(rgbaTexPath);
        string aTexPath = GetAlphaTexPath(rgbaTexPath);

        Texture2D sourceTex = AssetDatabase.LoadAssetAtPath(rgbaTexPath, typeof(Texture2D)) as Texture2D;
        if (sourceTex == null)
        {
            return;
        }
        TextureImporter sourceAssetImporter = AssetImporter.GetAtPath(rgbaTexPath) as TextureImporter;
        if (sourceAssetImporter == null)
        {
            return;
        }

        if (!sourceAssetImporter.DoesSourceTextureHaveAlpha())
        {
            return;
        }
        sourceAssetImporter.isReadable = true;
        TextureImporterPlatformSettings defaultSettings = sourceAssetImporter.GetDefaultPlatformTextureSettings();
        defaultSettings.textureCompression = TextureImporterCompression.Uncompressed;
        defaultSettings.format = TextureImporterFormat.RGBA32;
        sourceAssetImporter.SetPlatformTextureSettings(defaultSettings);
        sourceAssetImporter.SaveAndReimport();

        AssetDatabase.DeleteAsset(aTexPath);
        AssetDatabase.DeleteAsset(rgbTexPath);

        DoSeparateAlpha(sourceTex, size, useAlpha8);
    }

    public static void DoSeparateAlpha(Texture2D text, A_SIZE_REDUCE size, bool useAlpha8)
    {
        if (text != null)
        {
            string path = Application.dataPath.Replace("Assets", "");
            string rgbPath = path + AssetDatabase.GetAssetPath(text);
            string alphaPath = AssetDatabase.GetAssetPath(text).Split('.')[0] + "_alpha.png";
            string alphaFilePath = path + alphaPath;
            Texture2D alpha = new Texture2D(text.width, text.height);
            Texture2D rgbTex = new Texture2D(text.width, text.height);
            Color[] colors = text.GetPixels();
            Color[] alphaColors = new Color[colors.Length];
            Color[] rgbColors = new Color[colors.Length];
            for (int i = 0; i < colors.Length; i++)
            {
                Color c = colors[i];
                if (useAlpha8)
                {
                    alphaColors[i] = new Color(c.a, c.a, c.a, c.a);
                }
                else
                {
                    alphaColors[i] = new Color(c.a, c.a, c.a);
                }
                rgbColors[i] = new Color(c.r, c.g, c.b);
            }
            alpha.SetPixels(alphaColors);
            alpha.Apply();
            File.WriteAllBytes(alphaFilePath, alpha.EncodeToPNG());
            rgbTex.SetPixels(rgbColors);
            rgbTex.Apply();
            File.WriteAllBytes(rgbPath, rgbTex.EncodeToPNG());
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            TextureImporter texture = AssetImporter.GetAtPath(rgbPath.Replace(path, "")) as TextureImporter;
            texture.textureType = TextureImporterType.Default;
            texture.spriteImportMode = SpriteImportMode.None;
            texture.mipmapEnabled = false;
            texture.isReadable = false;
            texture.alphaIsTransparency = false;
            texture.maxTextureSize = 2048;
            TextureImporterPlatformSettings defaultSettings = texture.GetDefaultPlatformTextureSettings();
            defaultSettings.textureCompression = TextureImporterCompression.Compressed;
            texture.SetPlatformTextureSettings(defaultSettings);
            texture.SaveAndReimport();

            TextureImporter alphaImporter = AssetImporter.GetAtPath(alphaPath.Replace(path, "")) as TextureImporter;
            alphaImporter.textureType = TextureImporterType.Default;
            alphaImporter.spriteImportMode = SpriteImportMode.None;
            alphaImporter.alphaIsTransparency = false;
            alphaImporter.mipmapEnabled = false;
            alphaImporter.isReadable = false;
            if (size == A_SIZE_REDUCE.EQUAL)
            {
                alphaImporter.maxTextureSize = text.width > text.height ? text.width : text.height;
            }
            else if (size == A_SIZE_REDUCE.HALF)
            {
                alphaImporter.maxTextureSize = text.width > text.height ? text.width / 2 : text.height / 2;
            }
            if (text.width != text.height)
            {
                texture.ClearPlatformTextureSettings("Android");
                TextureImporterPlatformSettings iphoneSettings = alphaImporter.GetPlatformTextureSettings("iPhone");
                iphoneSettings.format = TextureImporterFormat.RGB16;
                iphoneSettings.overridden = true;
                alphaImporter.SetPlatformTextureSettings(iphoneSettings);
            }
            else
            {
                alphaImporter.ClearPlatformTextureSettings("iPhone");

                TextureImporterPlatformSettings androidSettings = alphaImporter.GetPlatformTextureSettings("Android");
                androidSettings.textureCompression = TextureImporterCompression.Uncompressed;
                androidSettings.overridden = true;
                if (useAlpha8)
                {
                    androidSettings.format = TextureImporterFormat.Alpha8;
                }
                else
                {
                    androidSettings.format = TextureImporterFormat.Automatic;
                }
                alphaImporter.SetPlatformTextureSettings(androidSettings);
            }

            alphaImporter.SaveAndReimport();
        }
    }
}
