using DG.Tweening.Core;
using System;
using System.Runtime.CompilerServices;
using UnityEngine;
using DG.Tweening;

namespace DOTween
{
    public class DOTweenSettings
    {
        public static Sequence Append(Sequence s, Tween t)
        {
            return TweenSettingsExtensions.Append(s, t);
        }

        public static Sequence AppendCallback(Sequence s, TweenCallback callback)
        {
            return TweenSettingsExtensions.AppendCallback(s, callback);
        }

        public static Sequence AppendInterval(Sequence s, float interval)
        {
            return TweenSettingsExtensions.AppendInterval(s, interval);
        }

        public static Sequence Insert(Sequence s, float atPosition, Tween t)
        {
            return TweenSettingsExtensions.Insert(s, atPosition, t);
        }

        public static Sequence InsertCallback(Sequence s, float atPosition, TweenCallback callback)
        {
            return TweenSettingsExtensions.InsertCallback(s, atPosition, callback);
        }

        public static Sequence Join(Sequence s, Tween t)
        {
            return TweenSettingsExtensions.Join(s, t);
        }

        public static Tween OnComplete(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnComplete<Tween>(t, action);
        }

        public static Tween OnKill(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnKill<Tween>(t, action);
        }

        public static Tween OnPause(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnPause<Tween>(t, action);
        }

        public static Tween OnPlay(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnPlay<Tween>(t, action);
        }

        public static Tween OnRewind(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnRewind<Tween>(t, action);
        }

        public static Tween OnStart(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnStart<Tween>(t, action);
        }

        public static Tween OnStepComplete(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnStepComplete<Tween>(t, action);
        }

        public static Tween OnUpdate(Tween t, TweenCallback action)
        {
            return TweenSettingsExtensions.OnUpdate<Tween>(t, action);
        }

        public static Tween OnWaypointChange(Tween t, TweenCallback<int> action)
        {
            return TweenSettingsExtensions.OnWaypointChange<Tween>(t, action);
        }

        public static Sequence Prepend(Sequence s, Tween t)
        {
            return TweenSettingsExtensions.Prepend(s, t);
        }

        public static Sequence PrependCallback(Sequence s, TweenCallback callback)
        {
            return TweenSettingsExtensions.PrependCallback(s, callback);
        }

        public static Sequence PrependInterval(Sequence s, float interval)
        {
            return TweenSettingsExtensions.PrependInterval(s, interval);
        }

        public static Tween SetAs(Tween t, Tween asTween)
        {
            return TweenSettingsExtensions.SetAs<Tween>(t, asTween);
        }

        public static Tween SetAs(Tween t, TweenParams tweenParams)
        {
            return TweenSettingsExtensions.SetAs<Tween>(t, tweenParams);
        }

        public static Tween SetAutoKill(Tween t)
        {
            return TweenSettingsExtensions.SetAutoKill<Tween>(t);
        }

        public static Tween SetAutoKill(Tween t, bool autoKillOnCompletion)
        {
            return TweenSettingsExtensions.SetAutoKill<Tween>(t, autoKillOnCompletion);
        }

        public static Tween SetDelay(Tween t, float delay)
        {
            return TweenSettingsExtensions.SetDelay<Tween>(t, delay);
        }

        public static Tween SetEase(Tween t, AnimationCurve animCurve)
        {
            return TweenSettingsExtensions.SetEase<Tween>(t, animCurve);
        }

        public static Tween SetEase(Tween t, int ease)
        {
            return TweenSettingsExtensions.SetEase<Tween>(t, (Ease)ease);
        }

        public static Tween SetEase(Tween t, EaseFunction customEase)
        { 
            return TweenSettingsExtensions.SetEase<Tween>(t, customEase);
        }

        public static Tween SetEase(Tween t, int ease, float overshoot)
        {
            return TweenSettingsExtensions.SetEase<Tween>(t, (Ease)ease, overshoot);
        }

        public static Tween SetEase(Tween t, int ease, float amplitude, float period)
        {
            return TweenSettingsExtensions.SetEase<Tween>(t, (Ease)ease, amplitude, period);
        }

        public static Tween SetId(Tween t, object id)
        {
            return TweenSettingsExtensions.SetId<Tween>(t, id);
        }

        public static TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> SetLookAt(TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> t, float lookAhead, Vector3? forwardDirection = null, Vector3? up = null)
        {
            return TweenSettingsExtensions.SetLookAt(t, lookAhead, forwardDirection, up);
        }

        public static TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> SetLookAt(TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> t, Transform lookAtTransform, Vector3? forwardDirection = null, Vector3? up = null)
        {
            return TweenSettingsExtensions.SetLookAt(t, lookAtTransform, forwardDirection, up);
        }

        public static TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> SetLookAt(TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> t, Vector3 lookAtPosition, Vector3? forwardDirection = null, Vector3? up = null)
        {
            return TweenSettingsExtensions.SetLookAt(t, lookAtPosition, forwardDirection, up);
        }

