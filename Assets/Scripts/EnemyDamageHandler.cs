
using System;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamageHandler : MonoBehaviour
{
    [SerializeField] private List<ItemInfo> itemList;
    private int maxHealth = 100;
    private int currentHealth;
    public HealthBar healthBar;
    [SerializeField] private Animator enemyAnimator;
    private bool dead = false;
    [SerializeField] private ItemWorld itemWorldPrefab;

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

        }

        else
        {
            enemyAnimator.SetTrigger("Hurt");
            //hurt animation
        }

    }

    private void Die()
    {
        enemyAnimator.SetBool("Die", true);
        dead = true;

        Instantiate(itemWorldPrefab, transform.position, Quaternion.identity).
            GetComponent<ItemWorld>().
            SetItem(itemList[UnityEngine.Random.Range(0, itemList.Count)]);
        GetComponent<SkeletonAI>().IsDead();
        this.GetComponent<Collider>().enabled = false;
        this.GetComponent<Rigidbody>().isKinematic = true;
    }

 
}
