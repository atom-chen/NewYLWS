using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
[TrackClipType(typeof(CustomAnimShot))]
[TrackMediaType(TimelineAsset.MediaType.Script)]
[TrackBindingType(typeof(Animator))]
[TrackColor(0f, 0.0f, 0.9f)]
public class CustomAnimTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        foreach (var c in GetClips())
        {
            CustomAnimShot shot = (CustomAnimShot)c.asset;
            if (string.IsNullOrEmpty(shot.animName))
            {
                c.displayName = "CustomAnimClip";
            }
            else
            {
                c.displayName = shot.animName;
            }
        }

        var mixer = ScriptPlayable<CustomAnimMixer>.Create(graph);
        mixer.SetInputCount(inputCount);
        return mixer;
    }
}
