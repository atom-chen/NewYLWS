using DG.Tweening;
using UnityEngine;

namespace DOTween
{
    public class DOTweenExtensions
    {
        public static void Complete(Tween t)
        {
            TweenExtensions.Complete(t);
        }

        public static void Complete(Tween t, bool withCallbacks)
        {
            TweenExtensions.Complete(t, withCallbacks);
        }

        public static int CompletedLoops(Tween t)
        {
            return TweenExtensions.CompletedLoops(t);
        }

        public static float Delay(Tween t)
        {
            return TweenExtensions.Delay(t);
        }

        public static float Duration(Tween t, bool includeLoops = true)
        {
            return TweenExtensions.Duration(t, includeLoops);
        }

        public static float Elapsed(Tween t, bool includeLoops = true)
        {
            return TweenExtensions.Elapsed(t, includeLoops);
        }

        public static float ElapsedDirectionalPercentage(Tween t)
        {
            return TweenExtensions.ElapsedDirectionalPercentage(t);
        }

        public static float ElapsedPercentage(Tween t, bool includeLoops = true)
        {
            return TweenExtensions.ElapsedPercentage(t, includeLoops);
        }

        public static void Flip(Tween t)
        {
            TweenExtensions.Flip(t);
        }

        public static void ForceInit(Tween t)
        {
            TweenExtensions.ForceInit(t);
        }

        public static void Goto(Tween t, float to, bool andPlay = false)
        {
            TweenExtensions.Goto(t, to, andPlay);
        }

        public static void GotoWaypoint(Tween t, int waypointIndex, bool andPlay = false)
        {
            TweenExtensions.GotoWaypoint(t, waypointIndex, andPlay);
        }

        public static bool IsActive(Tween t)
        {
            return TweenExtensions.IsActive(t);
        }
  
        public static bool IsBackwards(Tween t)
        {
            return TweenExtensions.IsBackwards(t);
        }
 
        public static bool IsComplete(Tween t)
        {
            return TweenExtensions.IsComplete(t);
        }

        public static bool IsInitialized(Tween t)
        {
            return TweenExtensions.IsInitialized(t);
        }

        public static bool IsPlaying(Tween t)
        {
            return TweenExtensions.IsPlaying(t);
        }

        public static void Kill(Tween t, bool complete = false)
        {
            TweenExtensions.Kill(t, complete);
        }

        public static int Loops(Tween t)
        {
            return TweenExtensions.Loops(t);
        }

        public static Vector3[] PathGetDrawPoints(Tween t, int subdivisionsXSegment = 10)
        {
            return TweenExtensions.PathGetDrawPoints(t, subdivisionsXSegment);
        }

        public static Vector3 PathGetPoint(Tween t, float pathPercentage)
        {
            return TweenExtensions.PathGetPoint(t, pathPercentage);
        }

        public static float PathLength(Tween t)
        {
            return TweenExtensions.PathLength(t);
        }
        
        public static Tween Pause(Tween t)
        {
            return TweenExtensions.Pause(t);
        }

        public static Tween Play(Tween t)
        {
            return TweenExtensions.Play(t);
        }

        public static void PlayBackwards(Tween t)
        {
            TweenExtensions.PlayBackwards(t);
        }

        public static void PlayForward(Tween t)
        {
            TweenExtensions.PlayForward(t);
        }

        public static void Restart(Tween t, bool includeDelay = true, float changeDelayTo = -1F)
        {
            TweenExtensions.Restart(t, includeDelay, changeDelayTo);
        }

        public static void Rewind(Tween t, bool includeDelay = true)
        {
            TweenExtensions.Rewind(t, includeDelay);
        }

        public static void SmoothRewind(Tween t)
        {
            TweenExtensions.SmoothRewind(t);
        }

        public static void TogglePause(Tween t)
        {
            TweenExtensions.TogglePause(t);
        }

        public static YieldInstruction WaitForCompletion(Tween t)
        {
            return TweenExtensions.WaitForCompletion(t);
        }

        public static YieldInstruction WaitForElapsedLoops(Tween t, int elapsedLoops)
        {
            return TweenExtensions.WaitForElapsedLoops(t, elapsedLoops);
        }

        public static YieldInstruction WaitForKill(Tween t)
        {
            return TweenExtensions.WaitForKill(t);
        }

        public static YieldInstruction WaitForPosition(Tween t, float position)
        {
            return TweenExtensions.WaitForPosition(t, position);
        }

        public static YieldInstruction WaitForRewind(Tween t)
        {
            return TweenExtensions.WaitForRewind(t);
        }

        public static Coroutine WaitForStart(Tween t)
        {
            return TweenExtensions.WaitForStart(t);
        }
    }
}
