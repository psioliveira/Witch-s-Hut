using System.Collections;
using UnityEngine;
using UnityEngine.AI;
public class SkeletonAI : MonoBehaviour
{
    [SerializeField] private Animator myAnim;
    [SerializeField] private Transform target;
    [SerializeField] private float speed;
    [SerializeField] private float maxRange;
    [SerializeField] private float minRange;
    [SerializeField] private float attackRange;
    [SerializeField] private int id;
    private bool dead = false;
    private Vector3 attackPos;
    [SerializeField]private float attackRadius = 1.2f;
    [SerializeField] private int attackDamage;
    private PatrolAI ai;

    // Start is called before the first frame update
    void Start()
    {
        myAnim = GetComponent<Animator>();
        target = FindObjectOfType<PlayerController>().transform;
    }

    // Update is called once per frame
    void Update()
    {
        if (!dead)
        {
            if (Vector3.Distance(target.position, transform.position) <= attackRange)
            {
                StartCoroutine(AttackPlayer());
            }
            else if (Vector3.Distance(target.position, transform.position) <= maxRange && Vector3.Distance(target.position, transform.position) >= minRange)
            {
                FollowPlayer();
            }
            else
                myAnim.SetBool("Moving", false);

        }


    }

    private IEnumerator AttackPlayer()
    {
        myAnim.SetBool("Moving", false);

        myAnim.SetFloat("MoveX", target.position.x - transform.position.x);
        myAnim.SetFloat("MoveY", target.position.z - transform.position.z);
        attackPos = (transform.position);
       
        myAnim.SetTrigger("Attack");
        Collider[] hitColliders = Physics.OverlapSphere(attackPos, attackRadius);
        foreach (var hitCollider in hitColliders)
        {
            if (hitCollider.tag == "Player")
            {
                hitCollider.transform.GetComponent<PlayerDamageHandler>().takeDamage(attackDamage);
            }

        }

        yield return new WaitForSecondsRealtime(2f);
        myAnim.ResetTrigger("Attack");

        yield return null;
    }

    public void FollowPlayer()
    {
        myAnim.SetBool("Moving", true);
        myAnim.SetFloat("MoveX", target.position.x - transform.position.x);
        myAnim.SetFloat("MoveY", target.position.z - transform.position.z);
        transform.position = Vector3.MoveTowards(transform.position, target.transform.position, speed * Time.deltaTime);

    }
    public void IsDead()
    {
        dead = true;
    }
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(attackPos, attackRadius);
    }
}
