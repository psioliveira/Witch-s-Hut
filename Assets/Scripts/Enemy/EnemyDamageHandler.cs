
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
    [SerializeField] private GameObject player;
     

    void Start()
    {
        currentHealth = maxHealth;
        healthBar.SetMaxHealth(maxHealth);
        rigidbody = GetComponent<Rigidbody>();
        player = GameObject.Find("player");
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
            Vector3 difference = (this.gameObject.transform.position - player.gameObject.transform.position).normalized;
            difference = difference * forceBack;
            rigidbody.AddForce(difference, ForceMode.Impulse);
            Debug.Log("knockback");
           
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
