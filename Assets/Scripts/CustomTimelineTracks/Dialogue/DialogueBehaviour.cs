using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class DialogueBehaviour : PlayableBehaviour
{
    public string uiName = string.Empty;
    public string sParam1 = string.Empty;
    public string sParam2 = string.Empty;
    public float fParam1 = 0;
    public float fParam2 = 0;
    public int iParam1 = 0;
    public int iParam2 = 0;
    public int index = 0;
    public double startTime = 0;

	private bool m_clipPlayed = false;
	private PlayableDirector m_director;
    private Timeline m_timeline;

    public override void OnPlayableCreate(Playable playable)
	{
		m_director = (playable.GetGraph().GetResolver() as PlayableDirector);
        if (m_director != null)
        {
            m_timeline = m_director.GetComponent<Timeline>();
        }
    }

    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        if (!m_clipPlayed && info.weight > 0f)
        {
            if (m_timeline != null)
            {
                m_timeline.DialogClipStart(index, startTime);
            }
            m_clipPlayed = true;
        }
    }

    public override void OnPlayableDestroy(Playable playable)
    {
        m_clipPlayed = false;
        m_director = null;
        m_timeline = null;
    }
}
