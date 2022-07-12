
using System;
using System.Collections.Generic;
using UnityEngine;

public class EnemyDamageHandler : MonoBehaviour
{
    [SerializeField] private Animator enemyAnimator;
    private bool dead = false;
    public int maxHealth;
    private int currentHealth;
    public HealthBar healthBar;
    [SerializeField] private AudioSource enemyDeathSound;
    [SerializeField] private Rigidbody rigidbody;
    [SerializeField] private float forceBack;
     

    void Start()
    {
        currentHealth = maxHealth;
        healthBar.SetMaxHealth(maxHealth);
        rigidbody = GetComponent<Rigidbody>();
    }


    public void TakeDamage(int damage)
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
            Vector3 difference = rigidbody.transform.position - transform.position;
            difference = difference.normalized * forceBack;
            rigidbody.AddForce(difference, ForceMode.Impulse);
           
        }

    }
    void Dead()
    {
        Destroy(gameObject);
    }

    private void Die()
    {
        enemyDeathSound.Play();
        enemyAnimator.SetBool("Die", true);
        dead = true;

        GetComponent<SkeletonAI>().IsDead();
        this.GetComponent<Collider>().enabled = false;
        this.GetComponent<Rigidbody>().isKinematic = true;
    }

 
}
