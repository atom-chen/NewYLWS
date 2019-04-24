using System;
using UnityEngine;
using UnityEditor;

public class CustomRoughnessShaderGUI : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }

    private static class Styles
    {
        public static GUIContent albedoText = new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)");
        public static GUIContent albedoAlphaText = new GUIContent("AlbedoAlpha", "Albedo (RGB) and Transparency (A)");
        public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");
        public static GUIContent metallicMapText = new GUIContent("Metallic", "Metallic (R) and Smoothness (A)");
        public static GUIContent roughnessText = new GUIContent("Roughness", "Roughness value");
        public static GUIContent highlightsText = new GUIContent("Specular Highlights", "Specular Highlights");
        public static GUIContent normalMapText = new GUIContent("Normal Map", "Normal Map");
        public static GUIContent heightMapText = new GUIContent("Height Map", "Height Map (G)");
        public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
        public static GUIContent emissionText = new GUIContent("Color", "Emission (RGB)");
        public static GUIContent detailMaskText = new GUIContent("Detail Mask", "Mask for Secondary Maps (A)");
        public static GUIContent rimColorText = new GUIContent("RimColor");
        public static GUIContent rimScaleText = new GUIContent("RimScale");

        public static GUIContent fluLightTexText = new GUIContent("FluLightTex");
        public static GUIContent fluColorText = new GUIContent("FluColor");
        public static GUIContent fluIntervalText = new GUIContent("FluInterval");
        public static GUIContent fluTimeText = new GUIContent("FluTime");
        public static GUIContent frontierRangeText = new GUIContent("FrontierRange");
        public static GUIContent fluMaskText = new GUIContent("FluMask");

        public static string primaryMapsText = "Main Maps";
        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static string advancedText = "Advanced Options";
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
    }

    MaterialProperty blendMode = null;
    MaterialProperty albedoMap = null;
    MaterialProperty albedoAlphaMap = null;
    MaterialProperty albedoColor = null;
    MaterialProperty rimColor = null;
    MaterialProperty rimScale = null;

    MaterialProperty fluLightTex = null;
    MaterialProperty fluColor = null;
    MaterialProperty fluInterval = null;
    MaterialProperty fluTime = null;
    MaterialProperty frontierRange = null;
    MaterialProperty fluMask = null;

    MaterialProperty alphaCutoff = null;
    MaterialProperty metallicMap = null;
    MaterialProperty metallic = null;
    MaterialProperty roughness = null;
    MaterialProperty roughnessMap = null;
    MaterialProperty highlights = null;
    MaterialProperty bumpScale = null;
    MaterialProperty bumpMap = null;
    MaterialProperty occlusionStrength = null;
    MaterialProperty occlusionMap = null;
    MaterialProperty heigtMapScale = null;
    MaterialProperty heightMap = null;
    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;
    MaterialProperty detailMask = null;

    MaterialEditor m_MaterialEditor;

    bool m_FirstTimeApply = true;

    public void FindProperties(MaterialProperty[] props)
    {
        blendMode = FindProperty("_Mode", props);
        albedoMap = FindProperty("_MainTex", props);
        albedoAlphaMap = FindProperty("_AlphaTex", props);
        albedoColor = FindProperty("_Color", props);
        alphaCutoff = FindProperty("_Cutoff", props);
        rimColor = FindProperty("_RimColor", props);
        rimScale = FindProperty("_Scale", props);

        fluLightTex = FindProperty("_FluLightTex", props); ;
        fluColor = FindProperty("_FluColor", props); ;
        fluInterval = FindProperty("_FluInterval", props); ;
        fluTime = FindProperty("_FluTime", props); ;
        frontierRange = FindProperty("_FrontierRange", props); ;
        fluMask = FindProperty("_EffectMask", props); ;

        metallicMap = FindProperty("_MetallicGlossMap", props, false);
        metallic = FindProperty("_Metallic", props, false);
        roughness = FindProperty("_Glossiness", props);
        roughnessMap = FindProperty("_SpecGlossMap", props);
        highlights = FindProperty("_SpecularHighlights", props, false);
        bumpScale = FindProperty("_BumpScale", props);
        bumpMap = FindProperty("_BumpMap", props);
        heigtMapScale = FindProperty("_Parallax", props);
        heightMap = FindProperty("_ParallaxMap", props);
        occlusionStrength = FindProperty("_OcclusionStrength", props);
        occlusionMap = FindProperty("_OcclusionMap", props);
        emissionColorForRendering = FindProperty("_EmissionColor", props);
        emissionMap = FindProperty("_EmissionMap", props);
        detailMask = FindProperty("_DetailMask", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
        // material to a standard shader.
        // Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)
        if (m_FirstTimeApply)
        {
            MaterialChanged(material);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();

            // Primary properties
            GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);

            DoAlbedoArea(material);
            m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMapText, metallicMap, metallicMap.textureValue != null ? null : metallic);

            m_MaterialEditor.TexturePropertySingleLine(Styles.roughnessText, roughnessMap, roughnessMap.textureValue != null ? null : roughness);
            m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap, bumpMap.textureValue != null ? bumpScale : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap, heightMap.textureValue != null ? heigtMapScale : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.detailMaskText, detailMask);
            DoEmissionArea(material);
            EditorGUI.BeginChangeCheck();
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
            if (EditorGUI.EndChangeCheck())
            {
                albedoAlphaMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset;
                emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake
            }

            EditorGUILayout.Space();

            // Third properties
            GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);
            if (highlights != null)
                m_MaterialEditor.ShaderProperty(highlights, Styles.highlightsText);

            m_MaterialEditor.ShaderProperty(rimColor, Styles.rimColorText.text);
            m_MaterialEditor.ShaderProperty(rimScale, Styles.rimScaleText.text);

            m_MaterialEditor.TexturePropertySingleLine(Styles.fluLightTexText, fluLightTex, fluColor);
            m_MaterialEditor.TextureScaleOffsetProperty(fluLightTex);
            m_MaterialEditor.ShaderProperty(fluInterval, Styles.fluIntervalText.text);
            m_MaterialEditor.ShaderProperty(fluTime, Styles.fluTimeText.text);
            m_MaterialEditor.ShaderProperty(frontierRange, Styles.frontierRangeText.text);
            m_MaterialEditor.TexturePropertySingleLine(Styles.fluMaskText, fluMask);
        }
        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in blendMode.targets)
                MaterialChanged((Material)obj);
        }

        EditorGUILayout.Space();

        // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
        {
            SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
            return;
        }

        BlendMode blendMode = BlendMode.Opaque;
        if (oldShader.name.Contains("/Transparent/Cutout/"))
        {
            blendMode = BlendMode.Cutout;
        }
        else if (oldShader.name.Contains("/Transparent/"))
        {
            // NOTE: legacy shaders did not provide physically based transparency
            // therefore Fade mode
            blendMode = BlendMode.Fade;
        }
        material.SetFloat("_Mode", (float)blendMode);

        MaterialChanged(material);
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void DoAlbedoArea(Material material)
    {
        m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
        {
            m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
        }
        if (albedoAlphaMap != null)
        {
            m_MaterialEditor.TexturePropertySingleLine(Styles.albedoAlphaText, albedoAlphaMap);
        }
    }

    void DoEmissionArea(Material material)
    {
        // Emission for GI?
        if (m_MaterialEditor.EmissionEnabledProperty())
        {
            bool hadEmissionTexture = emissionMap.textureValue != null;

            // Texture and HDR color controls
            m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, false);

            // If texture was assigned and color was black set color to white
            float brightness = emissionColorForRendering.colorValue.maxColorComponent;
            if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
                emissionColorForRendering.colorValue = Color.white;

            // change the GI flag and fix it up with emissive as black if necessary
            m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
        }
    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }

    static void SetMaterialKeywords(Material material)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap") || material.GetTexture("_DetailNormalMap"));
        SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap"));
        SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));
        SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
        SetKeyword(material, "_DETAIL_MULX2", material.GetTexture("_DetailAlbedoMap") || material.GetTexture("_DetailNormalMap"));

        // A material's GI flag internally keeps track of whether emission is enabled at all, it's enabled but has no effect
        // or is enabled and may be modified at runtime. This state depends on the values of the current flag and emissive color.
        // The fixup routine makes sure that the material is in the correct state if/when changes are made to the mode or color.
        MaterialEditor.FixupEmissiveFlag(material);
        bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);
    }

    static void MaterialChanged(Material material)
    {
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));

        SetMaterialKeywords(material);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }
}
