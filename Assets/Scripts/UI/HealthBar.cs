using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{
    public float  health;
    public Slider slider;
    public Gradient gradient;
    public Image colorFill;

    public void SetMaxHealth(int health)
    {
        this.health = health;
        slider.maxValue = health;
        slider.value = health;

        colorFill.color = gradient.Evaluate(1f);
    }

    public void SetHealth(int health)
    {
        this.health = health;
        slider.value = health;

        colorFill.color = gradient.Evaluate(slider.normalizedValue);

        if (health == 0)
        {
            gameObject.SetActive(false);
        }
    }
}
