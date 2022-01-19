using UnityEngine;

public class ItemWorld : MonoBehaviour
{
    private ItemInfo itemInfo;
    private SpriteRenderer spriteRenderer;

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

    public void DestroySelf()
    {
        Destroy(gameObject);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.gameObject.tag != "Map")
        {
            Physics.IgnoreCollision(GetComponent<Collider>(), collision.collider, true);
        }
    }
}
