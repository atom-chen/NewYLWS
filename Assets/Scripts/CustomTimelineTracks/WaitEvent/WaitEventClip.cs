using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class WaitEventClip : PlayableAsset, ITimelineClipAsset
{
    public WaitEventBehaviour param = new WaitEventBehaviour();

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<WaitEventBehaviour>.Create (graph, param);
        
        return playable;
    }
}
