using UnityEngine;

public class PlayerHandler : MonoBehaviour
{
    private Inventory inventory;
    [SerializeField] private UI_Inventory uiInventory;



    private void Awake()
    {
        inventory = new Inventory();
        uiInventory.SetInventory(inventory);
    }
    private void OnTriggerEnter(Collider other)
    {


        ItemWorld itemWorld = other.GetComponent<ItemWorld>();

        if (itemWorld != null)
        {
            inventory.AddItem(itemWorld);

            Quest quest = GetComponent<PlayerController>().quest;

            if (quest.isActive && quest.itemInfo == itemWorld.ItemInfo)
            {
                quest.goal.currentAmount++;
                if (quest.goal.IsReached())
                    quest.Complete();
            }

            itemWorld.DestroySelf();
        }

    }
}
