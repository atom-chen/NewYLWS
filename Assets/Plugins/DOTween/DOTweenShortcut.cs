using DG.Tweening.Core;
using DG.Tweening.Plugins.Core.PathCore;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

namespace DOTween
{
    public class DOTweenShortcut
    {
        public static Tweener DOAspect(Camera target, float endValue, float duration)
        {
            return ShortcutExtensions.DOAspect(target, endValue, duration);
        }

        public static Tweener DOBlendableColor(Light target, Color endValue, float duration)
        {
            return ShortcutExtensions.DOBlendableColor(target, endValue, duration);
        }

        public static Tweener DOBlendableColor(Material target, Color endValue, float duration)
        {
            return ShortcutExtensions.DOBlendableColor(target, endValue, duration);
        }

        public static Tweener DOBlendableColor(Material target, Color endValue, string property, float duration)
        {
            return ShortcutExtensions.DOBlendableColor(target, endValue, property, duration);
        }

        public static Tweener DOBlendableLocalMoveBy(Transform target, Vector3 byValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOBlendableLocalMoveBy(target, byValue, duration, snapping);
        }

        public static Tweener DOBlendableLocalRotateBy(Transform target, Vector3 byValue, float duration, RotateMode mode = RotateMode.Fast)
        {
            return ShortcutExtensions.DOBlendableLocalRotateBy(target, byValue, duration, mode);
        }

        public static Tweener DOBlendableMoveBy(Transform target, Vector3 byValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOBlendableMoveBy(target, byValue, duration, snapping);
        }

        public static Tweener DOBlendableRotateBy(Transform target, Vector3 byValue, float duration, RotateMode mode = RotateMode.Fast)
        {
            return ShortcutExtensions.DOBlendableRotateBy(target, byValue, duration, mode);
        }

        public static Tweener DOBlendableScaleBy(Transform target, Vector3 byValue, float duration)
        {
            return ShortcutExtensions.DOBlendableScaleBy(target, byValue, duration);
        }

        public static Tweener DOColor(Camera target, Color endValue, float duration)
        {
            return ShortcutExtensions.DOColor(target, endValue, duration);
        }

        public static Tweener DOColor(Light target, Color endValue, float duration)
        {
            return ShortcutExtensions.DOColor(target, endValue, duration);
        }

        public static Tweener DOColor(Material target, Color endValue, float duration)
        {
            return ShortcutExtensions.DOColor(target, endValue, duration);
        }

        public static Tweener DOColor(LineRenderer target, Color2 startValue, Color2 endValue, float duration)
        {
            return ShortcutExtensions.DOColor(target, startValue, endValue, duration);
        }

        public static Tweener DOColor(Material target, Color endValue, string property, float duration)
        {
            return ShortcutExtensions.DOColor(target, endValue, property, duration);
        }

        public static Tweener DOTextColor(Text target, Color endValue, float duration)
        {
            return target.DOColor(endValue, duration);
        }

        public static Tweener DoImgColor(Image image, Color endValue, float duration)
        {
            return image.DOColor(endValue, duration);
        }

        public static int DOComplete(Component target, bool withCallbacks = false)
        {
            return ShortcutExtensions.DOComplete(target, withCallbacks);
        }

        public static int DOComplete(Material target, bool withCallbacks = false)
        {
            return ShortcutExtensions.DOComplete(target, withCallbacks);
        }

        public static Tweener DOFade(AudioSource target, float endValue, float duration)
        {
            return ShortcutExtensions.DOFade(target, endValue, duration);
        }

        public static Tweener DOFade(Material target, float endValue, float duration)
        {
            return target.DOFade(endValue, duration);
        }

        public static Tweener DOFade(Material target, float endValue, string property, float duration)
        {
            return target.DOFade(endValue, property, duration);
        }

        public static Tweener DOFarClipPlane(Camera target, float endValue, float duration)
        {
            return ShortcutExtensions.DOFarClipPlane(target, endValue, duration);
        }

        public static Tweener DOFieldOfView(Camera target, float endValue, float duration)
        {
            return ShortcutExtensions.DOFieldOfView(target, endValue, duration);
        }

        public static int DOFlip(Component target)
        {
            return ShortcutExtensions.DOFlip(target);
        }

        public static int DOFlip(Material target)
        {
            return ShortcutExtensions.DOFlip(target);
        }

        public static Tweener DOFloat(Material target, float endValue, string property, float duration)
        {
            return ShortcutExtensions.DOFloat(target, endValue, property, duration);
        }

