using System.Collections;
using UnityEngine;

public class SkeletonAI : MonoBehaviour
{
    [SerializeField] private Animator myAnim;
    [SerializeField] private Transform target;
    [SerializeField] private float speed;
    [SerializeField] private float maxRange;
    [SerializeField] private float minRange;
    [SerializeField] private float attackRange;
    private bool dead = false;
    private Vector3 attackPos;


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
        attackPos = (target.position - transform.position).normalized;
        attackPos = new Vector3(attackPos.x, transform.position.y / 2, attackPos.z);
        myAnim.SetTrigger("Attack");
        yield return new WaitForSeconds(5f);
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

}
