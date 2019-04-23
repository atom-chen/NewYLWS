using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;
using System.Collections.Generic;

[Hotfix]
[LuaCallCSharp]
[TrackColor(0.855f, 0.903f, 0f)]
[TrackClipType(typeof(DialogueClip))]
public class DialogueTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        PlayableDirector director = graph.GetResolver() as PlayableDirector;
        if (director != null)
        {
            Timeline timeline = director.GetComponent<Timeline>();
            List<DialogClipData> dataList = new List<DialogClipData>();
            int index = 1;
            foreach (var c in GetClips())
            {
                DialogueClip clip = (DialogueClip)c.asset;
                DialogClipData data = new DialogClipData();
                data.uiName = clip.param.uiName;
                data.sParam1 = clip.param.sParam1;
                data.sParam2 = clip.param.sParam2;
                data.fParam1 = clip.param.fParam1;
                data.fParam2 = clip.param.fParam2;
                data.iParam1 = clip.param.iParam1;
                data.iParam2 = clip.param.iParam2;
                data.startTime = c.start;
                data.index = index;
                clip.param.index = index;
                clip.param.startTime = c.start;
                index++;
                dataList.Add(data);
            }
            timeline.DialogTrackInited(dataList);
        }

        return base.CreateTrackMixer(graph, go, inputCount);
    }
}
