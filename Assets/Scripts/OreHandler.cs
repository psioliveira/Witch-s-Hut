
using System;
using System.Collections.Generic;
using UnityEngine;

public class OreHandler : MonoBehaviour
{
    [SerializeField] private List<ItemInfo> itemList;
    private int maxHealth = 100;
    private int currentHealth;
    
    [SerializeField] private ItemWorld itemWorldPrefab;

    void Start()
    {
        currentHealth = maxHealth;
    }


    public void takeDamage(int damage)
    {
        currentHealth -= damage;

        if (currentHealth <= 0 || itemList.Count == 0)
        {
            currentHealth = 0;
            Destroy(gameObject);
        }

        else
        {
            int itemindex = UnityEngine.Random.Range(0, itemList.Count);
            Instantiate(itemWorldPrefab, transform.position, Quaternion.identity).
             GetComponent<ItemWorld>().
             SetItem(itemList[itemindex]);
            itemList.RemoveAt(itemindex);
        }

    }

}
