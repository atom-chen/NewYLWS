using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;
using System.Collections.Generic;

[Hotfix]
[LuaCallCSharp]
[TrackColor(0f, 0.903f, 0f)]
[TrackClipType(typeof(CommandClip))]
public class CommandTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        PlayableDirector director = graph.GetResolver() as PlayableDirector;
        if (director != null)
        {
            Timeline timeline = director.GetComponent<Timeline>();
            List<CommandClipData> dataList = new List<CommandClipData>();
            int index = 1;
            foreach (var c in GetClips())
            {
                CommandClip clip = (CommandClip)c.asset;
                CommandClipData data = new CommandClipData();
                data.commandID = clip.param.commandID;
                data.sParam1 = clip.param.sParam1;
                data.fParam1 = clip.param.fParam1;
                data.iParam1 = clip.param.iParam1;
                data.startTime = c.start;
                data.index = index;
                clip.param.index = index;
                clip.param.startTime = c.start;
                index++;
                dataList.Add(data);
            }
            timeline.CommandTrackInited(dataList);
        }

        return base.CreateTrackMixer(graph, go, inputCount);
    }
}
