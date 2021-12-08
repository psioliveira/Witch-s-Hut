
using UnityEngine;

public class EnemyDamageHandler : MonoBehaviour
{
    private int maxHealth = 100;
    private int currentHealth;
    [SerializeField] private Animator EnemyAnimator;
    void Start()
    {

        currentHealth = maxHealth;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void takeDamage(int damage)
    {
        currentHealth -= damage;

        if (currentHealth <= 0)
        {
            Die();

        }
        else
        {
            EnemyAnimator.SetTrigger("Hurt");
            //hurt animation
        }

    }

    private void Die()
    {
        EnemyAnimator.SetTrigger("Die");

    }

}
