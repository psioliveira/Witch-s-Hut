using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class KillPlayer : MonoBehaviour
{
    public float restarDelay = 2f;
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            Invoke("Restart", restarDelay);
            
        }
    }
    
    void Restart()
    {
      SceneManager.LoadScene("hutt Miguel");  
    }
    
}