        public static int DOGoto(Component target, float to, bool andPlay = false)
        {
            return ShortcutExtensions.DOGoto(target, to, andPlay);
        }

        public static int DOGoto(Material target, float to, bool andPlay = false)
        {
            return ShortcutExtensions.DOGoto(target, to, andPlay);
        }

        public static Tweener DOIntensity(Light target, float endValue, float duration)
        {
            return ShortcutExtensions.DOIntensity(target, endValue, duration);
        }

        public static Sequence DOJump(Rigidbody target, Vector3 endValue, float jumpPower, int numJumps, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOJump(target, endValue, jumpPower, numJumps, duration, snapping);
        }

        public static Sequence DOJump(Transform target, Vector3 endValue, float jumpPower, int numJumps, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOJump(target, endValue, jumpPower, numJumps, duration, snapping);
        }

        public static int DOKill(Component target, bool complete = false)
        {
            return ShortcutExtensions.DOKill(target, complete);
        }

        public static int DOKill(Material target, bool complete = false)
        {
            return ShortcutExtensions.DOKill(target, complete);
        }

        public static Sequence DOLocalJump(Transform target, Vector3 endValue, float jumpPower, int numJumps, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOLocalJump(target, endValue, jumpPower, numJumps, duration, snapping);
        }

        public static Tweener DOLocalMove(Transform target, Vector3 endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOLocalMove(target, endValue, duration, snapping);
        }

        public static Tweener DOLocalMoveX(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOLocalMoveX(target, endValue, duration, snapping);
        }

        public static Tweener DOLocalMoveY(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOLocalMoveY(target, endValue, duration, snapping);
        }

        public static Tweener DOLocalMoveZ(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOLocalMoveZ(target, endValue, duration, snapping);
        }

        public static TweenerCore<Vector3, Path, DG.Tweening.Plugins.Options.PathOptions> DOLocalPath(Rigidbody target, Vector3[] path, float duration, PathType pathType = PathType.Linear, PathMode pathMode = PathMode.Full3D, int resolution = 10, Color? gizmoColor = null)
        {
            return ShortcutExtensions.DOLocalPath(target, path, duration, pathType, pathMode, resolution, gizmoColor);
        }

        public static TweenerCore<Vector3, Path, DG.Tweening.Plugins.Options.PathOptions> DOLocalPath(Transform target, Vector3[] path, float duration, PathType pathType = PathType.Linear, PathMode pathMode = PathMode.Full3D, int resolution = 10, Color? gizmoColor = null)
        {
            return ShortcutExtensions.DOLocalPath(target, path, duration, pathType, pathMode, resolution, gizmoColor);
        }

        public static Tweener DOLocalRotate(Transform target, Vector3 endValue, float duration, RotateMode mode = RotateMode.Fast)
        {
            return ShortcutExtensions.DOLocalRotate(target, endValue, duration, mode);
        }

        public static Tweener DOLocalRotateQuaternion(Transform target, Quaternion endValue, float duration)
        {
            return ShortcutExtensions.DOLocalRotateQuaternion(target, endValue, duration);
        }

        public static Tweener DOLookAt(Rigidbody target, Vector3 towards, float duration, AxisConstraint axisConstraint = AxisConstraint.None, Vector3? up = null)
        {
            return ShortcutExtensions.DOLookAt(target, towards, duration, axisConstraint, up);
        }

        public static Tweener DOLookAt(Transform target, Vector3 towards, float duration, AxisConstraint axisConstraint = AxisConstraint.None, Vector3? up = null)
        {
            return ShortcutExtensions.DOLookAt(target, towards, duration, axisConstraint, up);
        }

        public static Tweener DOMove(Rigidbody target, Vector3 endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMove(target, endValue, duration, snapping);
        }

