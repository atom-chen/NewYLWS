using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[TrackColor(0.7366781f, 0.3261246f, 0.8529412f)]
[TrackClipType(typeof(SkipClip))]
public class SkipTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
		var scriptPlayable = ScriptPlayable<SkipMixerBehaviour>.Create(graph, inputCount);
		SkipMixerBehaviour skipMixer = scriptPlayable.GetBehaviour();
		skipMixer.markerClips = new System.Collections.Generic.Dictionary<string, double>();

		foreach (var c in GetClips())
		{
			SkipClip clip = (SkipClip)c.asset;
			string clipName = c.displayName;

			switch(clip.clipType)
			{
				case SkipBehaviour.SkipClipType.Node:
					clipName = "Node " + clip.nodeName.ToString();
					if(!skipMixer.markerClips.ContainsKey(clip.nodeName))
					{
						skipMixer.markerClips.Add(clip.nodeName, c.start);
					}
					break;
				case SkipBehaviour.SkipClipType.JumpToNode:
					clipName = "GOTO  " + clip.nodeToJump.ToString();
					break;
				case SkipBehaviour.SkipClipType.JumpToTime:
					clipName = "GOTO " + clip.timeToJump.ToString();
					break;
			}

            c.displayName = clipName;
        }

        return scriptPlayable;
    }


}
