using UnityEngine;
using UnityEditor;

namespace TMPro
{
    [AddComponentMenu("UI/HX_TMProText", 12), DisallowMultipleComponent, ExecuteInEditMode, RequireComponent(typeof(RectTransform)), RequireComponent(typeof(CanvasRenderer))]
    public class HX_TextMeshProUGUI : TextMeshProUGUI
    {
        protected override void LoadFontAsset()
        {
            ShaderUtilities.GetShaderPropertyIDs();
            if (this.m_fontAsset == null)
            {
#if UNITY_EDITOR
                this.m_fontAsset = AssetDatabase.LoadAssetAtPath<TMP_FontAsset>("Assets/AssetsPackage/UI/Fonts/SIMHEI2 SDF.asset");
#endif
                if (this.m_fontAsset == null)
                {
                    Debug.LogError("TextMesh Font Asset was not found. path: Assets/AssetsPackage/UI/Fonts/SIMHEI2 SDF.asset");
                    return;
                }
                if (this.m_fontAsset.characterDictionary == null)
                {
                    Debug.Log("Dictionary is Null!");
                }
                this.m_sharedMaterial = this.m_fontAsset.material;
            }
            else
            {
                base.LoadFontAsset();
            }
            base.GetSpecialCharacters(this.m_fontAsset);
            this.m_padding = this.GetPaddingForMaterial();
            this.SetMaterialDirty();
        }
    }
}
