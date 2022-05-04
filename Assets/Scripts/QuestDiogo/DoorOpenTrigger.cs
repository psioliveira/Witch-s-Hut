using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorOpenTrigger : MonoBehaviour
{
    [SerializeField] private List<EnemyDamageHandler> enemies;

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
            GetComponent<Animator>().Play("Door 1 Open");
            GetComponent<Animator>().Play("Door 2");
            GetComponent<Animator>().Play("Door 3");
            GetComponent<Animator>().Play("Door 4");
            GetComponent<Animator>().Play("Door5");
            enabled = false;
        }
    }
}
