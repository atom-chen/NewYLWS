using UnityEngine;
using UnityEngine.Playables;

public sealed class CustomAnimMixer : PlayableBehaviour
{
    private Animator m_anim;
    private int mBrainOverrideId = -1;
    private bool mPlaying;

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        base.ProcessFrame(playable, info, playerData);

        if (playable.GetPlayState() != PlayState.Playing)
        {
            Debug.LogError("not Playing");
            return;
        }
        GameObject go = playerData as GameObject;
        if (go == null)
        {
            m_anim = (Animator)playerData;
        }
        else
        {
            m_anim = go.GetComponent<Animator>();
        }
        if (m_anim == null)
        {
            Debug.LogError("Track bindings is null, Please check lua config");
            return;
        }

        for (int i = 0; i < playable.GetInputCount(); ++i)
        {
            CustomAnimShotPlayable shot = ((ScriptPlayable<CustomAnimShotPlayable>)playable.GetInput(i)).GetBehaviour();
            if (shot != null)
            {
                float weight = playable.GetInputWeight(i);
                if (weight > 0.0001f && !shot.clipExecuted)
                {
                    shot.clipExecuted = true;
                    GameUtility.ForceCrossFade(m_anim, shot.animName, 0.2f);
                    //Debug.LogError("Clip start");
                }
                else if (weight <= 0.0001f && shot.clipExecuted)
                {
                    shot.clipExecuted = false;
                    if (m_anim.GetCurrentAnimatorStateInfo(0).IsName("Base Layer." + shot.animName))
                    {
                        GameUtility.ForceCrossFade(m_anim, "idle", 0.2f);
                    }
                    //Debug.LogError("Clip end");
                }
            }
        }
    }
}