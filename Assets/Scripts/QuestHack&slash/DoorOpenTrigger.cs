using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DoorOpenTrigger : MonoBehaviour
{
    [SerializeField] private List<EnemyDamageHandler> enemies;
    public GameObject prefab;
    public Transform spawnPosition;

    //public GameObject win;

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
            //win.SetActive(true);
            Instantiate(prefab, spawnPosition.position, spawnPosition.rotation); 
            
            GetComponent<Animator>().Play("Door message 1");
            GetComponent<Animator>().Play("Door 1 Open");
            GetComponent<Animator>().Play("Door 2");
            GetComponent<Animator>().Play("Door 3");
            GetComponent<Animator>().Play("Door 4");
            GetComponent<Animator>().Play("Door5");
            GetComponent<Animator>().Play("Door 6");
            GetComponent<Animator>().Play("Door 7");
            enabled = false;

            
            
        }
    }
}
