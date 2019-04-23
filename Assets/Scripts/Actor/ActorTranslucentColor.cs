using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace Battle_Actor
{
    [Hotfix]
    [LuaCallCSharp]
    public class ActorTranslucentColor : MonoBehaviour
    {
        private float m_finalAlpha = 0;
        private float m_alphaLeftS = 0;

        private float m_oldAlpha = 1f;
        private float m_alphaChangeTimeS = 0;
        private float m_alphaChangeLeftS = 0;

        private GameObject objThis;
        private Renderer[] renderList;

        private Vector4 vector4 = Vector4.one;
        private bool isPause = false;

        public void Clear()
        {
            m_alphaLeftS = 0;
            m_alphaChangeTimeS = 0;
            m_alphaChangeLeftS = 0;
            isPause = false;

            ClearAlphaFactor();
        }


        void Update()
        {
            if (isPause)
            {
                return;
            }


            float deltaTime = Time.deltaTime;

            if (m_alphaLeftS > 0)
            {
                m_alphaLeftS -= deltaTime;
                m_alphaChangeLeftS -= deltaTime;

                if (m_alphaLeftS <= 0)
                {
                    ClearAlphaFactor();
                }
            }

            if (m_alphaChangeTimeS > 0f && m_alphaChangeLeftS > 0f)
            {
                RefleshCurrentAlpha();
            }
        }

        void Awake()
        {
            objThis = gameObject;
            renderList = gameObject.GetComponentsInChildren<Renderer>(true);
        }

        void OnDestroy()
        {
            Clear();

            renderList = null;
        }

        public int AddColorFactor(Color color, int priority, float durationTime, float inTime = 0f, float outTime = 0f)
        {
            return 0;
        }

        public void RemoveColorFactorByKey(int key) { }

        public void AddColorPowerFactor(float colorPower = 2f, float time = 0.1f) { }

        public void ClearColorPowerFactor() { }

        public void RefleshCurrentColorPower() { }

        public void SetActorColorPower(float power) { }

        public void AddAlphaFactor(float alpha, float time = float.MaxValue)
        {

        }

        public void AddAlphaFactor(float alpha, float changeTime, float time)
        {
            m_finalAlpha = alpha;

            m_alphaLeftS = time;

            m_alphaChangeTimeS = changeTime;
            m_alphaChangeLeftS = changeTime;
           
            m_oldAlpha = GetActorAlpha();

            RefleshCurrentAlpha();
        }

        public void ClearAlphaFactor()
        {
            m_alphaLeftS = 0f;
            m_finalAlpha = m_oldAlpha;

            m_alphaChangeTimeS = -1f;
            m_alphaChangeLeftS = -1f;
            RefleshCurrentAlpha();
        }

        public void RefleshCurrentAlpha()
        {
            if (m_alphaChangeTimeS > 0f && m_alphaChangeLeftS > 0f)
            {
                SetActorAlpha(m_oldAlpha + (m_finalAlpha - m_oldAlpha) * (1f - m_alphaChangeLeftS / m_alphaChangeTimeS));
            }
            else
            {
                SetActorAlpha(m_finalAlpha);
            }
        }

        public float GetActorAlpha()
        {
            if (renderList != null)
            {
                for (int i = 0; i < renderList.Length; i++)
                {
                    if (renderList[i] == null)
                    {
                        continue;
                    }
                    Material mat = renderList[i].material;
                    if (mat == null)
                    {
                        continue;
                    }

                    if (mat.HasProperty("_TintColor"))
                    {
                        vector4 = mat.GetVector("_TintColor");
                        return vector4.w;
                    }
                }
            }

            return 1;
        }

        public void SetActorAlpha(float alpha)
        {
            if (renderList != null)
            {
                for (int i = 0; i < renderList.Length; i++)
                {
                    if (renderList[i] == null)
                    {
                        continue;
                    }
                    Material mat = renderList[i].material;
                    if (mat == null)
                    {
                        continue;
                    }

                    if (mat.HasProperty("_TintColor"))
                    {
                        vector4.w = alpha;
                        mat.SetVector("_TintColor", vector4);
                    }
                }
            }
        }

        public void RefleshCurrentColor() { }

        public void SetActorColor(Color color) { }

        //清空变色
        public void ClearColor() { }

        public void Pause()
        {
            isPause = true;
        }

        public void Resume()
        {
            isPause = false;
        }

        public void SetOriginPower(float power) { }
    }
}