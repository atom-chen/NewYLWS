using UnityEngine;
using System.IO;
using System.Linq;
using XLua;
using System;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine.EventSystems;

/// <summary>
/// added by wsh @ 2017.12.25
/// 功能：通用静态方法
/// </summary>

[Hotfix]
[LuaCallCSharp]
public class GameUtility
{
    public const string AssetsFolderName = "Assets";

    public static string FormatToUnityPath(string path)
    {
        return path.Replace("\\", "/");
    }

    public static string FormatToSysFilePath(string path)
    {
        return path.Replace("/", "\\");
    }

    public static string FullPathToAssetPath(string full_path)
    {
        full_path = FormatToUnityPath(full_path);
        if (!full_path.StartsWith(Application.dataPath))
        {
            return null;
        }
        string ret_path = full_path.Replace(Application.dataPath, "");
        return AssetsFolderName + ret_path;
    }

    public static string GetFileExtension(string path)
    {
        return Path.GetExtension(path).ToLower();
    }

    public static string[] GetSpecifyFilesInFolder(string path, string[] extensions = null, bool exclude = false)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }

        if (extensions == null)
        {
            return Directory.GetFiles(path, "*.*", SearchOption.AllDirectories);
        }
        else if (exclude)
        {
            return Directory.GetFiles(path, "*.*", SearchOption.AllDirectories)
                .Where(f => !extensions.Contains(GetFileExtension(f))).ToArray();
        }
        else
        {
            return Directory.GetFiles(path, "*.*", SearchOption.AllDirectories)
                .Where(f => extensions.Contains(GetFileExtension(f))).ToArray();
        }
    }

    public static string[] GetSpecifyFilesInFolder(string path, string pattern)
    {
        if (string.IsNullOrEmpty(path))
        {
            return null;
        }

        return Directory.GetFiles(path, pattern, SearchOption.AllDirectories);
    }

    public static string[] GetAllFilesInFolder(string path)
    {
        return GetSpecifyFilesInFolder(path);
    }

    public static string[] GetAllDirsInFolder(string path)
    {
        return Directory.GetDirectories(path, "*", SearchOption.AllDirectories);
    }

    public static void CheckFileAndCreateDirWhenNeeded(string filePath)
    {
        if (string.IsNullOrEmpty(filePath))
        {
            return;
        }

        FileInfo file_info = new FileInfo(filePath);
        DirectoryInfo dir_info = file_info.Directory;
        if (!dir_info.Exists)
        {
            Directory.CreateDirectory(dir_info.FullName);
        }
    }

    public static void CheckDirAndCreateWhenNeeded(string folderPath)
    {
        if (string.IsNullOrEmpty(folderPath))
        {
            return;
        }

        if (!Directory.Exists(folderPath))
        {
            Directory.CreateDirectory(folderPath);
        }
    }

    public static AssetBundle LoadABFromMemory(WWW www)
    {
        if (www != null)
        {
            return AssetBundle.LoadFromMemory(www.bytes);
        }
        return null;
    }

    public static AssetBundleCreateRequest LoadABFromMemoryAsync(WWW www)
    {
        if (www != null)
        {
            return AssetBundle.LoadFromMemoryAsync(www.bytes);
        }
        return null;
    }

    public static bool SafeWriteWWWBytes(string outFile, WWW www)
    {
        if (www == null)
        {
            return false;
        }
        return SafeWriteAllBytes(outFile, www.bytes);
    }

    public static bool SafeWriteAllBytes(string outFile, byte[] outBytes)
    {
        try
        {
            if (string.IsNullOrEmpty(outFile))
            {
                return false;
            }

            CheckFileAndCreateDirWhenNeeded(outFile);
            if (File.Exists(outFile))
            {
                File.SetAttributes(outFile, FileAttributes.Normal);
            }
            File.WriteAllBytes(outFile, outBytes);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeWriteAllBytes failed! path = {0} with err = {1}", outFile, ex.Message));
            return false;
        }
    }

    public static bool SafeWriteAllLines(string outFile, string[] outLines)
    {
        try
        {
            if (string.IsNullOrEmpty(outFile))
            {
                return false;
            }

            CheckFileAndCreateDirWhenNeeded(outFile);
            if (File.Exists(outFile))
            {
                File.SetAttributes(outFile, FileAttributes.Normal);
            }
            File.WriteAllLines(outFile, outLines);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeWriteAllLines failed! path = {0} with err = {1}", outFile, ex.Message));
            return false;
        }
    }

    public static bool SafeWriteWWWText(string outFile, WWW www)
    {
        return SafeWriteAllText(outFile, www.text);
    }

    public static bool SafeWriteAllText(string outFile, string text)
    {
        try
        {
            if (string.IsNullOrEmpty(outFile))
            {
                return false;
            }

            CheckFileAndCreateDirWhenNeeded(outFile);
            if (File.Exists(outFile))
            {
                File.SetAttributes(outFile, FileAttributes.Normal);
            }
            File.WriteAllText(outFile, text);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeWriteAllText failed! path = {0} with err = {1}", outFile, ex.Message));
            return false;
        }
    }

    public static byte[] SafeReadAllBytes(string inFile)
    {
        try
        {
            if (string.IsNullOrEmpty(inFile))
            {
                return null;
            }

            if (!File.Exists(inFile))
            {
                return null;
            }

            File.SetAttributes(inFile, FileAttributes.Normal);
            return File.ReadAllBytes(inFile);
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeReadAllBytes failed! path = {0} with err = {1}", inFile, ex.Message));
            return null;
        }
    }

    public static string[] SafeReadAllLines(string inFile)
    {
        try
        {
            if (string.IsNullOrEmpty(inFile))
            {
                return null;
            }

            if (!File.Exists(inFile))
            {
                return null;
            }

            File.SetAttributes(inFile, FileAttributes.Normal);
            return File.ReadAllLines(inFile);
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeReadAllLines failed! path = {0} with err = {1}", inFile, ex.Message));
            return null;
        }
    }

    public static string SafeReadAllText(string inFile)
    {
        try
        {
            if (string.IsNullOrEmpty(inFile))
            {
                return null;
            }

            if (!File.Exists(inFile))
            {
                return null;
            }

            File.SetAttributes(inFile, FileAttributes.Normal);
            return File.ReadAllText(inFile);
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeReadAllText failed! path = {0} with err = {1}", inFile, ex.Message));
            return null;
        }
    }

    public static void DeleteDirectory(string dirPath)
    {
        string[] files = Directory.GetFiles(dirPath);
        string[] dirs = Directory.GetDirectories(dirPath);

        foreach (string file in files)
        {
            File.SetAttributes(file, FileAttributes.Normal);
            File.Delete(file);
        }

        foreach (string dir in dirs)
        {
            DeleteDirectory(dir);
        }

        Directory.Delete(dirPath, false);
    }

    public static bool SafeClearDir(string folderPath)
    {
        try
        {
            if (string.IsNullOrEmpty(folderPath))
            {
                return true;
            }

            if (Directory.Exists(folderPath))
            {
                DeleteDirectory(folderPath);
            }
            Directory.CreateDirectory(folderPath);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeClearDir failed! path = {0} with err = {1}", folderPath, ex.Message));
            return false;
        }
    }

    public static bool SafeDeleteDir(string folderPath)
    {
        try
        {
            if (string.IsNullOrEmpty(folderPath))
            {
                return true;
            }

            if (Directory.Exists(folderPath))
            {
                DeleteDirectory(folderPath);
            }
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeDeleteDir failed! path = {0} with err: {1}", folderPath, ex.Message));
            return false;
        }
    }

    public static bool SafeDeleteFile(string filePath)
    {
        try
        {
            if (string.IsNullOrEmpty(filePath))
            {
                return true;
            }

            if (!File.Exists(filePath))
            {
                return true;
            }
            File.SetAttributes(filePath, FileAttributes.Normal);
            File.Delete(filePath);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeDeleteFile failed! path = {0} with err: {1}", filePath, ex.Message));
            return false;
        }
    }

    public static bool SafeRenameFile(string sourceFileName, string destFileName)
    {
        try
        {
            if (string.IsNullOrEmpty(sourceFileName))
            {
                return false;
            }

            if (!File.Exists(sourceFileName))
            {
                return true;
            }
            File.SetAttributes(sourceFileName, FileAttributes.Normal);
            File.Move(sourceFileName, destFileName);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeRenameFile failed! path = {0} with err: {1}", sourceFileName, ex.Message));
            return false;
        }
    }

    public static bool SafeCopyFile(string fromFile, string toFile)
    {
        try
        {
            if (string.IsNullOrEmpty(fromFile))
            {
                return false;
            }

            if (!File.Exists(fromFile))
            {
                return false;
            }
            CheckFileAndCreateDirWhenNeeded(toFile);
            if (File.Exists(toFile))
            {
                File.SetAttributes(toFile, FileAttributes.Normal);
            }
            File.Copy(fromFile, toFile, true);
            return true;
        }
        catch (System.Exception ex)
        {
            Logger.LogError(string.Format("SafeCopyFile failed! formFile = {0}, toFile = {1}, with err = {2}",
                fromFile, toFile, ex.Message));
            return false;
        }
    }

    public static bool IsEditor()
    {
        return Application.isEditor;
    }

    public static void SetLightMap(Texture2D lm)
    {
        if (lm != null)
        {
            LightmapData lmd = new LightmapData();
            lmd.lightmapColor = lm;

            LightmapSettings.lightmaps = new LightmapData[1] { lmd };
        }
    }

    public static void SetSkyBox(Material mat)
    {
        if (mat != null)
        {
            RenderSettings.skybox = mat;
        }
    }

    public static void OpenFog(bool isOpen)
    {
        RenderSettings.fog = isOpen;
    }

    public static void SetFog(FogMode mode, float density, float begin, float end, Color color)
    {
        if (density <= 0)
        {
            RenderSettings.fog = false;
        }
        else
        {
            RenderSettings.fog = true;
            RenderSettings.fogMode = mode;
            RenderSettings.fogDensity = density;
            RenderSettings.fogStartDistance = begin;
            RenderSettings.fogEndDistance = end;
            RenderSettings.fogColor = color;
        }
    }

    public static Vector3 ScreenPos2TerrainPos(Vector2 screenPos, string terrainLayer)
    {
        Ray ray = Camera.main.ScreenPointToRay(screenPos);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, float.MaxValue, LayerMask.GetMask(terrainLayer)))
        {
            return hit.point;
        }

        return new Vector3(-1000, -1000, -1000);
    }


    public static int TouchWujiangIndex(int layer, Camera fortressMainCamera, PointerEventData eventData)
    {
        if (fortressMainCamera != null && eventData != null)
        {
            Vector3 v2 = Vector3.zero;
            bool touched = false;

            if (Input.touchSupported)
            {
                if (Input.touchCount == 1)
                {
                    Touch touch = Input.GetTouch(0);
                    TouchPhase phase = touch.phase;
                    if (phase == TouchPhase.Ended || phase == TouchPhase.Canceled)
                    {
                        v2 = touch.position;
                        touched = true;
                    }
                }
            }
            else
            {
                if (Input.GetMouseButtonUp(0))
                {
                    v2 = Input.mousePosition;
                    touched = true;
                }
            }

            if (touched)
            {
                Ray r = fortressMainCamera.ScreenPointToRay(v2);
                RaycastHit hit;
                if (Physics.Raycast(r, out hit, float.MaxValue, (1 << layer)))
                {
                    GameObject go = hit.collider.gameObject;
                    int index = 0;
                    if (int.TryParse(go.name, out index))
                    {
                        if (CheckGuiRaycastObjects(eventData) == false)
                        {
                            return index;
                        }
                    }
                }
            }
        }

        return 0;
    }

    public static GameObject CreateMeshGo(string name, Vector3[] vertices, Vector2[] uvs, Material material, int layer)
    {
        GameObject go = new GameObject(name);
        Mesh mesh = new Mesh();

        int[] triangles = new int[] { 0, 1, 2, 2, 3, 0 };

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;

        MeshFilter mf = go.AddComponent<MeshFilter>();
        mf.mesh = mesh;

        MeshRenderer mr = go.AddComponent<MeshRenderer>();
        mr.material = material;

        go.layer = layer;

        return go;
    }

    public static Transform CreateLine(Transform parent, Material mat, int layer)
    {
        Transform trans_line = new GameObject("Line").transform;
        trans_line.parent = parent;
        trans_line.localPosition = Vector3.zero;

        Transform trans_part1 = CreateMeshGo("Part1",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 0.4f), new Vector2(1f, 0.4f), new Vector2(1f, 0f) },
            mat, layer
            ).transform;
        trans_part1.parent = trans_line;
        trans_part1.localPosition = Vector3.zero;

        Transform trans_part2 = CreateMeshGo("Part2",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0.4f), new Vector2(0f, 0.66f), new Vector2(1f, 0.66f), new Vector2(1f, 0.4f) },
            mat, layer
            ).transform;
        trans_part2.parent = trans_line;
        trans_part2.localPosition = Vector3.zero;

        Transform trans_part3 = CreateMeshGo("Part3",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0.66f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0.66f) },
            mat, layer
            ).transform;
        trans_part3.parent = trans_line;
        trans_part3.localPosition = Vector3.zero;

        return trans_line;
    }

    public static Transform CreateRect(Transform parent, Material mat, int layer)
    {
        Transform trans_rect = new GameObject("Rect").transform;
        trans_rect.parent = parent;
        trans_rect.localPosition = Vector3.zero;

        Transform trans_part1 = CreateMeshGo("Part1",
                new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
                new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 0.3f), new Vector2(1f, 0.3f), new Vector2(1f, 0f) },
                mat, layer
                ).transform;
        trans_part1.parent = trans_rect;
        trans_part1.localPosition = Vector3.zero;

        Transform trans_part2 = CreateMeshGo("Part2",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0.3f), new Vector2(0f, 0.7f), new Vector2(1f, 0.7f), new Vector2(1f, 0.3f) },
            mat, layer
            ).transform;
        trans_part2.parent = trans_rect;
        trans_part2.localPosition = Vector3.zero;

        Transform trans_part3 = CreateMeshGo("Part3",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0.7f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0.7f) },
            mat, layer
            ).transform;
        trans_part3.parent = trans_rect;
        trans_part3.localPosition = Vector3.zero;

        return trans_rect;
    }

    public static Transform CreateCircle(Transform parent, Material mat, int layer)
    {
        Transform tran_circle = new GameObject("Circle").transform;
        tran_circle.parent = parent;
        tran_circle.localPosition = Vector3.zero;

        Transform trans_part1 = CreateMeshGo("Part1",
            new Vector3[] { new Vector3(-0.5f, 0f, -0.5f), new Vector3(-0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, -0.5f) },
            new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) },
            mat, layer
            ).transform;
        trans_part1.parent = tran_circle;
        trans_part1.localPosition = Vector3.zero;

        return tran_circle;
    }

    public static Transform CreateHalfCircle(Transform parent, Material mat, int layer)
    {
        Transform tran_circle = new GameObject("HalfCircle").transform;
        tran_circle.parent = parent;
        tran_circle.localPosition = Vector3.zero;

        Transform trans_part1 = CreateMeshGo("Part1",
            new Vector3[] { new Vector3(-0.5f, 0f, -0.5f), new Vector3(-0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, -0.5f) },
            new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) },
            mat, layer
            ).transform;
        trans_part1.parent = tran_circle;
        trans_part1.localPosition = Vector3.zero;

        return tran_circle;
    }

    public static Transform CreateSector(Transform parent, Material mat, int layer)
    {
        Transform com_sector = new GameObject("Sector").transform;
        com_sector.parent = parent;
        com_sector.localPosition = Vector3.zero;

        Transform com_sector_part1 = CreateMeshGo("Part1",
            new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
            new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) },
            mat, layer
            ).transform;
        com_sector_part1.parent = com_sector;
        com_sector_part1.localPosition = Vector3.zero;

        return com_sector;
    }

    public static Transform CreateRange(Transform parent, Material mat, int layer)
    {
        Transform trans_range = new GameObject("Range").transform;
        trans_range.parent = parent;
        trans_range.localPosition = Vector3.zero;

        Transform trans_part1 = CreateMeshGo("RangePart1",
            new Vector3[] { new Vector3(-0.5f, 0f, -0.5f), new Vector3(-0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, 0.5f), new Vector3(0.5f, 0f, -0.5f) },
            new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) },
            mat, layer
            ).transform;
        trans_part1.parent = trans_range;
        trans_part1.localPosition = Vector3.zero;

        return trans_range;
    }

    public static Transform[] CreateRingSector(Transform parent, Material mat, int layer)
    {
        Transform[] trans = new Transform[2];
        Transform trans_ring_sector = new GameObject("RingSector").transform;
        trans_ring_sector.parent = parent;
        trans_ring_sector.localPosition = Vector3.zero;

        Transform trans_ring_sector_part1 = GameUtility.CreateMeshGo("Part1",
              new Vector3[] { new Vector3(-0.5f, 0f, 0f), new Vector3(-0.5f, 0f, 1f), new Vector3(0.5f, 0f, 1f), new Vector3(0.5f, 0f, 0f) },
              new Vector2[] { new Vector2(0f, 0f), new Vector2(0f, 1f), new Vector2(1f, 1f), new Vector2(1f, 0f) },
              mat, layer).transform;

        trans_ring_sector_part1.parent = trans_ring_sector;
        trans_ring_sector_part1.localPosition = Vector3.zero;

        trans[0] = trans_ring_sector;
        trans[1] = trans_ring_sector_part1;
        return trans;
    }

    public static void SetLocalFromRotation(Transform tr, Vector3 fromDir, Vector3 toDir)
    {
        if (tr)
        {
            tr.localRotation = Quaternion.FromToRotation(fromDir, toDir);
        }
    }

    public static void ActiveTransform(Transform tr, bool isActive)
    {
        if (tr)
        {
            tr.gameObject.SetActive(isActive);
        }
    }

    public static Vector3 RotateAroundY(Vector3 forward, float angle)
    {
        Matrix4x4 mat = new Matrix4x4();

        float cos = Mathf.Cos(angle * Mathf.Deg2Rad);
        float sin = Mathf.Sin(angle * Mathf.Deg2Rad);

        mat.m00 = cos;
        mat.m02 = -sin;
        mat.m11 = 1;
        mat.m20 = sin;
        mat.m22 = cos;
        mat.m33 = 1;

        Vector3 ret = mat.MultiplyVector(forward);
        return ret;
    }

    public static void RecursiveSetLayer(GameObject obj, int layer)
    {
        if (obj == null) return;
        Transform trans = obj.transform;
        for (int i = 0; i < trans.childCount; i++)
        {
            Transform childtrans = trans.GetChild(i);
            RecursiveSetLayer(childtrans.gameObject, layer);
        }
        obj.layer = layer;
    }

    public static Vector3[] GetWorldCorners(RectTransform rectTransform)
    {
        if (rectTransform != null)
        {
            Vector3[] corners = new Vector3[4];
            rectTransform.GetWorldCorners(corners);
            return corners;
        }

        return null;
    }

    public static Transform[] GetChildTransforms(Transform parent, string[] names)
    {
        int len = names.Length;
        Transform[] childs = new Transform[len];
        for (int i = 0; i < len; i++)
        {
            Transform tr = parent.Find(names[i]);
            if (tr == null)
            {
                Logger.LogError("Cannot find " + names[i]);
            }
            childs[i] = tr;
        }
        return childs;
    }

    public static Text[] GetChildTexts(Transform parent, string[] names)
    {
        int len = names.Length;
        Text[] childs = new Text[len];
        for (int i = 0; i < len; i++)
        {
            Transform tr = parent.Find(names[i]);
            if (tr == null)
            {
                Logger.LogError("Cannot find " + names[i]);
            }
            childs[i] = tr.GetComponent<Text>();
        }
        return childs;
    }

    public static Image[] GetChildImages(Transform parent, string[] names)
    {
        int len = names.Length;
        Image[] childs = new Image[len];
        for (int i = 0; i < len; i++)
        {
            Transform tr = parent.Find(names[i]);
            if (tr == null)
            {
                Logger.LogError("Cannot find " + names[i]);
            }
            childs[i] = tr.GetComponent<Image>();
        }
        return childs;
    }

    public static int GetStringLength(string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return 0;
        }

        return str.Length;
    }


    private static string GetPlatformName()
    {
#if UNITY_EDITOR
        return "Editor";
#elif UNITY_ANDROID
                return "Android";
#elif UNITY_IPHONE
                return "IOS";
#else
                return "Unknown";
#endif
    }

    public static RectTransform[] GetChildRectTrans(Transform parent, string[] names)
    {
        int len = names.Length;
        RectTransform[] childs = new RectTransform[len];
        for (int i = 0; i < len; i++)
        {
            Transform tr = parent.Find(names[i]);
            if (tr == null)
            {
                Logger.LogError("Cannot find " + names[i]);
            }
            childs[i] = tr.GetComponent<RectTransform>();
        }
        return childs;
    }

    public static void OpenMainCameraDepthTexture(bool isOpen)
    {
        Camera cam = Camera.main;
        if (cam != null)
        {
            if (isOpen)
            {
                cam.depthTextureMode = DepthTextureMode.Depth;
            }
            else
            {
                cam.depthTextureMode = DepthTextureMode.None;
            }
        }
    }

    public static void SetLayer(GameObject go, int layer)
    {
        if (go != null)
        {
            Renderer[] renderers = go.GetComponentsInChildren<Renderer>(true);
            for (int i = 0; i < renderers.Length; i++)
            {
                if (renderers[i] != null)
                {
                    renderers[i].gameObject.layer = layer;
                }
            }
        }
    }

    public static void ForceCrossFade(Animator animator, string name, float transitionDuration, int layer = 0, float normalizedTime = float.NegativeInfinity)
    {
        animator.Update(0);

        if (animator.GetNextAnimatorStateInfo(layer).fullPathHash == 0)
        {
            animator.CrossFade(name, transitionDuration, layer, normalizedTime);
        }
        else
        {
            animator.Play(animator.GetNextAnimatorStateInfo(layer).fullPathHash, layer);
            animator.Update(0);
            animator.CrossFade(name, transitionDuration, layer, normalizedTime);
        }
    }

    public static float GetClipLength(Animator animator, string clip)
    {
        if (null == animator || string.IsNullOrEmpty(clip) || null == animator.runtimeAnimatorController)
        {
            return 0;
        }

        RuntimeAnimatorController ac = animator.runtimeAnimatorController;
        AnimationClip[] tAnimationClips = ac.animationClips;
        if (null == tAnimationClips || tAnimationClips.Length <= 0)
        {
            return 0;
        }

        AnimationClip tAnimationClip;
        for (int i = 0; i < tAnimationClips.Length; i++)
        {
            tAnimationClip = ac.animationClips[i];
            if (null != tAnimationClip && tAnimationClip.name.Contains(clip))
            {
                return tAnimationClip.length;
            }
        }
        return 0;
    }

    public static void DestroyChild(GameObject go)
    {
        if (go != null)
        {
            int index = 0;
            Transform trans = go.transform;
            int childCount = trans.childCount;
            GameObject child = null;
            while (index < childCount)
            {
                child = trans.GetChild(index).gameObject;
                child.SetActive(false);


                UnityEngine.Object.Destroy(child);
                index++;
            }
        }
    }

    public static void ObjectExploded(GameObject go, Vector3 pos, float radius, float power, float upward, float clearTime, bool useGravity = true)
    {
        if (go == null)
        {
            return;
        }


        ObjectExplosion explode = go.AddComponent<ObjectExplosion>();
        explode.explosionPos = pos;
        explode.radius = radius;
        explode.power = power;
        explode.upward = upward;
        explode.clearTime = clearTime;
        explode.useGravity = useGravity;

        explode.Explosion();
    }

    public static void SetUISortingOrder(GameObject go, bool isUI, int order)
    {
        if (isUI)
        {
            Canvas canvas = go.GetComponent<Canvas>();
            GraphicRaycaster caster = go.GetComponent<GraphicRaycaster>();
            if (canvas == null)
            {
                canvas = go.AddComponent<Canvas>();
            }

            if (caster == null)
            {
                caster = go.AddComponent<GraphicRaycaster>();
            }

            canvas.overrideSorting = true;
            canvas.sortingOrder = order;
        }
        else
        {
            Renderer[] renders = go.GetComponentsInChildren<Renderer>();
            foreach (Renderer render in renders)
            {
                render.sortingOrder = order;
            }
        }
    }

    public static void SetUIGray(GameObject go, bool isGray)
    {
        Image[] images = go.GetComponentsInChildren<Image>(false);
        for (int i = 0; i < images.Length; i++)
        {
            Image img = images[i];
            if (img.sprite != null)
            {
                img.color = isGray ? Color.black : Color.white;
            }
        }
    }

    public static void KeepCenterAlign(Transform srcTrans, Transform centerTrans)
    {
        if (srcTrans && centerTrans)
        {
            Transform centerTransParent = centerTrans.parent;
            Transform srcTransParent = srcTrans.parent;

            srcTrans.SetParent(centerTransParent);
            Bounds centerTransBounds = RectTransformUtility.CalculateRelativeRectTransformBounds(centerTransParent, centerTrans);
            Bounds srcTransBounds = RectTransformUtility.CalculateRelativeRectTransformBounds(centerTransParent, srcTrans);
            Vector3 srcCenterPos = srcTransBounds.center;
            srcTrans.SetParent(srcTransParent);
            Vector3 diff = centerTransBounds.center - srcCenterPos;

            RectTransform srcRectTran = srcTrans.GetComponent<RectTransform>();
            srcRectTran.anchoredPosition = new Vector2(srcRectTran.anchoredPosition.x + diff.x, srcRectTran.anchoredPosition.y);
        }
    }

    public static Vector3[] GetRectTransWorldCorners(RectTransform rectTrans)
    {
        Vector3[] vec = new Vector3[4];
        if (rectTrans != null)
        {
            rectTrans.GetWorldCorners(vec);
        }
        return vec;
    }

    public static bool RegulateTest(string str, string pattern, bool ingoreCase = true)
    {
        if (ingoreCase)
        {
            return System.Text.RegularExpressions.Regex.IsMatch(str, pattern, System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        }
        else
        {
            return System.Text.RegularExpressions.Regex.IsMatch(str, pattern);
        }
    }

    public static int GetNameLength(string temp)
    {
        int count = 0;
        for (int i = 0; i < temp.Length; i++)
        {
            string tempStr = temp.Substring(i, 1);
            int byteCount = System.Text.ASCIIEncoding.UTF8.GetByteCount(tempStr);
            if (byteCount > 1)
            {
                count += 2;
            }
            else
            {
                count += 1;
            }
        }
        return count;
    }


    public static void SetLineRendererPositionByIndex(LineRenderer lr, float x1, float y1, float z1, float x2, float y2, float z2)
    {
        if (lr == null)
        {
            return;
        }

        lr.SetPosition(0, new Vector3(x1, y1, z1));
        lr.SetPosition(1, new Vector3(x2, y2, z2));
    }

    public static void SetShadowHeight(GameObject go, float y, float offsetY)
    {
        if (go != null)
        {
            int ShaderShadowHeightID = Shader.PropertyToID("_ShadowHeight");
            float posY = y + offsetY;

            Renderer[] renderList = go.GetComponentsInChildren<Renderer>();
            for (int i = 0; i < renderList.Length; i++)
            {
                var render = renderList[i];
                if (render != null)
                {
                    Material mat = render.material;
                    if (mat != null)
                    {
                        if (mat.HasProperty("_ShadowHeight"))
                        {
                            mat.SetFloat(ShaderShadowHeightID, posY);
                        }
                    }
                }
            }
        }
    }

    public static void SetAnchoredPosition(RectTransform rt, float x, float y, float z)
    {
        if (rt != null)
        {
            rt.anchoredPosition3D = new Vector3(x, y, z);
        }
    }

    public static void SetPosition(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            tr.position = new UnityEngine.Vector3(x, y, z);
        }
    }

    public static void SetLocalPosition(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            tr.localPosition = new UnityEngine.Vector3(x, y, z);
        }
    }

    public static void SetLocalScale(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            tr.localScale = new UnityEngine.Vector3(x, y, z);
        }
    }

    public static void SetForward(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            Vector3 f = new UnityEngine.Vector3(x, y, z);
            if (f != Vector3.zero)
            {
                tr.forward = f;
            }
        }
    }

    public static void RotateByEuler(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            tr.rotation = tr.rotation * Quaternion.Euler(x, y, z);
        }
    }

    public static void LookAt(Transform tr, float x, float y, float z)
    {
        if (tr != null)
        {
            tr.LookAt(new UnityEngine.Vector3(x, y, z));
        }
    }

    public static bool TransformWorld2RectPos(Camera mainCam, Camera uiCam, Transform tr, RectTransform rectTr, float offSetY, out Vector2 recPos)
    {
        recPos = Vector2.zero;

        if (mainCam == null || uiCam == null || tr == null)
        {
            return false;
        }

        Vector3 wPos = tr.position;
        wPos.y += offSetY;

        Vector3 screenPoint = mainCam.WorldToScreenPoint(wPos);

        return RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTr, new Vector2(screenPoint.x, screenPoint.y), uiCam, out recPos);
    }

    public static bool PosWorld2RectPos(Camera mainCam, Camera uiCam, float wX, float wY, float wZ, RectTransform rectTr, float offSetY, out Vector2 recPos)
    {
        recPos = Vector2.zero;

        if (mainCam == null || uiCam == null)
        {
            return false;
        }

        Vector3 wPos = new Vector3(wX, wY + offSetY, wZ);
        Vector3 screenPoint = mainCam.WorldToScreenPoint(wPos);

        return RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTr, new Vector2(screenPoint.x, screenPoint.y), uiCam, out recPos);
    }

    public static void SetParticleSystemSpeed(GameObject go, float speed)
    {
        if (go != null)
        {
            ParticleSystem[] pss = go.GetComponentsInChildren<ParticleSystem>();
            if (pss != null)
            {
                for (int i = 0; i < pss.Length; i++)
                {
                    if (pss[i] != null)
                    {
                        var m = pss[i].main;
                        m.simulationSpeed = speed;
                    }
                }
            }
        }
    }

    public static void SetRaycastTarget(Graphic g, bool enabled)
    {
        if (g != null)
        {
            g.raycastTarget = enabled;
        }
    }

    public static bool IsRaycastTargetEnabled(Graphic g)
    {
        if (g != null)
        {
            return g.raycastTarget;
        }
        return false;
    }

    public static Sprite CreateSpriteFromTexture(Texture2D t)
    {
        if (t != null)
        {
            return Sprite.Create(t, new Rect(0, 0, t.width, t.height), new Vector2(0.5f, 0.5f), 100);
        }
        return null;
    }

    public static void PlayEffectGo(GameObject effectGO)
    {
        if (effectGO != null)
        {
            effectGO.SetActive(true);
            ParticleSystem[] particles = effectGO.GetComponentsInChildren<ParticleSystem>(true);
            if (particles != null)
            {
                for (int i = 0; i < particles.Length; i++)
                {
                    particles[i].Play();
                }
            }
        }
    }


    public static void ClipGameObjectWithBounds(Transform trans, Vector4 clipRegion)
    {
        if (trans != null)
        {
            Renderer[] renderList = trans.GetComponentsInChildren<Renderer>(true);
            if (renderList != null)
            {
                for (int i = 0; i < renderList.Length; i++)
                {
                    Material[] matList = renderList[i].materials;
                    if (matList != null)
                    {
                        for (int j = 0; j < matList.Length; j++)
                        {
                            Material mat = matList[j];
                            if (mat != null)
                            {
                                if (mat.HasProperty("_ClipRegions"))
                                {
                                    mat.SetVector("_ClipRegions", clipRegion);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static List<RaycastResult> raycastResultList = new List<RaycastResult>();

    public static bool CheckGuiRaycastObjects(PointerEventData eventData)
    {
        EventSystem eventSystem = EventSystem.current;

        if (eventData != null && eventSystem != null)
        {
            if (Input.touchSupported)
            {
                if (Input.touchCount == 1)
                {
                    Touch touch = Input.GetTouch(0);
                    TouchPhase phase = touch.phase;
                    if (phase == TouchPhase.Ended || phase == TouchPhase.Canceled)
                    {
                        eventData.pressPosition = touch.position;
                        eventData.position = touch.position;
                    }
                }
            }
            else
            {
                if (Input.GetMouseButtonUp(0))
                {
                    eventData.pressPosition = Input.mousePosition;
                    eventData.position = Input.mousePosition;
                }
            }

            eventSystem.RaycastAll(eventData, raycastResultList);
            int raycastResultCount = raycastResultList.Count;
            raycastResultList.Clear();

            return raycastResultCount > 0;
        }

        return false;
    }

    public static void SetWeaponTrailLayer(GameObject go, int layer)
    {
        if (go == null)
        {
            return;
        }
        MeleeWeaponTrail[] trails = go.GetComponentsInChildren<MeleeWeaponTrail>();

        if (trails != null)
        {
            for (int i = 0; i < trails.Length; ++i)
            {
                if (trails[i] != null)
                {
                    trails[i].SetLayer(layer);
                }
            }
        }
    }

    public static void UseWeaponTrail(GameObject go, bool isUse)
    {
        if (go == null)
        {
            return;
        }

        MeleeWeaponTrail[] trails = go.GetComponentsInChildren<MeleeWeaponTrail>();

        if (trails != null)
        {
            for (int i = 0; i < trails.Length; ++i)
            {
                if (trails[i] != null)
                {
                    trails[i].Use = isUse;
                }
            }
        }
    }

    public static void SetSceneGOActive(string parentPath, string path, bool value)
    {
        GameObject parentGo = GameObject.Find(parentPath);
        if (parentGo)
        {
            Transform childTrans = parentGo.transform.Find(path);
            if (childTrans != null)
            {
                childTrans.gameObject.SetActive(value);
            }
        }
    }


    
    public static void RegisterIOSNotification(double addDays, string hour, string min, string title, string msg)
    {
        DateTime now = DateTime.Now;
        string dateStr = now.ToShortDateString();
        dateStr = dateStr + " " + hour + ":" + min;
        if (addDays > 0)
        {
            DateTime dateTime = Convert.ToDateTime(dateStr).AddDays(addDays);
            if (now < dateTime)
            {
                CreateLoaclNotifiaction(dateTime, title, msg);
            }
        }
        else
        {
            for (double i = 0; i < 3; i++)
            {
                DateTime dateTime = Convert.ToDateTime(dateStr).AddDays(i);
                if (now < dateTime)
                {
                    CreateLoaclNotifiaction(dateTime, title, msg);
                }
            }
        }
    }

    private static void CreateLoaclNotifiaction(DateTime fireDate, string title, string msg, bool isRepeatDay = false)
    {
#if UNITY_IPHONE
        UnityEngine.iOS.LocalNotification localNotification = new UnityEngine.iOS.LocalNotification();
        localNotification.fireDate = fireDate;
        localNotification.alertBody = msg;
        localNotification.applicationIconBadgeNumber = 1;
        localNotification.hasAction = true;
        localNotification.alertAction = title;
        if (isRepeatDay)
        {
            localNotification.repeatCalendar = UnityEngine.iOS.CalendarIdentifier.ChineseCalendar;
            localNotification.repeatInterval = UnityEngine.iOS.CalendarUnit.Day;
        }
        
        localNotification.soundName = UnityEngine.iOS.LocalNotification.defaultSoundName;
        UnityEngine.iOS.NotificationServices.ScheduleLocalNotification(localNotification);
#endif
    }

    public static void ClearNotification()
    {
#if UNITY_IPHONE
        UnityEngine.iOS.LocalNotification notif = new UnityEngine.iOS.LocalNotification();
        notif.applicationIconBadgeNumber = -1;
        UnityEngine.iOS.NotificationServices.PresentLocalNotificationNow(notif);
        UnityEngine.iOS.NotificationServices.CancelAllLocalNotifications();
        UnityEngine.iOS.NotificationServices.ClearLocalNotifications();
#endif
    }

}

#if UNITY_EDITOR
public static class GameUtilityExporter
{
    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp = new List<Type>(){
            typeof(GameUtility),
        };
}
#endif