using UnityEngine;

public class ShowTrigger : MonoBehaviour
{
    public GameObject[] showTargetList;

    void OnTriggerEnter(Collider collider)
    {
        for (int i = 0; i < showTargetList.Length; i++)
        {
            showTargetList[i].SetActive(false);
        }
        DestroyTrigger();
    }

    private void DestroyTrigger()
    {
        gameObject.SetActive(false);
        Destroy(gameObject);
    }
}
