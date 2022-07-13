using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WinGame : MonoBehaviour
{
    [SerializeField] private List<EnemyDamageHandler> enemies;
    public GameObject win;

    // Update is called once per frame
    void Update()
    {
        bool allDead = true;

        foreach (var enemy in enemies)
        {
            if (enemy)
            {
                if (enemy.healthBar.health > 0)
                {
                    allDead = false;
                    break;
                }
            }
        }

        if (allDead)
        {
            win.SetActive(true);
            enabled = false;

            
            
        }
    }
}
