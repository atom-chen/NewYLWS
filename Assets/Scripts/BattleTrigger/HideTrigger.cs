using UnityEngine;

public class HideTrigger : MonoBehaviour
{
    public GameObject[] hideTargetList;

    void OnTriggerEnter(Collider collider)
    {
        for (int i = 0; i < hideTargetList.Length; i++)
        {
            hideTargetList[i].SetActive(false);
        }
        DestroyTrigger();
    }

    private void DestroyTrigger()
    {
        gameObject.SetActive(false);
        Destroy(gameObject);
    }
}
