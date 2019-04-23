using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
public class SkipMixerBehaviour : PlayableBehaviour
{
	public Dictionary<string, double> markerClips;

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

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
		if(!Application.isPlaying || m_timeline == null)
		{
			return;
		}

        int inputCount = playable.GetInputCount();
        for (int i = 0; i < inputCount; i++)
        {
            if (playable.GetInputWeight(i) <= 0f)
            {
                continue;
            }
            ScriptPlayable<SkipBehaviour> inputPlayable = (ScriptPlayable<SkipBehaviour>)playable.GetInput(i);
            SkipBehaviour input = inputPlayable.GetBehaviour();
            if (!input.clipExecuted)
			{
                input.clipExecuted = true;
                switch (input.clipType)
				{
					case SkipBehaviour.SkipClipType.JumpToTime:
                        m_timeline.SkipClipStart(input.timeToJump);
                        break;
					case SkipBehaviour.SkipClipType.JumpToNode:
                        m_timeline.SkipClipStart(markerClips[input.nodeToJump]);
                        break;
				}
			}
        }
    }

    public override void OnPlayableDestroy(Playable playable)
    {
        m_director = null;
        m_timeline = null;
    }
}
