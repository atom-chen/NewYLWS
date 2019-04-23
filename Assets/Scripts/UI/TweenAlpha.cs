using UnityEngine;
using UnityEngine.UI;
using XLua;
using DG.Tweening;
using System;

[Hotfix]
[LuaCallCSharp]
public class TweenAlpha : MonoBehaviour {

    public static Tweener Begin(Graphic graphic, TweenCallback completeCallback, float duration, float  startAlpha, float endAlpha, int loops, LoopType loopType)
    {
        if (graphic == null)
        {
            return null;
        }

        graphic.transform.DOKill(true);
        Tweener t = DG.Tweening.DOTween.To((float a) =>
        {
            if (graphic != null)
            {
                Color color = graphic.color;
                color.a = a;
                graphic.color = color;
            }
        }, startAlpha, endAlpha, duration);

        t.SetLoops(loops, loopType);
        if (completeCallback != null)
        {
            t.OnComplete(completeCallback);
        }
        return t;
    }


    public static void DOKill(Image image)
    {
        if (image == null)
        {
            return;
        }
        image.transform.DOKill(true);
    }
}
