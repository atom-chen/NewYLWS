using UnityEngine;
using UnityEngine.Playables;

public sealed class CustomAnimShotPlayable : PlayableBehaviour
{
    public string animName;
    [HideInInspector]
    public bool clipExecuted = false;
}

public sealed class CustomAnimShot : PlayableAsset
{
    public string animName;

    public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<CustomAnimShotPlayable>.Create(graph);
        playable.GetBehaviour().animName = animName;
        return playable;
    }
}
