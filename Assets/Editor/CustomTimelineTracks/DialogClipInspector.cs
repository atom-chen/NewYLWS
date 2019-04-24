using UnityEditor;
using System;
using UnityEngine;

[CustomEditor(typeof(DialogueClip))]
public class DialogClipInspector : Editor
{
    private PlotUI m_plotUI = PlotUI.UIPlotDialog;
    private SerializedProperty uiNameProperty = null;
    private SerializedProperty sParam1Property = null;
    private SerializedProperty sParam2Property = null;
    private SerializedProperty fParam1Property = null;
    private SerializedProperty fParam2Property = null;
    private SerializedProperty iParam1Property = null;
    private SerializedProperty iParam2Property = null;

    private GUIContent msgContent = new GUIContent("内容 :");
    private GUIContent charactorNameContent = new GUIContent("武将名字 :");
    private GUIContent showTimeContent = new GUIContent("显示时间 :");
    private GUIContent posXContent = new GUIContent("X轴位置 :");
    private GUIContent posYContent = new GUIContent("Y轴位置 :");
    private GUIContent wujiangScaleContent = new GUIContent("武将缩放 :");
    private GUIContent wujiangIDContent = new GUIContent("武将ID :");
    private GUIContent weaponLevelContent = new GUIContent("武器等级 :");
    private GUIContent wujiangPosXContent = new GUIContent("武将X轴位置 :");
    private GUIContent wujiangPosYContent = new GUIContent("武将Y轴位置 :");
    private GUIContent wujiangAnimContent = new GUIContent("武将初始动作 :");
    private GUIContent wujiangRotateYContent = new GUIContent("武将Y轴旋转 :");

    private void OnEnable()
    {
        SerializedProperty paramProperty = serializedObject.FindProperty("param");
        uiNameProperty = paramProperty.FindPropertyRelative("uiName");
        sParam1Property = paramProperty.FindPropertyRelative("sParam1");
        sParam2Property = paramProperty.FindPropertyRelative("sParam2");
        fParam1Property = paramProperty.FindPropertyRelative("fParam1");
        fParam2Property = paramProperty.FindPropertyRelative("fParam2");
        iParam1Property = paramProperty.FindPropertyRelative("iParam1");
        iParam2Property = paramProperty.FindPropertyRelative("iParam2");
    }

