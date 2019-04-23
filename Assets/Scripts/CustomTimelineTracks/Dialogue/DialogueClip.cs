using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class DialogueClip : PlayableAsset, ITimelineClipAsset
{
    public DialogueBehaviour param = new DialogueBehaviour ();

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<DialogueBehaviour>.Create (graph, param);
        
        return playable;
    }
}
