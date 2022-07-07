using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnockBack : MonoBehaviour
{
    public float range = 3f;
    public float KnockbackForce = 500;
    

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            ShootRaycast();
        }
    }

    void ShootRaycast()
    {
        RaycastHit hit;
        if(Physics.Raycast(transform.position, transform.forward, out hit, range))
        {
            EnemyDamageHandler target = hit.transform.GetComponent<EnemyDamageHandler>();
            if(target != null)
            {
                Knockback();
            }
        }
    }

    void Knockback()
    {
        transform.position -= transform.forward * Time.deltaTime * KnockbackForce;
    }
    /*public float thrust;
    public float knockTime;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Enemy"))
        {
            Rigidbody enemy = other.GetComponent<Rigidbody>();
            if (enemy != null)
            {
                enemy.isKinematic = false;
                Vector3 difference = enemy.transform.position - transform.position;
                difference = difference.normalized * thrust;
                enemy.AddForce(difference, ForceMode.Impulse);
                StartCoroutine(KnockC(enemy));
            }
        }
    }
    private IEnumerator KnockC(Rigidbody enemy)
    {
        if (enemy != null)
        {
            yield return new WaitForSeconds(knockTime);
            enemy.velocity = Vector3.zero;
            enemy.isKinematic = true;
        }
    }*/
}
