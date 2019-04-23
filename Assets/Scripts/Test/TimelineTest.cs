using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineTest : MonoBehaviour 
{
    public Transform[] leftWujiangList = new Transform[5];
    public Transform[] rightWujiangList = new Transform[5];
    public PlayableDirector playableDirector = null;

    private float[] leftTargetPosX = new float[5];
    private float[] rightTargetPosX = new float[5];
    private float moveDistance = 30;
    private float moveSpeed = 6;
    private float updateInterval = 0.033f;
    private float waitUpdateSingleTime = 0;
    private float waitUpdateSingleTime1 = 0;
    private float delayTime = 2f;
    private float delayTime1 = 2f;

    void Awake()
    {
        Application.targetFrameRate = 60;
    }

	void Start () 
    {
        for (int i = 0; i < 5; i++)
        {
            leftTargetPosX[i] = leftWujiangList[i].transform.localPosition.x + moveDistance;
            leftWujiangList[i].GetComponent<Animator>().Play("walk");
            rightTargetPosX[i] = rightWujiangList[i].transform.localPosition.x - moveDistance;
            rightWujiangList[i].GetComponent<Animator>().Play("walk");
        }
	}
	
	void Update () 
    {
        //delayTime -= Time.deltaTime;
        //if (delayTime > 0)
        //{
        //    return;
        //}

        waitUpdateSingleTime += Time.deltaTime;
        if (waitUpdateSingleTime >= updateInterval)
        {
            UpdateWujiangMove(updateInterval);
            //ManualUpdate(updateInterval);

            waitUpdateSingleTime -= updateInterval;
        }
	}

    //void LateUpdate()
    //{
    //    delayTime1 -= Time.deltaTime;
    //    if (delayTime1 > 0)
    //    {
    //        return;
    //    }

    //    waitUpdateSingleTime1 += Time.deltaTime;
    //    if (waitUpdateSingleTime1 >= updateInterval)
    //    {
    //        ManualUpdate(updateInterval);

    //        waitUpdateSingleTime1 -= updateInterval;
    //    }
    //}

    // 武将30帧，timeline60帧， 依旧卡顿，结论：只要帧率不一样就会导致画面卡
    //void LateUpdate()
    //{
    //    delayTime1 -=Time.deltaTime;
    //    if (delayTime1 > 0)
    //    {
    //        return;
    //    }

    //    ManualUpdate(Time.deltaTime);
    //}

    void UpdateWujiangMove(float deltaTime)
    {
        for (int i = 0; i < 5; i++)
        {
            Vector3 leftPos = leftWujiangList[i].transform.localPosition;
            if (leftPos.x < leftTargetPosX[i])
            {
                leftPos.x += deltaTime * moveSpeed;
                leftWujiangList[i].transform.localPosition = leftPos;
            }

            Vector3 rightPos = rightWujiangList[i].transform.localPosition;
            if (rightPos.x > rightTargetPosX[i])
            {
                rightPos.x -= deltaTime * moveSpeed;
                rightWujiangList[i].transform.localPosition = rightPos;
            }
        }
    }

    public void ManualUpdate(float deltaTime)
    {
        if (playableDirector == null)
        {
            return;
        }
        playableDirector.time += deltaTime;
        if (playableDirector.time >= playableDirector.duration)
        {
            playableDirector.time = playableDirector.duration;
        }
        playableDirector.Evaluate();
    }
}
