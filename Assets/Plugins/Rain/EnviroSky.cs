////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////        EnviroSky- Renders a SkyDome with sun,moon,clouds and weather.          ////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

using UnityEngine;
using System;
using System.Collections.Generic;
using System.Collections;


[Serializable]
public class ObjectVariables // References - setup these in inspector! Or use the provided prefab.
{
	public GameObject Atmosphere = null;
	public GameObject Clouds = null;
}


[Serializable] 
public class LightVariables // All Lightning Variables
{
	[Header("Direct Light")]
    public float SunIntensity = 0.75f;
	public float MoonIntensity = 0.5f;
	public float MoonPhase = 0.0f;

	public Gradient DirectLightColor;
	public Gradient SunDiskColor;

	[Header("Ambient Light")]
	public Gradient AmbientLightColor;
	public AnimationCurve ambientLightIntenisty;

	[Header("Stars")]
	public AnimationCurve starsIntensity;
	[HideInInspector]public float SunWeatherMod = 0.0f;
}


[Serializable]
public class FogSettings 
{
	public FogMode Fogmode;
    public float linearStartDistance;
    public float linearEndDistance;
    public float expDensity;
}

[Serializable]
public class CloudVariables // Default cloud settings, will be changed on runtime if Weather is enabled!
{
	[Header("Runtime Settings")]
	public Color BaseColor;
	public Color ShadingColor;
    public float Coverage = 1.0f; 
	public float Sharpness = 0.5f;
	public Vector2 WindDir = new Vector2 (1f, 1f);
    [Range(0, 2)]
    public float Scale = 0.666f;
    [Range(0, 25)]
    public float HorizonBlend = 6.5f;
    public float cloudChangeSpeed = 0.001f;
}

[Serializable]
public class AtmosphereVariables
{
    [Header("Runtime Settings")]
    public Color SunColor;
    public Vector4 SunDir;
}

[ExecuteInEditMode]
[AddComponentMenu("Enviro/Sky System")]
public class EnviroSky : MonoBehaviour
{
    // Parameters
	public ObjectVariables Components = null;
	public CloudVariables Clouds = null;
	public FogSettings Fog = null;
    public AtmosphereVariables Atmosphere = null;
    
	// Private Variables
	private int domeSeg = 32;

    //Some Pointers
    private Transform DomeTransform;
	private Material  AtmosphereMaterial;
    private Material  FlatCloudMaterial;
    
    public Camera PlayerCamera;
    public float UpdateInterval = 99999;

    // PI
    const float pi = Mathf.PI;
    private float passed = 0;

    void OnEnable()
    {
        DomeTransform = transform;

		// Setup Fog
		RenderSettings.fogMode = Fog.Fogmode;
		//Check for needed Objects and define startup vars 
		if (Components.Atmosphere)
        {
			AtmosphereMaterial = Components.Atmosphere.GetComponent<Renderer>().sharedMaterial;

			MeshFilter filter = Components.Atmosphere.GetComponent<MeshFilter>();

            if (filter != null)
            {
                if (filter.sharedMesh != null)
                {
                    UnityEngine.Object.DestroyImmediate(filter.sharedMesh);
                }
				// Create the gradientDome mesh and assign it
                Mesh mesh = new Mesh();
				CreateDome(mesh, domeSeg);
                filter.sharedMesh = mesh;
            }
        }
        else
        {
            Debug.LogError("Please set Atmosphere object in inspector!");
            this.enabled = false;
        }

		if (Components.Clouds)
        {
			FlatCloudMaterial = Components.Clouds.GetComponent<Renderer>().sharedMaterial;
        }
		else if (Components.Clouds == null)
		{
			Debug.LogError("Please set FastClouds object in inspector!");
			this.enabled = false;
		}

        SetupShader();
        UpdateFog();
    }
    		
    void LateUpdate()
    {
		if(!PlayerCamera)
		{
            //Debug.LogError("Please assign your MainCamera in EnviroMgr-component!");
            PlayerCamera = Camera.main;
		}

        if (PlayerCamera != null)
        {
            transform.position = PlayerCamera.transform.position;
            transform.localScale = new Vector3(PlayerCamera.farClipPlane - (PlayerCamera.farClipPlane * 0.1f), PlayerCamera.farClipPlane - (PlayerCamera.farClipPlane * 0.1f), PlayerCamera.farClipPlane - (PlayerCamera.farClipPlane * 0.1f));
        }

        passed += Time.deltaTime;
        if (passed >= UpdateInterval)
        {
            passed = 0;

            SetupShader();
            UpdateFog();
        }
    }

