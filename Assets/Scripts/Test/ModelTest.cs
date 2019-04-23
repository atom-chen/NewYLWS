using System.Collections;
using UnityEngine;
using AssetBundles;

public class ModelTest : MonoBehaviour {
    public int modelID = 0;
    public GameObject modelGo = null;
    private Transform modelTrans = null;
    private Animator animator = null;
    private bool leftRotate = false;
    private bool rightRotate = false;

    IEnumerator Start()
    {
        //AssetBundleManager.ManifestBundleName = "TEST";
        //yield return AssetBundleManager.Instance.Initialize();
        //var loader = AssetBundleManager.Instance.LoadAssetAsync("Models/" + modelID + "/" + modelID + ".prefab", typeof(GameObject));
        //yield return loader;
        //GameObject modelPrefab = loader.asset as GameObject;
        //modelGo = Instantiate(modelPrefab);
        modelTrans = modelGo.transform;
        modelTrans.localPosition = new Vector3(0,0,-8);
        modelTrans.localEulerAngles = new Vector3(0, 180, 0);
        animator = modelGo.GetComponent<Animator>();
        yield break;
    }

    // Update is called once per frame
    void Update () {
        if (leftRotate)
        {
            modelTrans.Rotate(Vector3.up, Time.deltaTime * 200);
        }

        if (rightRotate)
        {
            modelTrans.Rotate(Vector3.up, Time.deltaTime * -200);
        }
    }

    void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Space(60);
        if (GUILayout.Button("左旋转",GUILayout.Width(150), GUILayout.Height(60)))
        {
            leftRotate = !leftRotate;
            rightRotate = false;
        }
        GUILayout.Space(60);
        if (GUILayout.Button(new GUIContent("右旋转"), GUILayout.Width(150), GUILayout.Height(60)))
        {
            rightRotate = !rightRotate;
            leftRotate = false;
        }
        GUILayout.Space(60);
        if (GUILayout.Button("show_idle", GUILayout.Width(150), GUILayout.Height(60)))
        {
            animator.Play("show_idle");
        }
        GUILayout.Space(60);
        if (GUILayout.Button("skill1", GUILayout.Width(150), GUILayout.Height(60)))
        {
            animator.Play("skill1");
        }
        GUILayout.Space(60);
        if (GUILayout.Button("prepare", GUILayout.Width(150), GUILayout.Height(60)))
        {
            animator.Play("prepare");
        }
        GUILayout.EndVertical();
    }
}
