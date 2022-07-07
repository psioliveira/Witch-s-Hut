using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DeathMenu : MonoBehaviour
{
    public void Restart()
    {
        SceneManager.LoadScene("hutt Miguel");
    }

    public void Menu()
    {
         SceneManager.LoadScene("Menu");
    }
    
}
