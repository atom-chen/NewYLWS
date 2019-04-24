using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;
using UnityEditor;

[RequireComponent(typeof(Image))]
[AddComponentMenu("UI/Texture/UIBgTextureAdjustor")]
public class UIBgTextureAdjustor : MonoBehaviour
{
    private CanvasScaler m_canvasScaler = null;
    private Canvas m_canvas = null;

    void Awake()
    {
        m_canvasScaler = GameObject.FindObjectOfType<CanvasScaler>();
        if (m_canvasScaler != null)
        {
            m_canvas = m_canvasScaler.GetComponent<Canvas>();

            UpdateImageSize();
        }
    }

    public void UpdateImageSize()
    {
        if (m_canvasScaler == null || m_canvas == null)
        {
            return;
        }

        Image bg = GetComponent<Image>();
        if (bg != null)
        {
            Sprite texture = bg.sprite;
            if (texture == null || bg.type != Image.Type.Simple)
            {
                return;
            }
            bg.SetNativeSize();

            Vector2 resolution = m_canvasScaler.referenceResolution;
            Vector2 screen = screenSize;

            float rateX = resolution.x / screen.x;
            float rateY = resolution.y / screen.y;
            float realScaleRate = rateX > rateY ? rateX : rateY;

            float real_width = screen.x * realScaleRate;
            float real_height = screen.y * realScaleRate;
            float texture_width = bg.rectTransform.sizeDelta.x;
            float texture_height = bg.rectTransform.sizeDelta.y;
           
            float active_aspect = real_width / real_height;
            float texture_aspect = texture_width / texture_height;

            if (active_aspect > texture_aspect)
            {
                //按宽度适配
                real_width += 4;
                bg.rectTransform.sizeDelta = new Vector2(real_width, real_width / texture_aspect);
            }
            else
            {
                //按高度适配
                real_height += 4;
                bg.rectTransform.sizeDelta = new Vector2(real_height * texture_aspect, real_height);
            }
        }
    }

#if UNITY_EDITOR
    static int mSizeFrame = -1;
    static System.Reflection.MethodInfo s_GetSizeOfMainGameView;
    static Vector2 mGameSize = Vector2.one;

    static public Vector2 screenSize
    {
        get
        {
            int frame = Time.frameCount;

            if (mSizeFrame != frame || !Application.isPlaying)
            {
                mSizeFrame = frame;

                if (s_GetSizeOfMainGameView == null)
                {
                    System.Type type = System.Type.GetType("UnityEditor.GameView,UnityEditor");
                    s_GetSizeOfMainGameView = type.GetMethod("GetSizeOfMainGameView",
                        System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
                }
                mGameSize = (Vector2)s_GetSizeOfMainGameView.Invoke(null, null);
            }
            return mGameSize;
        }
    }
#else
	static public Vector2 screenSize { get { return new Vector2(Screen.width, Screen.height); } }
#endif

}

