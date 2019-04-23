using UnityEngine;

public class ButterFlyTrigger : MonoBehaviour
{
    public GameObject[] butterFly;

    void OnTriggerEnter(Collider collider)
    {
        for (int i = 0; i < butterFly.Length; i++)
        {
            butterFly[i].AddComponent<ButterFlyController>();
        }
        DestroyTrigger();
    }

    private void DestroyTrigger()
    {
        gameObject.SetActive(false);
        Destroy(gameObject);
    }
}
