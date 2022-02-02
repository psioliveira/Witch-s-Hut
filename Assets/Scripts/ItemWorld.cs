using UnityEngine;

public class ItemWorld : MonoBehaviour
{
    private ItemInfo itemInfo;
    private SpriteRenderer spriteRenderer;
    private int amount = 1;
    private void Awake()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
    }
    public void SetItem(ItemInfo itemInfo)
    {
        this.itemInfo = itemInfo;
        spriteRenderer.sprite = itemInfo.itemSprite;
    }
    public ItemInfo GetItem()
    {
        return itemInfo;
    }


    public int GetAmount()
    {
        return amount;
    }
    public void AddAmount(int amount)
    {
        this.amount += amount;
    }

    public void DestroySelf()
    {
        Destroy(gameObject);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (GetComponent<Collider>().tag == "Item" && collision.transform.gameObject.tag != "Map")
        {
            Physics.IgnoreCollision(GetComponent<Collider>(), collision.collider, true);
        }
    }
}
