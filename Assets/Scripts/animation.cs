
using UnityEngine;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(Rigidbody))]
public class Animation : MonoBehaviour
{
    [SerializeField]
    private Animator _playerAnimator;

    [SerializeField]
    private float _speed;
    [SerializeField]
    private float _normalSpeed;
    [SerializeField]
    private float _runSpeed;

    [SerializeField]
    private Vector3 _velocity;

    void Start()
    {
        _playerAnimator = GetComponent<Animator>();

    }

    void FixedUpdate()
    {
        UpdateVelocity();

    }

    private void UpdateAnimatorVariables()
    {
        _playerAnimator.SetFloat("Velocity up down", _velocity.z);
        _playerAnimator.SetFloat("Velocity left right", _velocity.x);
    }

    private void Update()
    {
        UpdateAttack();
        _velocity.x = Input.GetAxisRaw("Horizontal");
        _velocity.z = Input.GetAxisRaw("Vertical");
        UpdateAnimatorVariables();
        if (Input.GetButton("Run"))
        {
            _speed = _runSpeed;
        }
        else
        {
            _speed = _normalSpeed;
        }

    }


    private void UpdateVelocity()
    {

        GetComponent<Rigidbody>().MovePosition(GetComponent<Rigidbody>().position + _velocity * _speed * Time.fixedDeltaTime);

    }


    private void UpdateAttack()
    {

    }


    internal void Heal(float HealAmount)
    {
        //  PlayerStatus.heal(stat.baseHeal);
    }
}
