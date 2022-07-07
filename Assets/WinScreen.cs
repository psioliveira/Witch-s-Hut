using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class WinScreen : MonoBehaviour
{
public Text pointsText;

    public void Setup(int time)
    {

        gameObject.SetActive(true);
        pointsText.text = time.ToString() + "S";
        StopGame();
        
    }
     public void StopGame()
    {
        Time.timeScale = 0;
    }  
}
