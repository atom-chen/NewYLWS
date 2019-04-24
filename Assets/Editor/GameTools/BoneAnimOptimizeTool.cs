using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text;
using System.IO;

public class BoneAnimOptimizeTool : EditorWindow
{
    private string findWhat = "";

    [MenuItem("Tools/Optimize BoneAnim")]
    public static void Init()
    {
        BoneAnimOptimizeTool window = EditorWindow.GetWindow<BoneAnimOptimizeTool>("Optimize BoneAnim");
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("输入武将ID(0:全部)", EditorStyles.boldLabel);
        

        findWhat = GUILayout.TextField(findWhat, GUILayout.Width(200));

        if (GUILayout.Button("压缩Model下的Animation", GUILayout.Width(300)))
        {
            if (findWhat == "0")
            {
                findWhat = "";
            }

            string modelRoot = "Assets/AssetsPackage/Models/";

            string fromPath = "Assets/AssetsPackage/Models";

            if (!string.IsNullOrEmpty(findWhat))
            {
                fromPath += ("/" + findWhat);
            }

            string[] objGuids = AssetDatabase.FindAssets("t:animation", new string[] { fromPath });

            StringBuilder sb = new StringBuilder();

            //int index = 0;
            for (int j = 0; j < objGuids.Length; j++)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(objGuids[j]);

                if (!assetPath.EndsWith("anim"))
                {
                    continue;
                }

                string ID = assetPath.Substring(modelRoot.Length, 4);

                int id = 0;
                if (!int.TryParse(ID, out id))
                {
                    continue;
                }

                if (! assetPath.StartsWith(modelRoot + id + "/Animations"))
                {
                    continue;
                }

                //if (UnityEditor.EditorUtility.DisplayCancelableProgressBar(
                //        "Processing", assetPath, (float)(index + 1) / objGuids.Length))
                //{
                //    break;
                //}

                UnityEngine.AnimationClip asset = AssetDatabase.LoadAssetAtPath(assetPath, typeof(UnityEngine.AnimationClip)) as AnimationClip;
                if (asset != null)
                {
                    ApplyToAnimClip(asset);
                }

                sb.Append(assetPath + " \n");

                //++index;
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            File.WriteAllText("./OptimizedAnimation.txt", sb.ToString());
        }
    }

    public static void ApplyToAnimClip(AnimationClip animClip)
    {
        foreach (EditorCurveBinding curveBinding in AnimationUtility.GetCurveBindings(animClip))
        {
            string tName = curveBinding.propertyName.ToLower();
            if (tName.Contains("scale"))
            {
                AnimationUtility.SetEditorCurve(animClip, curveBinding, null);
            }
        }

        CompressAnimationClip(animClip);
    }

    //压缩精度
    public static void CompressAnimationClip(AnimationClip _clip)
    {

        EditorCurveBinding[] cbs = AnimationUtility.GetCurveBindings(_clip);

        //AnimationClipCurveData[] tCurveArr = new AnimationClipCurveData[cbs.Length];  // AnimationUtility.GetAllCurves(_clip);

        for (int i = 0; i < cbs.Length; i++)
        {
            EditorCurveBinding bind = cbs[i];

            AnimationCurve curve = AnimationUtility.GetEditorCurve(_clip, bind);

            if (curve == null || curve.keys == null)
            {
                continue;
            }
            Keyframe[] tKeyFrameArr = curve.keys;

            //Debug.Log( bind.path + " , " + bind.propertyName + " kfConnt: " + tKeyFrameArr.Length);



            for (int j = 0; j < tKeyFrameArr.Length; j++)
            {
                Keyframe tKey = tKeyFrameArr[j];

                tKey.value = float.Parse(tKey.value.ToString("f3"));    //#.###
                tKey.inTangent = float.Parse(tKey.inTangent.ToString("f3"));
                tKey.outTangent = float.Parse(tKey.outTangent.ToString("f3"));
                tKey.inWeight = float.Parse(tKey.inWeight.ToString("f3"));
                tKey.outWeight = float.Parse(tKey.outWeight.ToString("f3"));
                

                tKeyFrameArr[j] = tKey;
            }
            curve.keys = tKeyFrameArr;
            _clip.SetCurve(bind.path, bind.type, bind.propertyName, curve);

            //AnimationUtility.SetEditorCurve(_clip, bind, curve);
        }



        //AnimationClipCurveData[] tCurveArr =  AnimationUtility.GetAllCurves(_clip);
        //Keyframe tKey;
        //Keyframe[] tKeyFrameArr;
        //for (int i = 0; i < tCurveArr.Length; ++i)
        //{
        //    AnimationClipCurveData tCurveData = tCurveArr[i];
        //    if (tCurveData.curve == null || tCurveData.curve.keys == null)
        //    {
        //        continue;
        //    }
        //    tKeyFrameArr = tCurveData.curve.keys;
        //    for (int j = 0; j < tKeyFrameArr.Length; j++)
        //    {
        //        tKey = tKeyFrameArr[j];
        //        tKey.value = float.Parse(tKey.value.ToString("f3"));    //#.###
        //        tKey.inTangent = float.Parse(tKey.inTangent.ToString("f3"));
        //        tKey.outTangent = float.Parse(tKey.outTangent.ToString("f3"));
        //        tKeyFrameArr[j] = tKey;
        //    }
        //    tCurveData.curve.keys = tKeyFrameArr;
        //    _clip.SetCurve(tCurveData.path, tCurveData.type, tCurveData.propertyName, tCurveData.curve);
        //}
    }
}
