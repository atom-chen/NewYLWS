#region 程序集 DOTween.dll, v1.0.0.0
// F:\sanguo_client\NewYLWS\NYlwsTrunk\Assets\Plugins\DOTween\DOTween.dll
#endregion

using DG.Tweening.Core;
using DG.Tweening.Plugins.Core;
using System;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

namespace DOTween
{
    // 摘要: 
    //     Main DOTween class. Contains static methods to create and control tweens
    //     in a generic way
    public class DOTween
    {
        public static void Clear(bool destroy = false)
        {
            DG.Tweening.DOTween.Clear(destroy);
        }

        public static void Kill(object targetOrId, bool complete = false)
        {
            DG.Tweening.DOTween.Kill(targetOrId, complete);
        }

        public static int KillAll(bool complete = false)
        {
            return DG.Tweening.DOTween.KillAll(complete);
        }

        public static void ClearCachedTweens()
        {
            DG.Tweening.DOTween.ClearCachedTweens();
        }

        public static int CompleteAll(bool withCallbacks = false)
        {
            return DG.Tweening.DOTween.CompleteAll(withCallbacks);
        }

        public static int Pause(object targetOrId)
        {
            return DG.Tweening.DOTween.Pause(targetOrId);
        }

        public static int PauseAll()
        {
            return DG.Tweening.DOTween.PauseAll();
        }

        public static int PlayAll()
        {
            return DG.Tweening.DOTween.PlayAll();
        }

        public static TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> Punch(DOGetter<Vector3> getter, DOSetter<Vector3> setter, Vector3 direction, float duration, int vibrato = 10, float elasticity = 1f)
        {
            return DG.Tweening.DOTween.Punch(getter, setter, direction, duration, vibrato, elasticity);
        }

        public static int Restart(object targetOrId, bool includeDelay = true, float changeDelayTo = -1f)
        {
            return DG.Tweening.DOTween.Restart(targetOrId, includeDelay, changeDelayTo);
        }

        public static int Restart(object target, object id, bool includeDelay = true, float changeDelayTo = -1f)
        {
            return DG.Tweening.DOTween.Restart(target, id, includeDelay, changeDelayTo);
        }

        public static int RestartAll(bool includeDelay = true)
        {
            return DG.Tweening.DOTween.RestartAll(includeDelay);
        }

        public static void SetTweensCapacity(int tweenersCapacity, int sequencesCapacity)
        {
            DG.Tweening.DOTween.SetTweensCapacity(tweenersCapacity, sequencesCapacity);
        }

        public static TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> Shake(DOGetter<Vector3> getter, DOSetter<Vector3> setter, float duration, Vector3 strength, int vibrato = 10, float randomness = 90f, bool fadeOut = true)
        {
            return DG.Tweening.DOTween.Shake(getter, setter, duration, strength, vibrato, randomness, fadeOut);
        }

        public static TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> Shake(DOGetter<Vector3> getter, DOSetter<Vector3> setter, float duration, float strength = 3f, int vibrato = 10, float randomness = 90f, bool ignoreZAxis = true, bool fadeOut = true)
        {
            return DG.Tweening.DOTween.Shake(getter, setter, duration, strength, vibrato, randomness, fadeOut);
        }

        public static TweenerCore<Color, Color, DG.Tweening.Plugins.Options.ColorOptions> ToColorValue(DOGetter<Color> getter, DOSetter<Color> setter, Color endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<double, double, DG.Tweening.Plugins.Options.NoOptions> ToDoubleValue(DOGetter<double> getter, DOSetter<double> setter, double endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }
       
        public static TweenerCore<float, float, DG.Tweening.Plugins.Options.FloatOptions> ToFloatValue(DOGetter<float> getter, DOSetter<float> setter, float endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static Tweener To(DOSetter<float> setter, float startValue, float endValue, float duration)
        {
          
            return DG.Tweening.DOTween.To(setter, startValue, endValue, duration);
        }

        public static Tweener ToIntValue(DOGetter<int> getter, DOSetter<int> setter, int endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static Tweener ToLongValue(DOGetter<long> getter, DOSetter<long> setter, long endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<Quaternion, Vector3, DG.Tweening.Plugins.Options.QuaternionOptions> ToQuaternionValue(DOGetter<Quaternion> getter, DOSetter<Quaternion> setter, Vector3 endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<Rect, Rect, DG.Tweening.Plugins.Options.RectOptions> ToRectValue(DOGetter<Rect> getter, DOSetter<Rect> setter, Rect endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }
     
        public static Tweener ToRectOffsetValue(DOGetter<RectOffset> getter, DOSetter<RectOffset> setter, RectOffset endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<string, string, DG.Tweening.Plugins.Options.StringOptions> ToStringValue(DOGetter<string> getter, DOSetter<string> setter, string endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static Tweener ToUintValue(DOGetter<uint> getter, DOSetter<uint> setter, uint endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static Tweener ToUlongValue(DOGetter<ulong> getter, DOSetter<ulong> setter, ulong endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<Vector2, Vector2, DG.Tweening.Plugins.Options.VectorOptions> ToVector2Value(DOGetter<Vector2> getter, DOSetter<Vector2> setter, Vector2 endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }
       
        public static TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions> ToVector3Value(DOGetter<Vector3> getter, DOSetter<Vector3> setter, Vector3 endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static TweenerCore<Vector4, Vector4, DG.Tweening.Plugins.Options.VectorOptions> ToVector4Value(DOGetter<Vector4> getter, DOSetter<Vector4> setter, Vector4 endValue, float duration)
        {
            return DG.Tweening.DOTween.To(getter, setter, endValue, duration);
        }

        public static Tweener ToFloatValue2(DOSetter<float> setter, float startValue, float endValue, float duration)
        {
            return DG.Tweening.DOTween.To(setter, startValue, endValue, duration);
        }

        public static Tweener ToAlpha(DOGetter<Color> getter, DOSetter<Color> setter, float endValue, float duration)
        {
            return DG.Tweening.DOTween.ToAlpha(getter, setter, endValue, duration);
        }

        public static TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> ToArray(DOGetter<Vector3> getter, DOSetter<Vector3> setter, Vector3[] endValues, float[] durations)
        {
            return DG.Tweening.DOTween.ToArray(getter, setter, endValues, durations);
        }

        public static TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions> ToAxis(DOGetter<Vector3> getter, DOSetter<Vector3> setter, float endValue, float duration, AxisConstraint axisConstraint = AxisConstraint.X)
        {
            return DG.Tweening.DOTween.ToAxis(getter, setter, endValue, duration, axisConstraint);
        }

        public static Sequence NewSequence()
        {
            return DG.Tweening.DOTween.Sequence();
        }
    }
}
