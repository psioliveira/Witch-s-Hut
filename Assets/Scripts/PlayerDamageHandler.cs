using System;
using System.Collections;
using UnityEngine;

class PlayerDamageHandler : MonoBehaviour
{
    private int maxHealth = 100;
    private int currentHealth;
    [SerializeField] private Animator playerAnimator;
    private bool dead = false;
    private bool invincible = false;

    void Start()
    {
        currentHealth = maxHealth;
    }


    public void takeDamage(int damage)
    {
        if (!invincible)
        {
            currentHealth -= damage;
            invincible = true;


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
        StartCoroutine(Invincible());
    }

    private IEnumerator Invincible()
    {
        yield return new WaitForSecondsRealtime(2f);
        invincible = false;
    }

    private void Die()
    {
        playerAnimator.SetBool("Die", true);
        dead = true;
        GetComponent<PlayerController>().IsDead();
    }

}
