
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    public ItemInfo item;
    [SerializeField]private ItemWorld itemWorld;

    private void Start()
    {
        Item i = new Item();
        i.itemInfo = item;
        Instantiate(itemWorld, transform.position, Quaternion.identity).
                                    GetComponent<ItemWorld>().SetItem(i);
        Destroy(gameObject);
    }
}
