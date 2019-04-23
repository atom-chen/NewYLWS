using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ObjectExplosion : MonoBehaviour {

	bool _needClear = false;

	List<Rigidbody> rigidbodys = new List<Rigidbody>();

	// Use this for initialization
    //void Awake () {

    //}

	void DealWithItem(){
		MeshFilter[] meshs = gameObject.GetComponentsInChildren<MeshFilter>();
		foreach (var mesh in meshs)
		{
			AddMissingComponent<BoxCollider>(mesh.gameObject);
			//mesh.gameObject.AddMissingComponent<BoxCollider>();
			
			Rigidbody rb = AddMissingComponent<Rigidbody>(mesh.gameObject);
			rb.mass = 1f;
			rb.drag = 1f;
			rb.angularDrag = 0.5f;
			rb.useGravity = useGravity;
			rb.isKinematic = false;
			//rb.Sleep();
			rigidbodys.Add(rb);
		}
	}

    //void Start(){

    //}

    T AddMissingComponent<T>(GameObject go) where T : Component
    {
#if UNITY_FLASH
        object comp = go.GetComponent<Component>();
#else
        Component comp = go.GetComponent<T>();
#endif
        if (comp == null)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
                RegisterUndo(go, "Add " + typeof(T));
#endif
            comp = go.AddComponent<T>();
        }
#if UNITY_FLASH
		return (Component)comp;
#else
        return (T)comp;
#endif
    }

    public void RegisterUndo(UnityEngine.Object obj, string name)
    {
#if UNITY_EDITOR
        UnityEditor.Undo.RecordObject(obj, name);
        SetDirty(obj);
#endif
    }

    static public void SetDirty(UnityEngine.Object obj)
    {
#if UNITY_EDITOR
        if (obj)
        {
            //if (obj is Component) Debug.Log(NGUITools.GetHierarchy((obj as Component).gameObject), obj);
            //else if (obj is GameObject) Debug.Log(NGUITools.GetHierarchy(obj as GameObject), obj);
            //else Debug.Log("Hmm... " + obj.GetType(), obj);
            UnityEditor.EditorUtility.SetDirty(obj);
        }
#endif
    }

    void Clear(){
		if(clearDestory){
			DestroyImmediate(gameObject);
		}else{
			gameObject.SetActive(false);
		}
	}

	float timeFlag = 0;

	void Update(){
		if(_needClear){
			if(timeFlag == 0) timeFlag = Time.time;
			if(Time.time - timeFlag > clearTime){
				Clear();
			}
		}
	}

	public Vector3 explosionPos = Vector3.zero;
	public float radius = 5F;
	public float power = 500.0F;
	public float upward = 3f;
	public bool autoClear = true;
	public float clearTime = 1f;
	public bool clearDestory = true;
	public bool useGravity = false;


	// Update is called once per frame
	public void Explosion () {

		DealWithItem();
//		foreach (Rigidbody rb in rigidbodys) {
//			rb.WakeUp();
//		}

		Vector3 pos = transform.TransformPoint(explosionPos);
		Collider[] colliders = Physics.OverlapSphere(pos, radius);
		foreach (Collider hit in colliders) {
			if (!hit)
				continue; 
			if (hit.GetComponent<Rigidbody>())
				hit.GetComponent<Rigidbody>().AddExplosionForce(power, pos, radius, upward);
		}

		if(autoClear){
			_needClear = true;
		}
	}

	private void OnDrawGizmos()
	{
		if (this.enabled)
		{
			DrawVisualization();
		}
	}

	private void DrawVisualization(){

		Vector3 tmp = transform.TransformPoint(explosionPos);
		Gizmos.color = new Color(1,0,0,1f);
		Gizmos.DrawCube(tmp, Vector3.one * radius / 10);
		Gizmos.color = new Color(1,1,1,0.5f);
		Gizmos.DrawWireSphere(tmp, radius);
		//Gizmos.DrawSphere(tmp,radius);
	}
}
