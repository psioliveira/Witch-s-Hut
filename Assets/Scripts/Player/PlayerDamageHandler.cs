using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

class PlayerDamageHandler : MonoBehaviour
{
    public HealthBar healthBar;
    private int maxHealth = 100;
    private int currentHealth;
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
            //invincible = true;


            if (currentHealth <= 0)
            {
                currentHealth = 0;    
                if (!dead)
                {
                    Die();  
                }
                Invoke("Restart", 2f);
            }

            else
            {
                playerAnimator.SetTrigger("Hurt");
            }
        }
        StartCoroutine(Invincible());
    }

    void Restart()
    {
        SceneManager.LoadScene("hutt Miguel");
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
