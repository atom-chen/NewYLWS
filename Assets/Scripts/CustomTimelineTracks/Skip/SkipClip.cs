using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class SkipClip : PlayableAsset, ITimelineClipAsset
{
	[HideInInspector]
    public SkipBehaviour template = new SkipBehaviour ();

	public SkipBehaviour.SkipClipType clipType;
    public string nodeToJump = string.Empty;
    public string nodeName = string.Empty;
	public float timeToJump = 0f;

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<SkipBehaviour>.Create (graph, template);
        SkipBehaviour clone = playable.GetBehaviour ();
		clone.nodeToJump = nodeToJump;
		clone.clipType = clipType;
		clone.nodeName = nodeName;
		clone.timeToJump = timeToJump;

        return playable;
    }
}
