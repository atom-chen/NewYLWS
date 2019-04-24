using UnityEditor;
using System;
using UnityEngine;

[CustomEditor(typeof(CommandClip))]
public class CommandClipInspector : Editor
{
    private CommandType m_commandType = CommandType.NONE;
    private SerializedProperty commandIDProperty = null;
    private SerializedProperty sParam1Property = null;
    private SerializedProperty fParam1Property = null;
    private SerializedProperty iParam1Property = null;

    private GUIContent timeContent = new GUIContent("Time :");
    private GUIContent alphaContent1 = new GUIContent("FromAlpha :");
    private GUIContent alphaContent2 = new GUIContent("ToAlpha :");
    private GUIContent targetContent = new GUIContent("武将ID列表 :");
    private GUIContent heightContent = new GUIContent("影子高度 :");
    private GUIContent animNameContent = new GUIContent("AnimName :");
    private GUIContent rotateContent = new GUIContent("Rotate Angle Y :");

    private void OnEnable()
    {
        SerializedProperty paramProperty = serializedObject.FindProperty("param");
        commandIDProperty = paramProperty.FindPropertyRelative("commandID");
        sParam1Property = paramProperty.FindPropertyRelative("sParam1");
        fParam1Property = paramProperty.FindPropertyRelative("fParam1");
        iParam1Property = paramProperty.FindPropertyRelative("iParam1");
    }

    public override void OnInspectorGUI()
    {
        CommandType commandType = (CommandType)commandIDProperty.intValue;

        commandType = (CommandType)EditorGUILayout.EnumPopup("CommandType :", commandType);
        commandIDProperty.intValue = (int)commandType;

        switch (commandType)
        {
            case CommandType.ENABLE_UI_CLICK:
                bool isClickable = iParam1Property.intValue == 1;
                isClickable = EditorGUILayout.Toggle("Enable UI Click:", isClickable);
                iParam1Property.intValue = isClickable ? 1 : 0;
                break;
            case CommandType.SHOW_SUMMON_SCREEN_EFFECT:
                EditorGUILayout.PropertyField(fParam1Property, timeContent);
                break;
            case CommandType.HIDE_SUMMON_SCREEN_EFFECT:
                EditorGUILayout.PropertyField(fParam1Property, timeContent);
                break;
            case CommandType.SHOW_SCREEN_EFFECT:
                EditorGUILayout.PropertyField(fParam1Property, timeContent);
                bool isCoverUI = iParam1Property.intValue == 1;
                isCoverUI = EditorGUILayout.Toggle("CoverUI:", isCoverUI);
                iParam1Property.intValue = isCoverUI ? 1 : 0;
                break;
            case CommandType.SHOW_ALL_WUJIANG:
                bool isLeft = iParam1Property.intValue == 1;
                isLeft = EditorGUILayout.Toggle("IsLeft:", isLeft);
                iParam1Property.intValue = isLeft ? 1 : 2;
                break;
            case CommandType.HIDE_ALL_WUJIANG:
                isLeft = iParam1Property.intValue == 1;
                isLeft = EditorGUILayout.Toggle("IsLeft:", isLeft);
                iParam1Property.intValue = isLeft ? 1 : 2;
                break;
            case CommandType.HIDE_SCREEN_EFFECT:
                EditorGUILayout.PropertyField(fParam1Property, timeContent);
                break;
            case CommandType.TWEEN_SCREEN_EFFECT_ALPHA:
                string[] sParamList = sParam1Property.stringValue.Split(',');
                string showTime = string.Empty;
                string fromAlpha = string.Empty;
                string toAlpha = string.Empty;
                if (sParamList != null && sParamList.Length >= 3)
                {
                    showTime = sParamList[0];
                    fromAlpha = sParamList[1];
                    toAlpha = sParamList[2];
                }
                showTime = EditorGUILayout.TextField(timeContent, showTime);
                fromAlpha = EditorGUILayout.TextField(alphaContent1, fromAlpha);
                toAlpha = EditorGUILayout.TextField(alphaContent2, toAlpha);
                sParam1Property.stringValue = string.Format("{0},{1},{2}", showTime, fromAlpha, toAlpha);
                break;
            case CommandType.SET_SHADOW_HEIGHT:
                EditorGUILayout.PropertyField(sParam1Property, targetContent);
                EditorGUILayout.PropertyField(fParam1Property, heightContent);
                break;
            case CommandType.UI_WUJIANG_ANIM:
                isLeft = iParam1Property.intValue == 1;
                isLeft = EditorGUILayout.Toggle("IsLeft:", isLeft);
                iParam1Property.intValue = isLeft ? 1 : 2;
                EditorGUILayout.PropertyField(sParam1Property, animNameContent);
                break;
            case CommandType.UI_WUJIANG_ROTATE:
                isLeft = iParam1Property.intValue == 1;
                isLeft = EditorGUILayout.Toggle("IsLeft:", isLeft);
                iParam1Property.intValue = isLeft ? 1 : 2;
                EditorGUILayout.PropertyField(fParam1Property, rotateContent);
                break;
            case CommandType.CAMERA_SHAKE:
                EditorGUILayout.PropertyField(fParam1Property, new GUIContent("震动时间 :"));
                EditorGUILayout.PropertyField(sParam1Property, new GUIContent("震动强度 :"));
                EditorGUILayout.PropertyField(iParam1Property, new GUIContent("震动次数 :"));
                break;
            case CommandType.SET_GUIDED:
                EditorGUILayout.PropertyField(iParam1Property, new GUIContent("引导ID :"));
                break;
            case CommandType.CLOSE_UI:
                {
                    EditorGUILayout.PropertyField(sParam1Property, new GUIContent("UI名字 :"));
                }
                break;
            case CommandType.SET_TIME_SCALE:
                {
                    EditorGUILayout.PropertyField(fParam1Property, new GUIContent("时间缩放倍数 :"));
                }
                break;
        }

        serializedObject.ApplyModifiedProperties();
    }

    public enum CommandType
    {
        NONE,
        ENABLE_UI_CLICK = 1,
        SHOW_SUMMON_SCREEN_EFFECT = 2,
        HIDE_SUMMON_SCREEN_EFFECT = 3,
        SHOW_SCREEN_EFFECT = 4,
        HIDE_SCREEN_EFFECT = 5,
        TWEEN_SCREEN_EFFECT_ALPHA = 6,
        HIDE_ALL_WUJIANG = 7,
        SHOW_ALL_WUJIANG = 8,
        SET_SHADOW_HEIGHT = 9,
        UI_WUJIANG_ANIM  = 10,
        UI_WUJIANG_ROTATE = 11,
        CAMERA_SHAKE = 12,
        SET_GUIDED = 13,
        HIDE_DEAD_WUJIANG = 14, 
        CLOSE_UI = 15,
        SET_TIME_SCALE = 16,
    }
}
