
using System;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamageHandler : MonoBehaviour
{
    //[SerializeField] private List<ItemInfo> itemList;
    [SerializeField] private Animator enemyAnimator;
    //[SerializeField] private ItemWorld itemWorldPrefab;
    private bool dead = false;
    private int maxHealth = 100;
    private int currentHealth;
    public HealthBar healthBar;

    void Start()
    {
        currentHealth = maxHealth;
        healthBar.SetMaxHealth(maxHealth);
    }


    public void takeDamage(int damage)
    {
        currentHealth -= damage;
        healthBar.SetHealth(currentHealth);

        if (currentHealth <= 0)
        {
            currentHealth = 0;
            if (!dead)
                Die();
               Invoke("Dead", 1.5f);
        }

        else
        {
            enemyAnimator.SetTrigger("Hurt");
            //hurt animation
        }

    }
    void Dead()
    {
        Destroy(gameObject);
    }

    private void Die()
    {
        enemyAnimator.SetBool("Die", true);
        dead = true;

        GetComponent<SkeletonAI>().IsDead();
        this.GetComponent<Collider>().enabled = false;
        this.GetComponent<Rigidbody>().isKinematic = true;
    }

 
}
