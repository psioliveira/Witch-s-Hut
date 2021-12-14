
using System;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamageHandler : MonoBehaviour
{
    [SerializeField] private List<Item> itemList;
    private int maxHealth = 100;
    private int currentHealth;
    [SerializeField] private Animator enemyAnimator;
    [SerializeField] private float timeLeft;
    private bool dead = false;

    void Start()
    {

        currentHealth = maxHealth;
    }

    private void Update()
    {

    }

    public void takeDamage(int damage)
    {
        currentHealth -= damage;

        if (currentHealth <= 0)
        {
            currentHealth = 0;
            if (!dead)
                Die();

        }
        else
        {
            enemyAnimator.SetTrigger("Hurt");
            //hurt animation
        }

    }

    private void Die()
    {

        enemyAnimator.SetTrigger("Die");
        dead = true;

        ItemWorld.SpawnItemWorld(transform.position, itemList[UnityEngine.Random.Range(0, itemList.Count)]);


    }

}
