
using UnityEngine;

public class ItemSpawner : MonoBehaviour
{
    [SerializeField] private ItemInfo itemInfo;
    [SerializeField] private GameObject item;


    private void Start()
    {
        
        Instantiate(item, transform.position, Quaternion.identity).
            GetComponent<ItemWorld>().SetItem(itemInfo);
        
        Destroy(gameObject);
    }
}
