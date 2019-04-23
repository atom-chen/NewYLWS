using UnityEngine;
using System.Collections;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class FogWithNoise : MonoBehaviour
{

	//public Shader fogShader;
	public Material fogMaterial = null;

	//public Material material {  
	//	get {
	//		fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
	//		return fogMaterial;
	//	}  
	//}
	
	private Camera myCamera;
    private Transform myCameraTransform;

    public Camera thisCamera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

	public Transform cameraTransform {
		get {
			if (myCameraTransform == null) {
				myCameraTransform = thisCamera.transform;
			}
			
			return myCameraTransform;
		}
	}

	[Range(0.1f, 3.0f)]
	public float fogDensity = 1.0f;

	public Color fogColor = Color.white;

	public float fogStart = 0.0f;
	public float fogEnd = 2.0f;

	//public Texture noiseTexture;

	[Range(-0.5f, 0.5f)]
	public float fogXSpeed = 0.1f;

	[Range(-0.5f, 0.5f)]
	public float fogYSpeed = 0.1f;

	[Range(0.0f, 3.0f)]
	public float noiseAmount = 1.0f;

	void Start()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            enabled = false;
            return;
        }

        if (fogMaterial == null || thisCamera == null)
        {
            enabled = false;
            return;
        }
        thisCamera.depthTextureMode |= DepthTextureMode.Depth;
	}

    private void OnDestroy()
    {
        myCameraTransform = null;
        myCamera = null;
    }

    void OnRenderImage (RenderTexture src, RenderTexture dest)
    {
		if (fogMaterial != null)
        {
			Matrix4x4 frustumCorners = Matrix4x4.identity;
			
			float fov = thisCamera.fieldOfView;
			float near = thisCamera.nearClipPlane;
			float aspect = thisCamera.aspect;
			
			float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
			Vector3 toRight = cameraTransform.right * halfHeight * aspect;
			Vector3 toTop = cameraTransform.up * halfHeight;
			
			Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
			float scale = topLeft.magnitude / near;
			
			topLeft.Normalize();
			topLeft *= scale;
			
			Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
			topRight.Normalize();
			topRight *= scale;
			
			Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
			bottomLeft.Normalize();
			bottomLeft *= scale;
			
			Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
			bottomRight.Normalize();
			bottomRight *= scale;
			
			frustumCorners.SetRow(0, bottomLeft);
			frustumCorners.SetRow(1, bottomRight);
			frustumCorners.SetRow(2, topRight);
			frustumCorners.SetRow(3, topLeft);
			
			fogMaterial.SetMatrix("_FrustumCornersRay", frustumCorners);
            
			fogMaterial.SetFloat("_FogDensity", fogDensity);
			fogMaterial.SetColor("_FogColor", fogColor);
			fogMaterial.SetFloat("_FogStart", fogStart);
			fogMaterial.SetFloat("_FogEnd", fogEnd);
            
			//fogMaterial.SetTexture("_NoiseTex", noiseTexture);
			fogMaterial.SetFloat("_FogXSpeed", fogXSpeed);
			fogMaterial.SetFloat("_FogYSpeed", fogYSpeed);
            fogMaterial.SetFloat("_NoiseAmount", noiseAmount);

			Graphics.Blit (src, dest, fogMaterial);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
