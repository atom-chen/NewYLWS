using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using XLua;

/// <summary>
/// added by wsh @ 2018.01.03
/// 功能：Tip弹窗
/// </summary>

[Hotfix]
[LuaCallCSharp]
public class UINoticeTip : MonoSingleton<UINoticeTip>
{
    GameObject go;
    Text titleText;
    Text noticeText;
    Text buttonOneText;
    Text buttonTwoText;
    Button buttonOne;
    Button buttonTwo;
    GameObject buttonOneGo;
    GameObject buttonTwoGo;
    GameObject blockRaycastLayer;
    static int lastClickIndex = -1;

    static public int LastClickIndex
    {
        get
        {
            return lastClickIndex;
        }
        protected set
        {
            lastClickIndex = value;
        }
    }
    
    public bool IsShowing
    {
        get;
        protected set;
    }

    public GameObject UIGameObject
    {
        get
        {
            return go;
        }
        set
        {
            if (value != go)
            {
                go = value;
                InitGo(go);
            }
        }
    }

    private void InitGo(GameObject go)
    {
        if (go == null)
        {
            return;
        }

        titleText = go.transform.Find("BgRoot/titleText").GetComponent<Text>();
        noticeText = go.transform.Find("BgRoot/ContentRoot/msgText").GetComponent<Text>();
        buttonOneText = go.transform.Find("BgRoot/ContentRoot/btnGrid/One_BTN/ButtonOneText").GetComponent<Text>();
        buttonTwoText = go.transform.Find("BgRoot/ContentRoot/btnGrid/Two_BTN/ButtonTwoText").GetComponent<Text>();

        buttonOneGo = go.transform.Find("BgRoot/ContentRoot/btnGrid/One_BTN").gameObject;
        buttonTwoGo = go.transform.Find("BgRoot/ContentRoot/btnGrid/Two_BTN").gameObject;
        buttonOne = buttonOneGo.GetComponent<Button>();
        buttonTwo = buttonTwoGo.GetComponent<Button>();

        ResetView(IsShowing);
    }

    private void SetBlockGOActive(bool value)
    {
        if (blockRaycastLayer == null)
        {
            blockRaycastLayer = GameObject.Find("UIRoot/BlockRaycastLayer");
        }
        if (blockRaycastLayer)
        {
            blockRaycastLayer.SetActive(value);
        }
    }
    
    private void ResetView(bool isShow)
    {
        IsShowing = isShow;
        if (isShow)
        {
            LastClickIndex = -1;
        }

        if (go != null)
        {
            go.SetActive(isShow);
            buttonOneGo.SetActive(false);
            buttonTwoGo.SetActive(false);
            buttonOne.onClick.RemoveAllListeners();
            buttonTwo.onClick.RemoveAllListeners();
        }
    }

    void BindCallback(int index, Button button, Action callback)
    {
        button.onClick.AddListener(() =>
        {
            if (callback != null)
            {
                callback();
            }
            LastClickIndex = index;
            SetBlockGOActive(true);

            ResetView(false);
        });
    }
    
    public void ShowOneButtonTip(string title, string content, string btnText, Action callback)
    {
        if (go == null)
        {
            Logger.LogError("You should set UIGameObject first!");
            return;
        }

        SetBlockGOActive(false);
        ResetView(true);
        buttonTwoGo.SetActive(true);

        titleText.text = title;
        noticeText.text = content;
        buttonTwoText.text = btnText;
        BindCallback(0, buttonTwo, callback);
    }

    public void ShowTwoButtonTip(string title, string content, string btnText1, string btnText2, Action callback1, Action callback2)
    {
        if (go == null)
        {
            Logger.LogError("You should set UIGameObject first!");
            return;
        }

        SetBlockGOActive(false);
        ResetView(true);
        buttonOneGo.SetActive(true);
        buttonTwoGo.SetActive(true);

        titleText.text = title;
        noticeText.text = content;
        buttonOneText.text = btnText1;
        buttonTwoText.text = btnText2;

        BindCallback(0, buttonOne, callback1);
        BindCallback(1, buttonTwo, callback2);
    }

    public void HideTip()
    {
        if (go != null)
        {
            go.SetActive(false);
        }
    }

    [BlackList]
    public IEnumerator WaitForResponse()
    {
        yield return new WaitUntil(() => {
            return LastClickIndex != -1;
        });
        yield break;
    }

    public override void Dispose()
    {
        if (go != null)
        {
            Destroy(go);
        }

        base.Dispose();
    }
}
