using UnityEngine;
using UnityEngine.UI;

public class HealthPickup : MonoBehaviour
{
    PlayerDamageHandler playerHealth;
    public HealthBar slider;
    public int healthBonus;
    [SerializeField] private AudioSource healthPickup;

    void Awake()
    {
        playerHealth = FindObjectOfType<PlayerDamageHandler>();
    }

    void OnTriggerEnter(Collider other)
    {
        if (playerHealth.currentHealth < playerHealth.maxHealth)
        {
            Destroy(gameObject);
            healthPickup.Play();
            playerHealth.currentHealth = playerHealth.currentHealth + healthBonus;
            slider.SetHealth(playerHealth.currentHealth);
        }
        if (playerHealth.currentHealth > playerHealth.maxHealth)
        {
           playerHealth.currentHealth = playerHealth.maxHealth; 
        } 
    }
}