	// Setup the Shaders with correct information
    private void SetupShader()
    {
        if (AtmosphereMaterial != null)
        {
            AtmosphereMaterial.SetColor("_SunColor", Atmosphere.SunColor);
            AtmosphereMaterial.SetVector("_SunDirection", Atmosphere.SunDir);
            //AtmosphereShader.SetMatrix ("_Rotation", SunTransform.worldToLocalMatrix);
        }
        
		if (FlatCloudMaterial != null)
        {
			FlatCloudMaterial.SetColor("_BaseColor", Clouds.BaseColor);
			FlatCloudMaterial.SetColor("_ShadingColor", Clouds.ShadingColor);
			FlatCloudMaterial.SetFloat("_CloudCover", Clouds.Coverage);
			FlatCloudMaterial.SetFloat("_CloudSharpness", Clouds.Sharpness);
			FlatCloudMaterial.SetVector("_CloudSpeed", Clouds.WindDir);
            FlatCloudMaterial.SetFloat("_CloudScale", Clouds.Scale);
            FlatCloudMaterial.SetFloat("_horizonBlend", Clouds.HorizonBlend);
        }
    }
    
    void UpdateFog()
    {
        RenderSettings.fogMode = Fog.Fogmode;
        if (Fog.Fogmode == FogMode.Linear)
        {
            RenderSettings.fogStartDistance = Mathf.Lerp(RenderSettings.fogStartDistance, Fog.linearStartDistance, 0.01f);
            RenderSettings.fogEndDistance = Mathf.Lerp(RenderSettings.fogEndDistance, Fog.linearEndDistance, 0.01f);
        }
        else
            RenderSettings.fogDensity = Mathf.Lerp(RenderSettings.fogDensity, Fog.expDensity, 0.01f);
    }



    //Create the skyDome mesh
    void CreateDome (Mesh mesh, int segments)
    {
        Vector3[] vertices = new Vector3[segments * (segments - 1) + 2];
        Vector3[] normals = new Vector3[segments * (segments - 1) + 2];
        Vector2[] uv = new Vector2[segments * (segments - 1) + 2];

        int[] indices = new int[2 * segments * (segments - 1) * 3];

        float deltaLatitude = pi / (float)segments;
        float deltaLongitude = pi * 2.0f / (float )segments;

        // Generate the rings
        int index = 0;
        for (int i = 1; i < segments; i++) 
		{
            float r0 = Mathf.Sin (i * deltaLatitude);
            float y0 = Mathf.Cos (i * deltaLatitude);

            for (int j = 0; j < segments; j++) 
			{
                float x0 = r0 * Mathf.Sin (j * deltaLongitude);
                float z0 = r0 * Mathf.Cos (j * deltaLongitude);

                vertices[index].x = x0;
                vertices[index].y = y0;
                vertices[index].z = z0;

                normals[index].x = -x0;
                normals[index].y = -y0;
                normals[index].z = -z0;

                uv[index].x = 0;
                uv[index].y = 1 - y0;

                index++;
            }
        }

        // Generate the UPside
        vertices[index].x = 0;
        vertices[index].y = 1;
        vertices[index].z = 0;

        normals[index].x = 0;
        normals[index].y = -1;
        normals[index].z = 0;

        uv[index].x = 0;
        uv[index].y = 0;

        index++;

        vertices[index].x = 0;
        vertices[index].y = -1;
        vertices[index].z = 0;

        normals[index].x = 0;
        normals[index].y = 1;
        normals[index].z = 0;

        uv[index].x = 0;
        uv[index].y = 2;

        index = 0;
        // Generate the midSide
        for (int i = 0; i < segments - 2; i++) 
		{
            for (int j = 0; j < segments; j++) 
			{
                indices[index++] = segments * i + j;
                indices[index++] = segments * i + (j + 1) % segments;
                indices[index++] = segments * (i + 1) + (j + 1) % segments;
                indices[index++] = segments * i + j;
                indices[index++] = segments * (i + 1) + (j + 1) % segments;
                indices[index++] = segments * (i + 1) + j;
            }
        }

        // Generate the upper cap
        for (int i = 0; i < segments; i++) 
		{
            indices[index++] = segments * (segments - 1);
            indices[index++] = (i + 1) % segments;
            indices[index++] = i;
        }

        // Generate the lower cap
        for (int i = 0; i < segments; i++)
		{
            indices[index++] = segments * (segments - 1) + 1;
            indices[index++] = segments * (segments - 2) + i;
            indices[index++] = segments * (segments - 2) + (i + 1) % segments;
        }

        mesh.vertices = vertices;
        mesh.normals = normals;
        mesh.uv = uv;
        mesh.triangles = indices;
    }
}
