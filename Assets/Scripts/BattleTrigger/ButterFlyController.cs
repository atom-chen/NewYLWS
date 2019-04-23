using UnityEngine;

public class ButterFlyController : MonoBehaviour
{
    public float destroyTime = 20f;
    public float speed = 2f;

    private Transform m_transform;

    void Start()
    {
        m_transform = transform;

        float rotationX = Random.Range(0, 30);
        float rotationY = Random.Range(90, 270);
        m_transform.localRotation = Quaternion.Euler(new Vector3(rotationX, rotationY, 0));

        Invoke("DestroyMySelf", destroyTime);
    }

    void Update()
    {
        m_transform.Translate(Vector3.back * Time.deltaTime * speed);
        float randomY = Random.Range(-0.15f, 0.15f);
        Vector3 pos = m_transform.position;
        pos.y += randomY;
        m_transform.position = pos;
    }

    private void DestroyMySelf()
    {
        Destroy(gameObject);
    }
}
