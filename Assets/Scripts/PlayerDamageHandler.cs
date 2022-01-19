using System;
using System.Collections.Generic;

using UnityEngine;

class PlayerDamageHandler : MonoBehaviour
{
    private int maxHealth = 100;
    private int currentHealth;
    [SerializeField] private Animator playerAnimator;
    private bool dead = false;

    void Start()
    {
        currentHealth = maxHealth;
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
            playerAnimator.SetTrigger("Hurt");
          
        }

    }

    private void Die()
    {
        playerAnimator.SetBool("Die", true);
        dead = true;

        
        GetComponent<PlayerController>().IsDead();
        this.GetComponent<Collider>().enabled = false;
        this.GetComponent<Rigidbody>().isKinematic = true;
    }

}
