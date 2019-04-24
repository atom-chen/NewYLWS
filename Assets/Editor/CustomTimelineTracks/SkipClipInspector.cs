using UnityEditor;

[CustomEditor(typeof(SkipClip))]
public class SkipClipInspector : Editor
{
	private SerializedProperty clipTypeProp;

	private void OnEnable()
	{
		clipTypeProp = serializedObject.FindProperty("clipType");
	}

	public override void OnInspectorGUI()
	{
		EditorGUILayout.PropertyField(clipTypeProp);

		int index = clipTypeProp.enumValueIndex;
		SkipBehaviour.SkipClipType actionType = (SkipBehaviour.SkipClipType)index;

		switch(actionType)
		{
			case SkipBehaviour.SkipClipType.Node:
				EditorGUILayout.PropertyField(serializedObject.FindProperty("nodeName"));
				break;

			case SkipBehaviour.SkipClipType.JumpToNode:
				EditorGUILayout.PropertyField(serializedObject.FindProperty("nodeToJump"));
				break;
			
			case SkipBehaviour.SkipClipType.JumpToTime:
				EditorGUILayout.PropertyField(serializedObject.FindProperty("timeToJump"));
				break;
        }

		serializedObject.ApplyModifiedProperties();
	}
}
