using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class GameOverScreen : MonoBehaviour
{

    public void Setup(int time)
    {

        gameObject.SetActive(true);
        StopGame();
        
    }
     public void StopGame()
    {
        Time.timeScale = 0;
    }
}

