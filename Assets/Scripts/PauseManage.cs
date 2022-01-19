using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseManage : MonoBehaviour
{
    PauseAction action;

    public static bool paused = false;

    public GameObject menu;

    private void Awake()
    {
        action = new PauseAction();
    }

    private void OnEnable()
    {
        action.Enable();
    }

    private void OnDisable()
    {
        action.Disable();
    }

    private void Start()
    {
        action.Pause.PauseGame.performed += _ => DeterminePause();
    }

    public void DeterminePause()
    {
        if (paused)
        {
            ResumeGame();
        }
        else
        {
            PauseGame();
        }
    }
    public void PauseGame()
    {
        Time.timeScale = 0;
        paused = true;
        menu.SetActive(true);
    }

    public void ResumeGame()
    {
        Time.timeScale = 1;
        paused = false;
        menu.SetActive(false);
    }

    public void LoadMenu()
    {
        SceneManager.LoadScene("Menu");
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
