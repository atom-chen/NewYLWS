using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
 
public class  AtlasPostProcessor : AssetPostprocessor 
{
	void OnPostprocessTexture (Texture2D texture) 
	{
        if (assetPath.Contains("UI/Atlas/"))
        {
            string metaPath = Application.dataPath + assetPath + ".meta";
            metaPath = metaPath.Replace("AssetsAssets", "Assets");
            if (File.Exists(metaPath))
            {
                File.Delete(metaPath);
            }
            string AtlasName = new DirectoryInfo(Path.GetDirectoryName(assetPath)).Name;
            TextureImporter textureImporter = assetImporter as TextureImporter;
            textureImporter.textureType = TextureImporterType.Sprite;
            textureImporter.spritePackingTag = AtlasName;
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

            AssetDatabase.Refresh();
        }

        if (assetPath.Contains("_dither565"))
        {
            var texw = texture.width;
            var texh = texture.height;

            var pixels = texture.GetPixels();
            var offs = 0;

            var k1Per31 = 1.0f / 31.0f;

            var k1Per32 = 1.0f / 32.0f;
            var k5Per32 = 5.0f / 32.0f;
            var k11Per32 = 11.0f / 32.0f;
            var k15Per32 = 15.0f / 32.0f;

            var k1Per63 = 1.0f / 63.0f;

            var k3Per64 = 3.0f / 64.0f;
            var k11Per64 = 11.0f / 64.0f;
            var k21Per64 = 21.0f / 64.0f;
            var k29Per64 = 29.0f / 64.0f;

            var k_r = 32; //R&B压缩到5位，所以取2的5次方
            var k_g = 64; //G压缩到6位，所以取2的6次方

            for (var y = 0; y < texh; y++)
            {
                for (var x = 0; x < texw; x++)
                {
                    float r = pixels[offs].r;
                    float g = pixels[offs].g;
                    float b = pixels[offs].b;

                    var r2 = Mathf.Clamp01(Mathf.Floor(r * k_r) * k1Per31);
                    var g2 = Mathf.Clamp01(Mathf.Floor(g * k_g) * k1Per63);
                    var b2 = Mathf.Clamp01(Mathf.Floor(b * k_r) * k1Per31);

                    var re = r - r2;
                    var ge = g - g2;
                    var be = b - b2;

                    var n1 = offs + 1;
                    var n2 = offs + texw - 1;
                    var n3 = offs + texw;
                    var n4 = offs + texw + 1;

                    if (x < texw - 1)
                    {
                        pixels[n1].r += re * k15Per32;
                        pixels[n1].g += ge * k29Per64;
                        pixels[n1].b += be * k15Per32;
                    }

                    if (y < texh - 1)
                    {
                        pixels[n3].r += re * k11Per32;
                        pixels[n3].g += ge * k21Per64;
                        pixels[n3].b += be * k11Per32;

                        if (x > 0)
                        {
                            pixels[n2].r += re * k5Per32;
                            pixels[n2].g += ge * k11Per64;
                            pixels[n2].b += be * k5Per32;
                        }

                        if (x < texw - 1)
                        {
                            pixels[n4].r += re * k1Per32;
                            pixels[n4].g += ge * k3Per64;
                            pixels[n4].b += be * k1Per32;
                        }
                    }

                    pixels[offs].r = r2;
                    pixels[offs].g = g2;
                    pixels[offs].b = b2;

                    offs++;
                }
            }

            texture.SetPixels(pixels);
            EditorUtility.CompressTexture(texture, TextureFormat.RGB565, TextureCompressionQuality.Best);
        }
	}
 
    public static void OnPostprocessAllAssets(string[]importedAsset,string[] deletedAssets,string[] movedAssets,string[]movedFromAssetPaths)
	{
		foreach (string path in movedAssets) {
            if (path.Contains("UI/Atlas/"))
            {
                string metaPath = Application.dataPath + path + ".meta";
                metaPath = metaPath.Replace("AssetsAssets", "Assets");
                if (File.Exists(metaPath))
                {
                    File.Delete(metaPath);
                }

                string AtlasName = new DirectoryInfo(Path.GetDirectoryName(path)).Name;
                TextureImporter textureImporter = AssetImporter.GetAtPath(path) as TextureImporter;
                textureImporter.textureType = TextureImporterType.Sprite;
                textureImporter.spritePackingTag = AtlasName;
                textureImporter.mipmapEnabled = false;

                TextureImporterPlatformSettings defaultSettings = textureImporter.GetDefaultPlatformTextureSettings();
                defaultSettings.textureCompression = TextureImporterCompression.Uncompressed;
                textureImporter.SetPlatformTextureSettings(defaultSettings);

                TextureImporterPlatformSettings androidSettings = textureImporter.GetPlatformTextureSettings("Android");
                androidSettings.textureCompression = TextureImporterCompression.Uncompressed;
                textureImporter.SetPlatformTextureSettings(androidSettings);

                TextureImporterPlatformSettings iphoneSettings = textureImporter.GetPlatformTextureSettings("iPhone");
                iphoneSettings.textureCompression = TextureImporterCompression.Uncompressed;
                textureImporter.SetPlatformTextureSettings(iphoneSettings);
            }
		}
	}
}