        public static Tweener DOMove(Transform target, Vector3 endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMove(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveX(Rigidbody target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveX(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveX(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveX(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveY(Rigidbody target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveY(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveY(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveY(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveZ(Rigidbody target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveZ(target, endValue, duration, snapping);
        }

        public static Tweener DOMoveZ(Transform target, float endValue, float duration, bool snapping = false)
        {
            return ShortcutExtensions.DOMoveZ(target, endValue, duration, snapping);
        }

        public static Tweener DONearClipPlane(Camera target, float endValue, float duration)
        {
            return ShortcutExtensions.DONearClipPlane(target, endValue, duration);
        }

        public static Tweener DOOffset(Material target, Vector2 endValue, float duration)
        {
            return ShortcutExtensions.DOOffset(target, endValue, duration);
        }

        public static Tweener DOOffset(Material target, Vector2 endValue, string property, float duration)
        {
            return ShortcutExtensions.DOOffset(target, endValue, property, duration);
        }

        public static Tweener DOOrthoSize(Camera target, float endValue, float duration)
        {
            return ShortcutExtensions.DOOrthoSize(target, endValue, duration);
        }

        public static TweenerCore<Vector3, Path, DG.Tweening.Plugins.Options.PathOptions> DOPath(Rigidbody target, Vector3[] path, float duration, PathType pathType = PathType.Linear, PathMode pathMode = PathMode.Full3D, int resolution = 10, Color? gizmoColor = null)
        {
            return ShortcutExtensions.DOPath(target, path, duration, pathType, pathMode, resolution, gizmoColor);
        }

        public static TweenerCore<Vector3, Path, DG.Tweening.Plugins.Options.PathOptions> DOPath(Transform target, Vector3[] path, float duration, PathType pathType = PathType.Linear, PathMode pathMode = PathMode.Full3D, int resolution = 10, Color? gizmoColor = null)
        {
            return ShortcutExtensions.DOPath(target, path, duration, pathType, pathMode, resolution, gizmoColor);
        }

        public static int DOPause(Component target)
        {
            return ShortcutExtensions.DOPause(target);
        }

        public static int DOPause(Material target)
        {
            return ShortcutExtensions.DOPause(target);
        }

        public static Tweener DOPitch(AudioSource target, float endValue, float duration)
        {
            return ShortcutExtensions.DOPitch(target, endValue, duration);
        }

        public static Tweener DOPixelRect(Camera target, Rect endValue, float duration)
        {
            return ShortcutExtensions.DOPixelRect(target, endValue, duration);
        }

        public static int DOPlay(Component target)
        {
            return ShortcutExtensions.DOPlay(target);
        }

        public static int DOPlay(Material target)
        {
            return ShortcutExtensions.DOPlay(target);
        }

        public static int DOPlayBackwards(Component target)
        {
            return ShortcutExtensions.DOPlayBackwards(target);
        }

        public static int DOPlayBackwards(Material target)
        {
            return ShortcutExtensions.DOPlayBackwards(target);
        }

        public static int DOPlayForward(Component target)
        {
            return ShortcutExtensions.DOPlayForward(target);
        }

        public static int DOPlayForward(Material target)
        {
            return ShortcutExtensions.DOPlayForward(target);
        }

        public static Tweener DOPunchPosition(Transform target, Vector3 punch, float duration, int vibrato = 10, float elasticity = 1f, bool snapping = false)
        {
            return ShortcutExtensions.DOPunchPosition(target, punch, duration, vibrato, elasticity, snapping);
        }

        public static Tweener DOPunchRotation(Transform target, Vector3 punch, float duration, int vibrato = 10, float elasticity = 1f)
        {
            return ShortcutExtensions.DOPunchRotation(target, punch, duration, vibrato, elasticity);
        }

        public static Tweener DOPunchScale(Transform target, Vector3 punch, float duration, int vibrato = 10, float elasticity = 1f)
        {
            return ShortcutExtensions.DOPunchScale(target, punch, duration, vibrato, elasticity);
        }

        public static Tweener DORect(Camera target, Rect endValue, float duration)
        {
            return ShortcutExtensions.DORect(target, endValue, duration);
        }

        public static Tweener DOResize(TrailRenderer target, float toStartWidth, float toEndWidth, float duration)
        {
            return ShortcutExtensions.DOResize(target, toStartWidth, toEndWidth, duration);
        }

        public static int DORestart(Component target, bool includeDelay = true)
        {
            return ShortcutExtensions.DORestart(target, includeDelay);
        }

        public static int DORestart(Material target, bool includeDelay = true)
        {
            return ShortcutExtensions.DORestart(target, includeDelay);
        }

        public static int DORewind(Component target, bool includeDelay = true)
        {
            return ShortcutExtensions.DORewind(target, includeDelay);
        }

        public static int DORewind(Material target, bool includeDelay = true)
        {
            return ShortcutExtensions.DORewind(target, includeDelay);
        }

        public static Tweener DORotate(Rigidbody target, Vector3 endValue, float duration, RotateMode mode = RotateMode.Fast)
        {
            return ShortcutExtensions.DORotate(target, endValue, duration, mode);
        }

        public static Tweener DORotate(Transform target, Vector3 endValue, float duration, RotateMode mode = RotateMode.Fast)
        {
            return ShortcutExtensions.DORotate(target, endValue, duration, mode);
        }

        public static Tweener DORotateQuaternion(Transform target, Quaternion endValue, float duration)
        {
            return ShortcutExtensions.DORotateQuaternion(target, endValue, duration);
        }

        public static Tweener DOScale(Transform target, float endValue, float duration)
        {
            return ShortcutExtensions.DOScale(target, endValue, duration);
        }

        public static Tweener DOScale(Transform target, Vector3 endValue, float duration)
        {
            return ShortcutExtensions.DOScale(target, endValue, duration);
        }

        public static Tweener DOScaleX(Transform target, float endValue, float duration)
        {
            return ShortcutExtensions.DOScaleX(target, endValue, duration);
        }

        public static Tweener DOScaleY(Transform target, float endValue, float duration)
        {
            return ShortcutExtensions.DOScaleY(target, endValue, duration);
        }

        public static Tweener DOScaleZ(Transform target, float endValue, float duration)
        {
            return ShortcutExtensions.DOScaleZ(target, endValue, duration);
        }

        public static Tweener DOShadowStrength(Light target, float endValue, float duration)
        {
            return ShortcutExtensions.DOShadowStrength(target, endValue, duration);
        }

        public static Tweener DOShakePosition(Camera target, float duration, float strength = 3f, int vibrato = 10, float randomness = 90f, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakePosition(target, duration, strength, vibrato, randomness, fadeOut);
        }

        public static Tweener DOShakePosition(Transform target, float duration, float strength = 1f, int vibrato = 10, float randomness = 90f, bool snapping = false, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakePosition(target, duration, strength, vibrato, randomness, snapping, fadeOut);
        }

        public static Tweener DOShakePosition(Transform target, float duration, Vector3 strength, int vibrato = 10, float randomness = 90, bool snapping = false, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakePosition(target, duration, strength, vibrato, randomness, snapping, fadeOut);
        }

        public static Tweener DOShakePosition(Camera target, float duration, Vector3 strength, int vibrato = 10, float randomness = 90, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakePosition(target, duration, strength, vibrato, randomness, fadeOut);
        }

        public static Tweener DOShakeRotation(Camera target, float duration, float strength = 90f, int vibrato = 10, float randomness = 90f, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakeRotation(target, duration, strength, vibrato, randomness, fadeOut);
        }

        public static Tweener DOShakeRotation(Transform target, float duration, float strength = 90f, int vibrato = 10, float randomness = 90f, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakeRotation(target, duration, strength, vibrato, randomness, fadeOut);
        }

        public static Tweener DOShakeScale(Transform target, float duration, float strength = 1f, int vibrato = 10, float randomness = 90f, bool fadeOut = true)
        {
            return ShortcutExtensions.DOShakeScale(target, duration, strength, vibrato, randomness, fadeOut);
        }

        public static int DOSmoothRewind(Component target)
        {
            return ShortcutExtensions.DOSmoothRewind(target);
        }

        public static int DOSmoothRewind(Material target)
        {
            return ShortcutExtensions.DOSmoothRewind(target);
        }

        public static Tweener DOTiling(Material target, Vector2 endValue, float duration)
        {
            return ShortcutExtensions.DOTiling(target, endValue, duration);
        }

        public static Tweener DOTiling(Material target, Vector2 endValue, string property, float duration)
        {
            return ShortcutExtensions.DOTiling(target, endValue, property, duration);
        }

        public static Tweener DOTime(TrailRenderer target, float endValue, float duration)
        {
            return ShortcutExtensions.DOTime(target, endValue, duration);
        }

        public static Tweener DOTimeScale(Tween target, float endValue, float duration)
        {
            return ShortcutExtensions.DOTimeScale(target, endValue, duration);
        }

        public static int DOTogglePause(Component target)
        {
            return ShortcutExtensions.DOTogglePause(target);
        }

        public static int DOTogglePause(Material target)
        {
            return ShortcutExtensions.DOTogglePause(target);
        }

        public static Tweener DOVector(Material target, Vector4 endValue, string property, float duration)
        {
            return ShortcutExtensions.DOVector(target, endValue, property, duration);
        }

        public static Tweener DOFillAmount(Image target, float endValue, float duration)
        {
            return target.DOFillAmount(endValue, duration);
        }
    }
}
