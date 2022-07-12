using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerDamageHandler : MonoBehaviour
{
    public HealthBar healthBar;
    public int maxHealth = 100;
    public int currentHealth;
    [SerializeField] private Animator playerAnimator;
    [SerializeField] private AudioSource deathSound;
    private bool dead = false;
    private bool invincible = false;

    public GameObject death;
    
    void Start()
    {
        currentHealth = maxHealth;
        healthBar.SetMaxHealth(maxHealth);
    }


    public void TakeDamage(int damage)
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
                death.SetActive(true);
                //Invoke("Restart", 2f);
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
        deathSound.Play();
        playerAnimator.SetBool("Die", true);
        dead = true;
        GetComponent<PlayerController>().IsDead();
    }

}
