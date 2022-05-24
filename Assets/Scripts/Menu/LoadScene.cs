using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScene : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            SceneManager.LoadScene("Menu");
        }

        if (other.tag != "Player")
        {
            Destroy(other.gameObject);
        }
    }
}
