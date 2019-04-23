using UnityEngine;

public class GrayscaleEffect : MonoBehaviour
{
    private static GrayscaleEffect s_grayscaleEffect = null;
    private Material m_material = null;

    public static void ApplyEffect(Material mat)
    {
        if (mat == null)
        {
            return;
        }

        GameObject cameraGO = Camera.main.gameObject;
        if (cameraGO == null)
        {
            return;
        }

        if (s_grayscaleEffect != null)
        {
            Destroy(s_grayscaleEffect);
            s_grayscaleEffect = null;
        }

        s_grayscaleEffect = cameraGO.AddComponent<GrayscaleEffect>();
        s_grayscaleEffect.Init(new Material(mat));
    }

    public void Init(Material mat)
    {
        m_material = mat;
    }

    void OnDisable()
    {
        if (s_grayscaleEffect != null)
        {
            Destroy(s_grayscaleEffect);
            s_grayscaleEffect = null;
        }

        if (m_material != null)
        {
            Destroy(m_material);
            m_material = null;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (m_material != null)
        {
            Graphics.Blit(src, dest, m_material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}