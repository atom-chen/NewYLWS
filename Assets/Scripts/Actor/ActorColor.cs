using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace Battle_Actor
{
    [Hotfix]
    [LuaCallCSharp]
    public class ActorColor : MonoBehaviour
    {
        private class ColorFactor
        {
            public Color color;
            public int priority;
            public float inTime;
            public float durationTime;
            public float outTime;

            public int key = 0;
            private float lifeTime = 0.01f;
            private float power = 0f;

            public Color GetCurrentColor()
            {
                return color * power;
            }

            public float GetPower()
            {
                return power;
            }

            private float CalculatePower()
            {
                if (lifeTime > inTime)
                {
                    if (lifeTime > inTime + durationTime)
                    {
                        if (lifeTime > inTime + durationTime + outTime)
                        {
                            return 0f;
                        }
                        else
                        {
                            return 1f - (lifeTime - inTime - durationTime) / outTime;
                        }
                    }
                    else
                    {
                        return 1f;
                    }
                }
                else
                {
                    return lifeTime / inTime;
                }
            }

            public void UpdateTime(float deltaTime)
            {
                lifeTime += deltaTime;
                power = CalculatePower();
            }

            public bool IsFinish()
            {
                return lifeTime > inTime + durationTime + outTime;
            }
        }

        static readonly Color NoneColor = new Color(0f, 0f, 0f, 0f);
        const float REFLESH_INTERVAL = 0.3f;

        private List<ColorFactor> m_colorFactorList = new List<ColorFactor>();
        private Color finalColor;
        private int newestKey = 1;

        private float m_originPower = 1;
        private float m_finalPower = 0;
        private float m_powerLeftS = 0;

        private float m_finalAlpha = 0;
        private float m_alphaLeftS = 0;

        private float m_oldAlpha = 0f;
        private float m_alphaChangeTimeS = 0;
        private float m_alphaChangeLeftS = 0;

        private float m_leftRefleshTime = 0f;

        private GameObject objThis;
        private Renderer[] renderList;

        private bool isPause = false;

        private static int ShaderID_Power = Shader.PropertyToID("_power");
        private static int ShaderID_AlphaPower = Shader.PropertyToID("_AlphaPower");
        private static int ShaderID_EffectColor = Shader.PropertyToID("_EffectColor");

        void Awake()
        {
            objThis = gameObject;
            renderList = gameObject.GetComponentsInChildren<Renderer>(true);
        }


        public void Clear()
        {
            newestKey = 1;
            m_finalPower = 0;
            m_powerLeftS = 0;

            m_finalAlpha = 0;
            m_alphaLeftS = 0;

            m_oldAlpha = 0f;
            m_alphaChangeTimeS = 0;
            m_alphaChangeLeftS = 0;
            m_leftRefleshTime = 0f;
            isPause = false;

            ClearAlphaFactor();
            ClearColorPowerFactor();

        }

        void Update()
        {
            if(isPause)
            {
                return;
            }

            float deltaTime = Time.deltaTime;

            if (m_colorFactorList != null)
            {
                for (int i = m_colorFactorList.Count - 1; i >= 0; --i)
                {
                    m_colorFactorList[i].UpdateTime(deltaTime);
                    if (m_colorFactorList[i].IsFinish())
                    {
                        m_colorFactorList.RemoveAt(i);
                    }
                }
            }

            if (m_powerLeftS > 0)
            {
                m_powerLeftS -= deltaTime;

                if (m_powerLeftS <= 0)
                {
                    ClearColorPowerFactor();
                }
            }

            if (m_alphaLeftS > 0)
            {
                m_alphaLeftS -= deltaTime;
                m_alphaChangeLeftS -= deltaTime;

                if (m_alphaLeftS <= 0)
                {
                    ClearAlphaFactor();
                }
            }


            m_leftRefleshTime -= Time.unscaledTime;
            if (m_leftRefleshTime < 0f)
            {
                RefleshCurrentColor();
                m_leftRefleshTime += REFLESH_INTERVAL;
            }

            if (m_alphaChangeTimeS > 0f && m_alphaChangeLeftS > 0f)
            {
                RefleshCurrentAlpha();
            }
        }

        void OnDestroy()
        {
            Clear();

            renderList = null;
        }

        public int AddColorFactor(Color color, int priority, float durationTime, float inTime = 0f, float outTime = 0f)
        {
            ColorFactor colorFactor = new ColorFactor();
            colorFactor.color = color;
            colorFactor.priority = priority;
            colorFactor.inTime = inTime;
            colorFactor.durationTime = durationTime;
            colorFactor.outTime = outTime;
            colorFactor.key = newestKey;
            ++newestKey;

            m_colorFactorList.Add(colorFactor);
            m_colorFactorList.Sort((ColorFactor a, ColorFactor b) => { return a.priority - b.priority; });
            return colorFactor.key;
        }

        public void RemoveColorFactorByKey(int key)
        {
            if (m_colorFactorList != null)
            {
                for (int i = m_colorFactorList.Count - 1; i >= 0; --i)
                {
                    if (m_colorFactorList[i].key == key)
                    {
                        m_colorFactorList.RemoveAt(i);
                        break;
                    }
                }
            }
            RefleshCurrentColor();
        }

        public void AddColorPowerFactor(float colorPower = 2f, float time = 0.1f)
        {
            m_finalPower = colorPower;

            m_powerLeftS = time;

            RefleshCurrentColorPower();
        }

        public void ClearColorPowerFactor()
        {
            m_powerLeftS = 0f;
            m_finalPower = m_originPower;
            RefleshCurrentColorPower();
        }

        public void RefleshCurrentColorPower()
        {
            SetActorColorPower(m_finalPower);
        }

        public void SetActorColorPower(float power)
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

                    if (mat.HasProperty(ShaderID_Power))
                    {
                        mat.SetFloat(ShaderID_Power, power);
                    }
                }
            }
        }

        public void AddAlphaFactor(float alpha, float time = float.MaxValue)
        {
            m_finalAlpha = alpha;

            m_alphaLeftS = time;

            m_alphaChangeTimeS = -1f;
            m_alphaChangeLeftS = -1f;

            RefleshCurrentAlpha();
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
            m_finalAlpha = 1f;

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

                    if (mat.HasProperty(ShaderID_AlphaPower))
                    {
                        return mat.GetFloat(ShaderID_AlphaPower);
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

                    if (renderList[i].materials != null)
                    {
                        for (int k = 0; k < renderList[i].materials.Length; k++)
                        {
                            Material mat = renderList[i].materials[k];
                            if (mat != null)
                            {
                                if (mat.HasProperty(ShaderID_AlphaPower))
                                {
                                    mat.SetFloat(ShaderID_AlphaPower, alpha);
                                }
                            }
                        }
                    }
                }
            }
        }

        public void RefleshCurrentColor()
        {
            finalColor = NoneColor;
            if (m_colorFactorList != null)
            {
                if (m_colorFactorList.Count > 0)
                {
                    finalColor = m_colorFactorList[m_colorFactorList.Count - 1].GetCurrentColor();
                }
            }
            SetActorColor(finalColor);
        }

        public void SetActorColor(Color color)
        {
            if (renderList != null)
            {
                for (int i = 0; i < renderList.Length; i++)
                {
                    if (renderList[i] == null)
                    {
                        continue;
                    }

                    if (renderList[i].materials != null)
                    {
                        for (int k = 0; k < renderList[i].materials.Length; k++)
                        {
                            Material mat = renderList[i].materials[k];
                            if (mat != null)
                            {
                                if (mat.HasProperty(ShaderID_EffectColor))
                                {
                                    mat.SetColor(ShaderID_EffectColor, color);
                                }
                            }
                        }
                    }                    
                }
            }
        }

        //清空变色
        public void ClearColor()
        {
            if(m_colorFactorList != null)
            {
                m_colorFactorList.Clear();
            }

            RefleshCurrentColor();

            ClearColorPowerFactor();
        }
        
        public void Pause()
        {
            isPause = true;
        }

        public void Resume()
        {
            isPause = false;
        }


        //设置初始亮度
        public void SetOriginPower(float power)
        {
            m_originPower = power;

            ClearColorPowerFactor();
        }
    }
}