using UnityEditor;
using System;
using UnityEngine;

[CustomEditor(typeof(WaitEventClip))]
public class WaitEventClipInspector : Editor
{
    private SerializedProperty waitWhatEventProperty = null;
    private SerializedProperty sParam1Property = null;
    private SerializedProperty fParam1Property = null;
    private SerializedProperty iParam1Property = null;

    private GUIContent timeContent = new GUIContent("Time :");
    private GUIContent alphaContent1 = new GUIContent("FromAlpha :");
    private GUIContent alphaContent2 = new GUIContent("ToAlpha :");

    private void OnEnable()
    {
        SerializedProperty paramProperty = serializedObject.FindProperty("param");
        waitWhatEventProperty = paramProperty.FindPropertyRelative("waitWhatEvent");
        sParam1Property = paramProperty.FindPropertyRelative("sParam1");
        fParam1Property = paramProperty.FindPropertyRelative("fParam1");
        iParam1Property = paramProperty.FindPropertyRelative("iParam1");
    }

    public override void OnInspectorGUI()
    {
        EventType eventType = (EventType)waitWhatEventProperty.intValue;
        eventType = (EventType)EditorGUILayout.EnumPopup("Event Type :", eventType);
        waitWhatEventProperty.intValue = (int)eventType;

        switch (eventType)
        {
            case EventType.CLOSE_UI_END:
                string uiName = sParam1Property.stringValue;
                PlotUI plotUI = PlotUI.UIPlotDialog;
                if (!string.IsNullOrEmpty(uiName))
                {
                    plotUI = (PlotUI)Enum.Parse(typeof(PlotUI), uiName);
                }
                plotUI = (PlotUI)EditorGUILayout.EnumPopup("UI Name :", plotUI);
                sParam1Property.stringValue = plotUI.ToString();
                break;
            case EventType.SHOW_UI_END:
                EditorGUILayout.PropertyField(sParam1Property, new GUIContent("UI名字 :"));
                break;
        }

        serializedObject.ApplyModifiedProperties();
    }

    public enum EventType
    {
        NONE,
        SHOW_UI_START = 17,             // 开始显示某UI
        CLOSE_UI_END = 18,              //某UI关闭
        CLICK_UI = 19,                          // 点击UI物件
        PLOT_TIMELINE_END = 20,     // 剧情关闭
        SHOW_UI_END = 21,               // UI完全打开，有些是异步加载
        CHILD_UI_SHOW_END = 22,   // 子UI显示完成
        SHENBING_OPERATION_FINISH = 23, //神兵装备、强化
        TWEEN_END = 24,                 //界面中各种Tween位移
        EQUIP_HORSE = 25,               //装备坐骑
    }
}
