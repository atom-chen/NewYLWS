using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using XLua;

[Hotfix]
[LuaCallCSharp]
[Serializable]
public class SkipBehaviour : PlayableBehaviour
{
	public SkipClipType clipType;
    public string nodeToJump;
    public string nodeName;
	public float timeToJump;

    [HideInInspector]
	public bool clipExecuted = false;

	public enum SkipClipType
	{
		Node,
		JumpToTime,
		JumpToNode,
	}
}
