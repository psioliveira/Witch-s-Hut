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
        if (other.GetComponent<ItemWorld>() != null)
        {
            inventory.AddItem(other.GetComponent<ItemWorld>().GetItem());
            (other.GetComponent<ItemWorld>()).DestroySelf();
        }
    }
}
