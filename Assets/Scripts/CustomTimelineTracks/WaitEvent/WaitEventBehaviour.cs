using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class WaitEventBehaviour : PlayableBehaviour
{
    public int waitWhatEvent = 0;
    public string sParam1 = string.Empty;
    public int iParam1 = 0;
    public float fParam1 = 0;

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
                m_timeline.PauseClipStart(waitWhatEvent, sParam1, iParam1, fParam1);
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
