using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System;
using System.Text;
using UnityEditor.SceneManagement;

public class ModelReferencer : EditorWindow
{

    class ReferencerAssetParam
    {
        public string assetDirectory { get; private set; }

        public string assetType { get; private set; }

        public string assetExtension { get; private set; }

        public ReferencerAssetParam(string assetDirectory, string assetType, string assetExtension)
        {
            this.assetDirectory = assetDirectory;
            this.assetType = assetType;
            this.assetExtension = assetExtension;
        }
    }

    static readonly ReferencerAssetParam[] referencerAssetParams = new ReferencerAssetParam[] {
            new ReferencerAssetParam ("Assets", "Scene", ".unity"),
            new ReferencerAssetParam ("Assets", "Prefab", ".prefab"),
            new ReferencerAssetParam ("Assets", "Material", ".mat"),
            new ReferencerAssetParam ("Assets", "Shader", ".shader"),
            new ReferencerAssetParam ("Assets", "ScriptableObject", ".asset"),
            //new ReferencerAssetParam ("Assets", "Flare", ".flare"),
            //new ReferencerAssetParam ("Assets", "AnimatorController", ".controller"),
            //new ReferencerAssetParam ("Assets", "AnimatorOverrideController", ".overrideController"),
            //new ReferencerAssetParam ("Assets", "Cubemap", ".cubemap"),
            //new ReferencerAssetParam ("Assets", "ComputeShader", ".compute"),
            //new ReferencerAssetParam ("Assets", "AvatorMask", ".mask"),
            //new ReferencerAssetParam ("Assets", "GUISkin", ".guiskin"),
        };

    [MenuItem("Tools/Model Rererence Finder")]
    static void Init()
    {
        ModelReferencer window = EditorWindow.GetWindow<ModelReferencer>("Model Reference Finder");
        window.Show();
    }

    ModelReferencer()
    {
    }

    private static List<string> ListUpAllObjectPath()
    {
        List<string> path = new List<string>(10000);

        foreach (var param in referencerAssetParams)
        {
            path.AddRange(ListUpAllObjectPathByType(param.assetDirectory, param.assetType, param.assetExtension));
        }

        return path;
    }

    private static List<string> ListUpAllObjectPathByType(string directory, string assetType, string assetFileExtension)
    {
        string assetSearchCond = "t:" + assetType + " ";
        string[] assetPaths = new string[1] {
                directory,
            };

        string[] guids = AssetDatabase.FindAssets(assetSearchCond, assetPaths);

        List<string> scenePath = new List<string>(4000);

        foreach (string guid in guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            if (!assetPath.EndsWith(assetFileExtension))
            {
                continue;
            }
            scenePath.Add(assetPath);
        }

        return scenePath;
    }

    void OnGUI()
    {
        //if (Selection.activeObject == null)
        //{
        //    GUI.color = Color.red;
        //    GUILayout.Label("Please select an object", EditorStyles.wordWrappedLabel);
        //    return;
        //}

        GUI.color = Color.white;

        if (GUILayout.Button("print model reference to ModelRefence.txt"))
        {
            //string[] objGuids = AssetDatabase.FindAssets("t:prefab", new string[] { relativePath });

            HashSet<string> deps = new HashSet<string>();

            StringBuilder result = new StringBuilder();

            string[] dirs = Directory.GetDirectories("Assets/AssetsPackage/Models");
            for (int i = 0; i < dirs.Length; i++)
            {
                string oneDir = dirs[i];

                int lastPos = oneDir.LastIndexOf('/');
                string roleStr = oneDir.Substring(lastPos + 1);

                //Debug.Log(" BEGIN ----------------------------- " + oneDir);

                //int roleID = 0;
                //if (Int32.TryParse(roleStr, out roleID))
                //{
                deps.Clear();


                StringBuilder sb = new StringBuilder();

                string[] objGuids = AssetDatabase.FindAssets("t:prefab", new string[] { oneDir });

                for (int j = 0; j < objGuids.Length; j++)
                {
                    string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                    UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.Object));
                    if (asset != null)
                    {
                        string[] dependencies = AssetDatabase.GetDependencies(assetPath);
                        for (int k = 0; k < dependencies.Length; k++)
                        {
                            //
                            if (deps.Contains(dependencies[k]) == false)
                            {
                                deps.Add(dependencies[k]);
                            }                            
                        }
                    }
                }
                //}

                List<string> ll = deps.ToList();
                ll.Sort();

                foreach (var dep in ll)
                {
                    sb.Append(dep + " ,\n");
                }

                result.Append(oneDir + " dependOn : \n" + sb.ToString() + "\n--------------------------------\n");

                //Debug.Log(" END -----------------------------  " + oneDir);

            }

            Debug.Log(result.ToString());
            

