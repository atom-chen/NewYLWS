using UnityEngine;
using XLua;
using UnityEngine.Playables;
using Cinemachine;
using Cinemachine.Timeline;
using UnityEngine.Timeline;
using System.Collections.Generic;

[Hotfix]
[LuaCallCSharp]
public class Timeline : MonoBehaviour
{
    public delegate void OnDialogClipStart(int index, double startTime);
    public delegate void OnPauseClipStart(int waitWhatEvent, string sParam1, int iParam1, float fParam1);
    public delegate void OnSkipClipStart(double time);
    public delegate void OnCommandClipStart(int index, double startTime);
    public delegate void OnDirectorInited(DialogClipData[] dialogClipDatas, CommandClipData[] commandClipDatas);

    private PlayableDirector m_playableDirector;
    private OnDialogClipStart m_onDialogClipStart = null;
    private OnPauseClipStart m_onPauseClipStart = null;
    private OnSkipClipStart m_onSkipClipStart = null;
    private OnCommandClipStart m_onCommandClipStart = null;
    private DialogClipData[] m_dialogClipDataList = null;
    private List<CommandClipData> m_commandClipDataList = new List<CommandClipData>();

    public void Init(PlayableDirector playableDirector)
    {
        m_playableDirector = playableDirector;
    }

    public void Play(OnDirectorInited onDirectorInited, OnDialogClipStart onDialogClipStart, OnPauseClipStart onPauseClipStart, OnSkipClipStart onSkipClipStart, OnCommandClipStart onCommandClipStart)
    {
        m_onDialogClipStart = onDialogClipStart;
        m_onPauseClipStart = onPauseClipStart;
        m_onSkipClipStart = onSkipClipStart;
        m_onCommandClipStart = onCommandClipStart;

        if (m_playableDirector != null)
        {
            m_playableDirector.Play();
        }
        if (onDirectorInited != null)
        {
            onDirectorInited(m_dialogClipDataList, m_commandClipDataList.ToArray());
        }
    }

    public void Pause()
    {
        if (m_playableDirector != null)
        {
            m_playableDirector.Pause();
        }
    }

    public void Resume()
    {
        if (m_playableDirector != null)
        {
            m_playableDirector.Resume();
        }
    }

    public void DialogClipStart(int index, double startTime)
    {
        if (m_onDialogClipStart != null)
        {
            m_onDialogClipStart(index, startTime);
        }
    }

    public void PauseClipStart(int waitWhatEvent, string sParam1, int iParam1, float fParam1)
    {
        if (m_onPauseClipStart != null)
        {
            m_onPauseClipStart(waitWhatEvent, sParam1, iParam1, fParam1);
        }
    }

    public void SkipClipStart(double timeSkipTo)
    {
        if (m_onSkipClipStart != null)
        {
            m_onSkipClipStart(timeSkipTo);
        }
    }

    public void CommandClipStart(int index, double startTime)
    {
        if (m_onCommandClipStart != null)
        {
            m_onCommandClipStart(index, startTime);
        }
    }

    public void DialogTrackInited(List<DialogClipData> dataList)
    {
        m_dialogClipDataList = dataList.ToArray();
    }

    public void CommandTrackInited(List<CommandClipData> dataList)
    {
        m_commandClipDataList.AddRange(dataList);
        m_commandClipDataList.Sort(SortCommandData);
    }

    private int SortCommandData(CommandClipData a, CommandClipData b)
    {
        if (a == null) return 1;
        if (b == null) return -1;
        if (a.startTime > b.startTime)
        {
            return 1;
        }
        else if (a.startTime < b.startTime)
        {
            return -1;
        }

        if (a.commandID > b.commandID)
        {
            return -1;
        }
        else if (a.commandID < b.commandID)
        {
            return 1;
        }


        return a.iParam1 - b.iParam1;
    }

    public void InitCameraTrack(Object trackObject)
    {
        if (trackObject == null)
        {
            return;
        }
        CinemachineTrack track = trackObject as CinemachineTrack;
        if (track == null)
        {
            return;
        }
        foreach (var clip in track.GetClips())
        {
            InitCinemachineClip(clip);
        }
    }

    public void InitCinemachineClip(TimelineClip clip)
    {
        if (clip == null)
        {
            return;
        }
        Transform vcamTrans = null;
        if (clip.displayName.Equals("CM vcam1"))
        {
            GameObject vcamGO = GameObject.Find("CM vcam1");
            if (vcamGO)
            {
                vcamTrans = vcamGO.transform;
            }
        }
        else
        {
            vcamTrans = m_playableDirector.transform.Find(clip.displayName);
        }
        if (vcamTrans == null)
        {
            return;
        }
        var cameraInfo = clip.asset as CinemachineShot;
        var vcam1 = vcamTrans.GetComponent<CinemachineVirtualCameraBase>();
        if (vcam1 != null)
        {
            var setCam = new ExposedReference<CinemachineVirtualCameraBase>();
            setCam.defaultValue = vcam1;
            cameraInfo.VirtualCamera = setCam;
        }
    }

    public void InitEffectTrack(Object trackObject, string key, GameObject parent, GameObject prefab)
    {
        if (trackObject == null)
        {
            return;
        }
        ControlTrack track = trackObject as ControlTrack;
        if (track == null)
        {
            return;
        }
        foreach (var clip in track.GetClips())
        {
            if (clip.displayName == key)
            {
                ControlPlayableAsset controlAsset = clip.asset as ControlPlayableAsset;
                var parentER = new ExposedReference<GameObject>();
                parentER.defaultValue = parent;
                controlAsset.sourceGameObject = parentER;
                controlAsset.prefabGameObject = prefab;
                break;
            }
        }
    }

    public bool IsTimelineEnd()
    {
        if (m_playableDirector == null)
        {
            return true;
        }

        return m_playableDirector.time >= m_playableDirector.duration;
    }

    public Object SetTimelineBinding(string key, Object value)
    {
        if (m_playableDirector == null)
        {
            return null;
        }
        foreach (var at in m_playableDirector.playableAsset.outputs)
        {
            if (at.streamName == key)
            {
                m_playableDirector.SetGenericBinding(at.sourceObject, value);
                return at.sourceObject;
            }
        }
        return null;
    }

    public Object GetTimelineTrack(string key)
    {
        if (m_playableDirector == null)
        {
            return null;
        }
        foreach (var at in m_playableDirector.playableAsset.outputs)
        {
            if (at.streamName == key)
            {
                return at.sourceObject;
            }
        }
        return null;
    }

    public void SkipTo(double time, bool skipToEnd)
    {
        if (m_playableDirector == null)
        {
            return;
        }
        if (skipToEnd && time > m_playableDirector.duration)
        {
            time = m_playableDirector.duration - 0.01;
        }
        m_playableDirector.time = time;
    }

    private void OnDestroy()
    {
        m_playableDirector = null;
        m_onDialogClipStart = null;
        m_onPauseClipStart = null;
        m_onSkipClipStart = null;
        m_dialogClipDataList = null;
        m_commandClipDataList = null;
    }

    public double GetCurTime()
    {
        if (m_playableDirector == null)
        {
            return 0;
        }
        return m_playableDirector.time;
    }
}
