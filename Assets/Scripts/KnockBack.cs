using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KnockBack : MonoBehaviour
{
    public float thrust;
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
    }
}