            File.WriteAllText("./ModelRefence.txt", result.ToString());
        }

        if (GUILayout.Button("print scene reference to SceneRefence.txt"))
        {
            //string[] objGuids = AssetDatabase.FindAssets("t:prefab", new string[] { relativePath });

            HashSet<string> deps = new HashSet<string>();

            StringBuilder result = new StringBuilder();


            StringBuilder sb = new StringBuilder();

            string[] objGuids = AssetDatabase.FindAssets("t:scene", new string[] { "Assets/AssetsPackage/Maps" });

            Debug.Log(" ----------- Scene count " + objGuids.Length);

            for (int j = 0; j < objGuids.Length; j++)
            {
                deps.Clear();
                sb.Length = 0;

                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);

                Debug.Log(" ----------- asset " + assetPath);

                if (assetPath.Contains("SkyBox"))
                {
                    continue;
                }

                UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.Object));
                if (asset != null)
                {
                    string[] dependencies = AssetDatabase.GetDependencies(assetPath);
                    for (int k = 0; k < dependencies.Length; k++)
                    {
                        //
                        if (deps.Contains(dependencies[k]) == false)
                        {
                            deps.Add(dependencies[k]);
                        }
                    }

                    List<string> ll = deps.ToList();
                    ll.Sort();

                    foreach (var dep in ll)
                    {
                        sb.Append(dep + " ,\n");

                    }
                    result.Append(assetPath + " dependOn : \n" + sb.ToString() + "\n--------------------------------\n");
                }
            }

            //Debug.Log(result.ToString());


            File.WriteAllText("./SceneRefence.txt", result.ToString());
        }


        if (GUILayout.Button("print scene unused Texture and Mat to UnusedTextureRefence.txt"))
        {
            StringBuilder result = new StringBuilder();

            HashSet<string> deps = new HashSet<string>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    //
                    if (deps.Contains(dependencies[k]) == false)
                    {
                        deps.Add(dependencies[k]);
                    }
                }
            }

            string[] objGuids = AssetDatabase.FindAssets("t:texture", new string[] { "Assets/AssetsPackage/Maps" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedTextureRefence.txt", result.ToString());


            objGuids = AssetDatabase.FindAssets("t:material", new string[] { "Assets/AssetsPackage/Maps" });
            result.Length = 0;

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedMaterialRefence.txt", result.ToString());
        }

        if (GUILayout.Button("print Effect unused Texture and Mat to UnusedTextureEffectRefence.txt"))
        {
            StringBuilder result = new StringBuilder();

            HashSet<string> deps = new HashSet<string>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    //
                    if (deps.Contains(dependencies[k]) == false)
                    {
                        deps.Add(dependencies[k]);
                    }
                }
            }

            string[] objGuids = AssetDatabase.FindAssets("t:texture", new string[] { "Assets/AssetsPackage/Effect" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedTextureEffectRefence.txt", result.ToString());


            objGuids = AssetDatabase.FindAssets("t:material", new string[] { "Assets/AssetsPackage/Effect" });
            result.Length = 0;

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedMaterialEffectRefence.txt", result.ToString());
        }


        if (GUILayout.Button("print unused Atlas to UnusedAtlasRefence.txt"))
        {
            StringBuilder result = new StringBuilder();

            HashSet<string> deps = new HashSet<string>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    //
                    if (deps.Contains(dependencies[k]) == false)
                    {
                        deps.Add(dependencies[k]);
                    }
                }
            }

            List<string> dirList = new List<string>(50);
            string[] dirs = Directory.GetDirectories("Assets/AssetsPackage/UI/Atlas");
            for (int i = 0; i < dirs.Length; i++)
            {
                string oneDir = dirs[i];
                if (oneDir.Contains("DynamicLoad") == false &&
                    oneDir.Contains("Icon") == false)
                {
                    dirList.Add(oneDir);
                }

            }

            string[] objGuids = AssetDatabase.FindAssets("t:texture", dirList.ToArray());

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedAtlasRefence.txt", result.ToString());
        }


        //if (GUILayout.Button("print depOn1046 to DepOn1046.txt"))
        //{
        //    StringBuilder result = new StringBuilder();

        //    //HashSet<string> deps = new HashSet<string>();

        //    List<string> objectsPath = ListUpAllObjectPath();

        //    foreach (var path in objectsPath)
        //    {
        //        string[] dependencies = AssetDatabase.GetDependencies(path);
        //        for (int k = 0; k < dependencies.Length; k++)
        //        {
        //            //
        //            //if (deps.Contains(dependencies[k]) == false)
        //            //{
        //            //    deps.Add(dependencies[k]);
        //            //}

        //            if (dependencies[k].Contains("1046"))
        //            {
        //                result.Append(path + " \n");
        //            }
        //        }
        //    }

        //    File.WriteAllText("./DepOn1046.txt", result.ToString());
        //}


        if (GUILayout.Button("print ModelAnimClipLength to ModelAnimClipLength.txt"))
        {
            StringBuilder result = new StringBuilder();


            string[] objGuids = AssetDatabase.FindAssets("t:animation", new string[] { "Assets/AssetsPackage/Models" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                UnityEngine.AnimationClip asset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.AnimationClip)) as AnimationClip;
                if (asset != null)
                {
                    float animLength = asset.length;
                    result.Append(assetPath + " : " + animLength + "\n");
                }
            }

            File.WriteAllText("./ModelAnimClipLength.txt", result.ToString());
        }


        if (GUILayout.Button("print UnusedShader to UnusedShader.txt"))
        {
            StringBuilder result = new StringBuilder();

            HashSet<string> deps = new HashSet<string>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    //
                    if (deps.Contains(dependencies[k]) == false)
                    {
                        deps.Add(dependencies[k]);
                    }
                }
            }


            string[] objGuids = AssetDatabase.FindAssets("t:shader", new string[] { "Assets/AssetsPackage/Shaders" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    result.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./UnusedShader.txt", result.ToString());
        }

        if (GUILayout.Button("print ReferenceDynamic to ReferenceDynamic.txt"))
        {
            StringBuilder unRefResult = new StringBuilder();
            StringBuilder refResult = new StringBuilder();

            HashSet<string> deps = new HashSet<string>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    //
                    if (deps.Contains(dependencies[k]) == false)
                    {
                        deps.Add(dependencies[k]);
                    }
                }
            }


            string[] objGuids = AssetDatabase.FindAssets("t:texture", new string[] { "Assets/AssetsPackage/UI/Atlas/DynamicLoad" });

            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                if (deps.Contains(assetPath) == false)
                {
                    unRefResult.Append(assetPath + " \n");
                }
                else
                {
                    refResult.Append(assetPath + " \n");
                }
            }

            File.WriteAllText("./DynamicUnReference.txt", unRefResult.ToString());
            File.WriteAllText("./DynamicReference.txt", refResult.ToString());

        }


        if (GUILayout.Button("print UnpackTextureRefs to UnpackTextureRefs.txt"))
        {
            StringBuilder result = new StringBuilder();

            Dictionary<string, List<string>> deps = new Dictionary<string, List<string>>();

            List<string> objectsPath = ListUpAllObjectPath();

            foreach (var path in objectsPath)
            {
                string[] dependencies = AssetDatabase.GetDependencies(path);
                for (int k = 0; k < dependencies.Length; k++)
                {
                    List<string> depL;
                    if (deps.TryGetValue(dependencies[k], out depL))
                    {
                        depL.Add(path);
                    }
                    else
                    {
                        depL = new List<string>();
                        depL.Add(path);
                        deps[dependencies[k]] = depL;
                    }
                }
            }


            string[] objGuids = AssetDatabase.FindAssets("t:texture", new string[] { "Assets/AssetsPackage/UI/Image/Unpackaged" });

            Dictionary<string, int> depDic = new Dictionary<string, int>();

            for (int j = 0; j < objGuids.Length; j++)
            {
                StringBuilder sb = new StringBuilder();

                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);
                sb.Append("----------- " + assetPath + " By ---------------\n");

                List<string> depL;
                if (deps.TryGetValue(assetPath, out depL))
                {
                    foreach (var item in depL)
                    {
                        sb.Append(item + " \n");
                    }
                }

                result.Append(sb.ToString() +  " \n");
            }

            File.WriteAllText("./UnpackTextureRefs.txt", result.ToString());
        }


        if (GUILayout.Button("print MobileShader to MobileShader.txt"))
        {
            //StringBuilder result = new StringBuilder();

            ////AssetDatabase.LoadAssetAtPath("", type(Shader));

            ////Shader.Find("");

            //string[] objGuids = AssetDatabase.FindAssets("t:material", new string[] { "Assets/AssetsPackage/Models" });

            //for (int j = 0; j < objGuids.Length; j++)
            //{
            //    string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);

            //    Material mat = AssetDatabase.LoadAssetAtPath(assetPath, typeof(Material)) as Material;
            //    if (mat.shader.name.Contains("Mobile/Particles"))
            //    {
            //        result.Append(assetPath + "         ON:           " + mat.shader.name + "\n");
            //    }
            //}

            //File.WriteAllText("./MobileShader.txt", result.ToString());

        }

        if (GUILayout.Button("print MantisEditorRef to MantisEditorRef.txt"))
        {
            StringBuilder result = new StringBuilder();


            //string[] objGuids = AssetDatabase.FindAssets("t:scene", new string[] { "Assets/AssetsPackage/Maps" });

            //for (int j = 0; j < objGuids.Length; j++)
            //{
            //    string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);

            //    SceneAsset sceneAsset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(SceneAsset)) as SceneAsset;
            //    EditorSceneManager.OpenScene(AssetDatabase.GetAssetPath(sceneAsset));
            //    Scene scene = SceneManager.GetActiveScene();

            //}

            File.WriteAllText("./MantisEditorRef.txt", result.ToString());

        }
    }




}