        public static Tween SetLoops(Tween t, int loops)
        {
            return TweenSettingsExtensions.SetLoops<Tween>(t, loops);
        }

        public static Tween SetLoops(Tween t, int loops, int loopType)
        {
            return TweenSettingsExtensions.SetLoops<Tween>(t, loops, (LoopType)loopType);
        }

        public static Tweener SetOptions(TweenerCore<Color, Color, DG.Tweening.Plugins.Options.ColorOptions> t, bool alphaOnly)
        {
            return TweenSettingsExtensions.SetOptions(t, alphaOnly);
        }

        public static Tweener SetOptions(TweenerCore<float, float, DG.Tweening.Plugins.Options.FloatOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Quaternion, Vector3, DG.Tweening.Plugins.Options.QuaternionOptions> t, bool useShortest360Route = true)
        {
            return TweenSettingsExtensions.SetOptions(t, useShortest360Route);
        }

        public static Tweener SetOptions(TweenerCore<Rect, Rect, DG.Tweening.Plugins.Options.RectOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector2, Vector2, DG.Tweening.Plugins.Options.VectorOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector4, Vector4, DG.Tweening.Plugins.Options.VectorOptions> t, bool snapping)
        {
            return TweenSettingsExtensions.SetOptions(t, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector2, Vector2, DG.Tweening.Plugins.Options.VectorOptions> t, AxisConstraint axisConstraint, bool snapping = false)
        {
            return TweenSettingsExtensions.SetOptions(t, axisConstraint, snapping);
        }

        public static TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> SetOptions(TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> t, AxisConstraint lockPosition, AxisConstraint lockRotation = AxisConstraint.None)
        {
            return TweenSettingsExtensions.SetOptions(t, lockPosition, lockRotation);
        }

        public static Tweener SetOptions(TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions> t, AxisConstraint axisConstraint, bool snapping = false)
        {
            return TweenSettingsExtensions.SetOptions(t, axisConstraint, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions> t, AxisConstraint axisConstraint, bool snapping = false)
        {
            return TweenSettingsExtensions.SetOptions(t, axisConstraint, snapping);
        }

        public static Tweener SetOptions(TweenerCore<Vector4, Vector4, DG.Tweening.Plugins.Options.VectorOptions> t, AxisConstraint axisConstraint, bool snapping = false)
        {
            return TweenSettingsExtensions.SetOptions(t, axisConstraint, snapping);
        }

        public static Tweener SetOptions(TweenerCore<string, string, DG.Tweening.Plugins.Options.StringOptions> t, bool richTextEnabled, ScrambleMode scrambleMode = ScrambleMode.None, string scrambleChars = null)
        {
            return TweenSettingsExtensions.SetOptions(t, richTextEnabled, scrambleMode, scrambleChars);
        }

        public static TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> SetOptions(TweenerCore<Vector3, DG.Tweening.Plugins.Core.PathCore.Path, DG.Tweening.Plugins.Options.PathOptions> t, bool closePath, AxisConstraint lockPosition = AxisConstraint.None, AxisConstraint lockRotation = AxisConstraint.None)
        {
            return TweenSettingsExtensions.SetOptions(t, closePath, lockPosition, lockRotation);
        }

        public static Tween SetRecyclable(Tween t)
        {
            return TweenSettingsExtensions.SetRecyclable<Tween>(t);
        }

        public static Tween SetRecyclable(Tween t, bool recyclable)
        {
            return TweenSettingsExtensions.SetRecyclable<Tween>(t, recyclable);
        }

        public static Tween SetRelative(Tween t)
        {
            return TweenSettingsExtensions.SetRelative<Tween>(t);
        }

        public static Tween SetRelative(Tween t, bool isRelative)
        {
            return TweenSettingsExtensions.SetRelative<Tween>(t, isRelative);
        }

        public static Tween SetSpeedBased(Tween t)
        {
            return TweenSettingsExtensions.SetSpeedBased<Tween>(t);
        }

        public static Tween SetSpeedBased(Tween t, bool isSpeedBased)
        {
            return TweenSettingsExtensions.SetSpeedBased<Tween>(t, isSpeedBased);
        }

        public static Tween SetTarget(Tween t, object target)
        {
            return TweenSettingsExtensions.SetTarget<Tween>(t, target);
        }

        public static Tween SetUpdate(Tween t, bool isIndependentUpdate)
        {
            return TweenSettingsExtensions.SetUpdate<Tween>(t, isIndependentUpdate);
        }

        public static Tween SetUpdate(Tween t, UpdateType updateType)
        {
            return TweenSettingsExtensions.SetUpdate<Tween>(t, updateType);
        }

        public static Tween SetUpdate(Tween t, UpdateType updateType, bool isIndependentUpdate)
        {
            return TweenSettingsExtensions.SetUpdate<Tween>(t, updateType, isIndependentUpdate);
        }
    }
}
