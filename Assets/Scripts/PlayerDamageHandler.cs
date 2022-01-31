using System;
using System.Collections;
using UnityEngine;

class PlayerDamageHandler : MonoBehaviour
{
    public int maxHealth = 100;
    public int currentHealth;
    public HealthBar healthBar;
    [SerializeField] private Animator playerAnimator;
    private bool dead = false;
    private bool invincible = false;

    

    void Start()
    {
        currentHealth = maxHealth;
        healthBar.SetMaxHealth(maxHealth);
    }


    public void takeDamage(int damage)
    {
        if (!invincible)
        {
            currentHealth -= damage;
            healthBar.SetHealth(currentHealth);
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