    public override void OnInspectorGUI()
    {
        string uiName = uiNameProperty.stringValue;
        PlotUI plotUI = PlotUI.UIPlotDialog;
        if (!string.IsNullOrEmpty(uiName))
        {
            plotUI = (PlotUI)Enum.Parse(typeof(PlotUI), uiName);
        }
        plotUI = (PlotUI)EditorGUILayout.EnumPopup("UI Name :", plotUI);
        uiNameProperty.stringValue = plotUI.ToString();

        switch (plotUI)
        { 
            case PlotUI.UIPlotDialog:
                EditorGUILayout.PropertyField(sParam1Property, msgContent);
                EditorGUILayout.PropertyField(sParam2Property, charactorNameContent);
                break;
            case PlotUI.UIPlotTextDialog:
                EditorGUILayout.PropertyField(sParam1Property, msgContent);
                EditorGUILayout.PropertyField(fParam1Property, showTimeContent);
                break;
            case PlotUI.UIPlotTopBottomHeidi:
                bool isClickable = fParam1Property.floatValue == 1f;
                isClickable = EditorGUILayout.Toggle("打开:", isClickable);
                fParam1Property.floatValue = isClickable ? 1 : 0;
                bool skipToEnd = fParam2Property.floatValue == 0f;
                skipToEnd = EditorGUILayout.Toggle("是否恢复相机:", skipToEnd);
                fParam2Property.floatValue = skipToEnd ? 0 : 1;
                break;
            case PlotUI.UIPlotBubbleDialog:
                EditorGUILayout.PropertyField(sParam1Property, msgContent);
                EditorGUILayout.PropertyField(sParam2Property, charactorNameContent);
                bool isRight = fParam1Property.floatValue == 1f;
                isRight = EditorGUILayout.Toggle("显示在右边？:", isRight);
                fParam1Property.floatValue = isRight ? 1 : 0;
                EditorGUILayout.PropertyField(iParam1Property, posXContent);
                EditorGUILayout.PropertyField(iParam2Property, posYContent);
                break;
            case PlotUI.UIPlotWujiangDialog:
                {
                    EditorGUILayout.PropertyField(sParam2Property, charactorNameContent);
                    EditorGUILayout.PropertyField(iParam2Property, msgContent);
                    EditorGUILayout.PropertyField(fParam2Property, wujiangIDContent);
                    EditorGUILayout.PropertyField(iParam1Property, weaponLevelContent);
                    bool iswujiangLeft = fParam1Property.floatValue == 1f;
                    iswujiangLeft = EditorGUILayout.Toggle("显示在左边？:", iswujiangLeft);
                    fParam1Property.floatValue = iswujiangLeft ? 1 : 0;

                    string[] sParamList = sParam1Property.stringValue.Split(',');
                    string wujiangScale = "400";
                    bool isSkipToEnd = true;
                    string wujiangPosX = "500";
                    string wujiangPosY = "-100";
                    bool isCloseWhenClick = true;
                    string anim = "nil"; // 默认填个nil吧，lua字符串分割有问题，不能识别string.Empty
                    bool isPlayImmediate = true;
                    string wujiangRotateY = "180";
                    string animSpeed = "1";
                    if (sParamList != null)
                    {
                        for (int i = 0; i < 9; i++)
                        {
                            if (i == 0 && sParamList.Length >= (i + 1)) wujiangScale = sParamList[i];
                            else if (i == 1 && sParamList.Length >= (i + 1)) isSkipToEnd = sParamList[i] == "1" ? true : false;
                            else if (i == 2 && sParamList.Length >= (i + 1)) wujiangPosX = sParamList[i];
                            else if (i == 3 && sParamList.Length >= (i + 1)) wujiangPosY = sParamList[i];
                            else if (i == 4 && sParamList.Length >= (i + 1)) isCloseWhenClick = sParamList[i] == "1" ? true : false;
                            else if (i == 5 && sParamList.Length >= (i + 1)) anim = sParamList[i];
                            else if (i == 6 && sParamList.Length >= (i + 1)) isPlayImmediate = sParamList[i] == "1" ? true : false;
                            else if (i == 7 && sParamList.Length >= (i + 1)) wujiangRotateY = sParamList[i];
                            else if (i == 8 && sParamList.Length >= (i + 1)) animSpeed = sParamList[i];
                        }
                    }
                    if (string.IsNullOrEmpty(anim)) anim = "nil";
                    wujiangScale = EditorGUILayout.TextField(wujiangScaleContent, wujiangScale);
                    wujiangPosX = EditorGUILayout.TextField(wujiangPosXContent, wujiangPosX);
                    wujiangPosY = EditorGUILayout.TextField(wujiangPosYContent, wujiangPosY);
                    isSkipToEnd = EditorGUILayout.Toggle("是否恢复相机？:", isSkipToEnd);
                    isCloseWhenClick = EditorGUILayout.Toggle("点击时关闭UI？:", isCloseWhenClick);
                    anim = EditorGUILayout.TextField(wujiangAnimContent, anim);
                    isPlayImmediate = EditorGUILayout.Toggle("立即播放动作: ", isPlayImmediate);
                    wujiangRotateY = EditorGUILayout.TextField(wujiangRotateYContent, wujiangRotateY);
                    animSpeed = EditorGUILayout.TextField(new GUIContent("动画播放速度"), animSpeed);
                    sParam1Property.stringValue = string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8}", wujiangScale, isSkipToEnd ? "1" : "0", wujiangPosX, wujiangPosY, isCloseWhenClick ? "1" : "0", anim, isPlayImmediate ? "1" : "0", wujiangRotateY, animSpeed);
                    break;
                }
            case PlotUI.UIGuideWujiangDialog:
                {
                    EditorGUILayout.PropertyField(sParam2Property, charactorNameContent);
                    EditorGUILayout.PropertyField(iParam2Property, msgContent);
                    EditorGUILayout.PropertyField(fParam2Property, wujiangIDContent);
                    EditorGUILayout.PropertyField(iParam1Property, weaponLevelContent);
                    bool iswujiangLeft = fParam1Property.floatValue == 1f;
                    iswujiangLeft = EditorGUILayout.Toggle("显示在左边？:", iswujiangLeft);
                    fParam1Property.floatValue = iswujiangLeft ? 1 : 0;

                    string[] sParamList = sParam1Property.stringValue.Split(',');
                    string wujiangScale = "400";
                    bool isShowSkip = true;
                    string wujiangPosX = "500";
                    string wujiangPosY = "-100";
                    bool isCloseWhenClick = true;
                    string anim = "nil"; // 默认填个nil吧，lua字符串分割有问题，不能识别string.Empty
                    bool isPlayImmediate = true;
                    string wujiangRotateY = "180";
                    bool isCloseMainUI = false;
                    string animSpeed = "1";

                    if (sParamList != null)
                    {
                        for (int i = 0; i < 10; i++)
                        {
                            if (i == 0 && sParamList.Length >= (i + 1)) wujiangScale = sParamList[i];
                            else if (i == 1 && sParamList.Length >= (i + 1)) isShowSkip = sParamList[i] == "1" ? true : false;
                            else if (i == 2 && sParamList.Length >= (i + 1)) wujiangPosX = sParamList[i];
                            else if (i == 3 && sParamList.Length >= (i + 1)) wujiangPosY = sParamList[i];
                            else if (i == 4 && sParamList.Length >= (i + 1)) isCloseWhenClick = sParamList[i] == "1" ? true : false;
                            else if (i == 5 && sParamList.Length >= (i + 1)) anim = sParamList[i];
                            else if (i == 6 && sParamList.Length >= (i + 1)) isPlayImmediate = sParamList[i] == "1" ? true : false;
                            else if (i == 7 && sParamList.Length >= (i + 1)) wujiangRotateY = sParamList[i];
                            else if (i == 8 && sParamList.Length >= (i + 1)) isCloseMainUI = sParamList[i] == "1";
                            else if (i == 9 && sParamList.Length >= (i + 1)) animSpeed = sParamList[i];
                        }
                    }
                    if (string.IsNullOrEmpty(anim)) anim = "nil";
                    isCloseMainUI = EditorGUILayout.Toggle("关闭主界面？:", isCloseMainUI);
                    wujiangScale = EditorGUILayout.TextField(wujiangScaleContent, wujiangScale);
                    wujiangPosX = EditorGUILayout.TextField(wujiangPosXContent, wujiangPosX);
                    wujiangPosY = EditorGUILayout.TextField(wujiangPosYContent, wujiangPosY);
                    isShowSkip = EditorGUILayout.Toggle("显示跳过 :", isShowSkip);
                    isCloseWhenClick = EditorGUILayout.Toggle("点击时关闭UI？:", isCloseWhenClick);
                    anim = EditorGUILayout.TextField(wujiangAnimContent, anim);
                    isPlayImmediate = EditorGUILayout.Toggle("立即播放动作: ", isPlayImmediate);
                    wujiangRotateY = EditorGUILayout.TextField(wujiangRotateYContent, wujiangRotateY);
                    animSpeed = EditorGUILayout.TextField(new GUIContent("动画播放速度"), animSpeed);
                    sParam1Property.stringValue = string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}", wujiangScale, isShowSkip ? "1" : "0", wujiangPosX,
                                                    wujiangPosY, isCloseWhenClick ? "1" : "0", anim, isPlayImmediate ? "1" : "0", wujiangRotateY, isCloseMainUI ? "1" : "0", animSpeed);
                    break;
                }
            case PlotUI.UIFingerGuideDialog:
                {
                    EditorGUILayout.PropertyField(fParam2Property, new GUIContent("标题 :"));
                    EditorGUILayout.PropertyField(fParam1Property, msgContent);
                    
                    string[] sParam2List = sParam2Property.stringValue.Split(',');
                    int iEventType = 0;
                    string eventParam = string.Empty;
                    bool isCheckGuideExecption = false;
                    string execptionID = "0";
                    string skipToTime = "0";
                    if (sParam2List != null)
                    {
                        for (int i = 0; i < 5; i++)
                        {
                            if (i == 0 && sParam2List.Length >= (i + 1)) int.TryParse(sParam2List[i], out iEventType);
                            else if (i == 1 && sParam2List.Length >= (i + 1)) eventParam = sParam2List[i];
                            else if (i == 2 && sParam2List.Length >= (i + 1)) isCheckGuideExecption = sParam2List[i] == "1";
                            else if (i == 3 && sParam2List.Length >= (i + 1)) execptionID = sParam2List[i];
                            else if (i == 4 && sParam2List.Length >= (i + 1)) skipToTime = sParam2List[i];
                        }
                    }
                    WaitEventClipInspector.EventType eventType = (WaitEventClipInspector.EventType)iEventType;
                    eventType = (WaitEventClipInspector.EventType)EditorGUILayout.EnumPopup("事件类型 :", eventType);
                    iEventType = ((int)eventType);
                    eventParam = EditorGUILayout.TextField(new GUIContent("事件参数 :"), eventParam);
                    isCheckGuideExecption = EditorGUILayout.Toggle("是否检查引导异常", isCheckGuideExecption);
                    if (isCheckGuideExecption)
                    {
                        EditorGUI.indentLevel += 2;
                        execptionID = EditorGUILayout.TextField(new GUIContent("异常ID :"), execptionID);
                        skipToTime = EditorGUILayout.TextField(new GUIContent("跳转到哪（时间） :"), skipToTime);
                        EditorGUI.BeginDisabledGroup(true);
                        GUIStyle style = new GUIStyle();
                        style.normal.textColor = new Color(1f, 0.2f, 0.2f);
                        EditorGUILayout.TextField("这个是引导异常检查，ID在GuideDef.lua中找到对应的，如果检查到\n引导异常，跳转到指定的时间节点继续执行", style);
                        EditorGUI.EndDisabledGroup();
                        GUILayout.Space(10);
                        EditorGUI.indentLevel -= 2;
                    }
                    sParam2Property.stringValue = string.Format("{0},{1},{2},{3},{4}", iEventType, eventParam, isCheckGuideExecption ? "1" : "0", execptionID, skipToTime);

                    EditorGUILayout.PropertyField(iParam1Property, posXContent);
                    EditorGUILayout.PropertyField(iParam2Property, posYContent);

                    string[] sParamList = sParam1Property.stringValue.Split(',');
                    string targetUIName = string.Empty;
                    string highLightChild = string.Empty;
                    string focusTarget = string.Empty;
                    string focusTargetIndex = "0";
                    string fingerRotate = "0|0";
                    string fingerOffset = "0|0";
                    
                    if (sParamList != null)
                    {
                        for (int i = 0; i < 6; i++)
                        {
                            if (i == 0 && sParamList.Length >= (i + 1)) targetUIName = sParamList[i];
                            else if (i == 1 && sParamList.Length >= (i + 1)) highLightChild = sParamList[i];
                            else if (i == 2 && sParamList.Length >= (i + 1)) focusTarget = sParamList[i];
                            else if (i == 3 && sParamList.Length >= (i + 1)) focusTargetIndex = sParamList[i];
                            else if (i == 4 && sParamList.Length >= (i + 1)) fingerRotate = sParamList[i];
                            else if (i == 5 && sParamList.Length >= (i + 1)) fingerOffset = sParamList[i];
                        }
                    }
                    targetUIName = EditorGUILayout.TextField(new GUIContent("UI名字 :"), targetUIName);
                    highLightChild = EditorGUILayout.TextField(new GUIContent("高亮节点 :"), highLightChild);
                    focusTarget = EditorGUILayout.TextField(new GUIContent("操作对象父节点 :"), focusTarget);
                    focusTargetIndex = EditorGUILayout.TextField(new GUIContent("操作对象节点index :"), focusTargetIndex);
                    fingerRotate = EditorGUILayout.TextField(new GUIContent("手指旋转y|z :"), fingerRotate);
                    fingerOffset = EditorGUILayout.TextField(new GUIContent("手指偏移x|y :"), fingerOffset);

                    sParam1Property.stringValue = string.Format("{0},{1},{2},{3},{4},{5}", targetUIName, highLightChild, focusTarget, focusTargetIndex, fingerRotate, fingerOffset);
                break;
                }
            case PlotUI.PauseTimeline:
                {
                    WaitEventClipInspector.EventType eventType = (WaitEventClipInspector.EventType)iParam1Property.intValue;
                    eventType = (WaitEventClipInspector.EventType)EditorGUILayout.EnumPopup("事件类型 :", eventType);
                    iParam1Property.intValue = ((int)eventType);
                    sParam1Property.stringValue = EditorGUILayout.TextField(new GUIContent("事件参数 :"), sParam1Property.stringValue);
                }
                break;
            case PlotUI.UIInscriptionFingerGuideDialog:
                {
                    EditorGUILayout.PropertyField(fParam2Property, new GUIContent("标题 :"));

                    string[] sParam2List = sParam2Property.stringValue.Split(',');
                    int iEventType = 0;
                    string eventParam = string.Empty;
                    bool isCheckGuideExecption = false;
                    string execptionID = "0";
                    string skipToTime = "0";
                    if (sParam2List != null)
                    {
                        for (int i = 0; i < 5; i++)
                        {
                            if (i == 0 && sParam2List.Length >= (i + 1)) int.TryParse(sParam2List[i], out iEventType);
                            else if (i == 1 && sParam2List.Length >= (i + 1)) eventParam = sParam2List[i];
                            else if (i == 2 && sParam2List.Length >= (i + 1)) isCheckGuideExecption = sParam2List[i] == "1";
                            else if (i == 3 && sParam2List.Length >= (i + 1)) execptionID = sParam2List[i];
                            else if (i == 4 && sParam2List.Length >= (i + 1)) skipToTime = sParam2List[i];
                        }
                    }
                    WaitEventClipInspector.EventType eventType = (WaitEventClipInspector.EventType)iEventType;
                    eventType = (WaitEventClipInspector.EventType)EditorGUILayout.EnumPopup("事件类型 :", eventType);
                    iEventType = ((int)eventType);
                    eventParam = EditorGUILayout.TextField(new GUIContent("事件参数 :"), eventParam);
                    isCheckGuideExecption = EditorGUILayout.Toggle("是否检查引导异常", isCheckGuideExecption);
                    if (isCheckGuideExecption)
                    {
                        EditorGUI.indentLevel += 2;
                        execptionID = EditorGUILayout.TextField(new GUIContent("异常ID :"), execptionID);
                        skipToTime = EditorGUILayout.TextField(new GUIContent("跳转到哪（时间） :"), skipToTime);
                        EditorGUI.BeginDisabledGroup(true);
                        GUIStyle style = new GUIStyle();
                        style.normal.textColor = new Color(1f, 0.2f, 0.2f);
                        EditorGUILayout.TextField("这个是引导异常检查，ID在GuideDef.lua中找到对应的，如果检查到\n引导异常，跳转到指定的时间节点继续执行", style);
                        EditorGUI.EndDisabledGroup();
                        GUILayout.Space(10);
                        EditorGUI.indentLevel -= 2;
                    }
                    sParam2Property.stringValue = string.Format("{0},{1},{2},{3},{4}", iEventType, eventParam, isCheckGuideExecption ? "1" : "0", execptionID, skipToTime);

                    EditorGUILayout.PropertyField(iParam1Property, posXContent);
                    EditorGUILayout.PropertyField(iParam2Property, posYContent);

                    string[] sParamList = sParam1Property.stringValue.Split(',');
                    string targetUIName = string.Empty;
                    string focusWujiangID = string.Empty;
                    string focusTarget = string.Empty;
                    string focusPos = "0|0";
                    string fingerRotate = "0|0";
                    string fingerOffset = "0|0";
                    string msgList = "0";

                    if (sParamList != null)
                    {
                        for (int i = 0; i < 7; i++)
                        {
                            if (i == 0 && sParamList.Length >= (i + 1)) targetUIName = sParamList[i];
                            else if (i == 1 && sParamList.Length >= (i + 1)) focusWujiangID = sParamList[i];
                            else if (i == 2 && sParamList.Length >= (i + 1)) focusTarget = sParamList[i];
                            else if (i == 3 && sParamList.Length >= (i + 1)) focusPos = sParamList[i];
                            else if (i == 4 && sParamList.Length >= (i + 1)) fingerRotate = sParamList[i];
                            else if (i == 5 && sParamList.Length >= (i + 1)) fingerOffset = sParamList[i];
                            else if (i == 6 && sParamList.Length >= (i + 1)) msgList = sParamList[i];
                        }
                    }
                    targetUIName = EditorGUILayout.TextField(new GUIContent("UI名字 :"), targetUIName);
                    focusTarget = EditorGUILayout.TextField(new GUIContent("操作对象节点 :"), focusTarget);
                    focusWujiangID = EditorGUILayout.TextField(new GUIContent("操作对象角色ID :"), focusWujiangID);
                    focusPos = EditorGUILayout.TextField(new GUIContent("操作对象节点位置 :"), focusPos);
                    fingerRotate = EditorGUILayout.TextField(new GUIContent("手指旋转y|z :"), fingerRotate);
                    fingerOffset = EditorGUILayout.TextField(new GUIContent("手指偏移x|y :"), fingerOffset);
                    msgList = EditorGUILayout.TextField(new GUIContent("消息列表 :"), msgList);

                    sParam1Property.stringValue = string.Format("{0},{1},{2},{3},{4},{5},{6}", targetUIName, focusWujiangID, focusTarget, focusPos, fingerRotate, fingerOffset, msgList);
                    break;
                }
        }

        serializedObject.ApplyModifiedProperties();
    }
}

public enum PlotUI
{
    UIPlotTextDialog,
    UIPlotDialog,
    UIPlotTopBottomHeidi,
    UIPlotBubbleDialog,
    UIPlotWujiangDialog,
    UIGuideWujiangDialog,
    UIFingerGuideDialog,
    PauseTimeline,
    UIInscriptionFingerGuideDialog,
}
