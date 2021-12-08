using PlayerControl;
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{

    private PlayerControls playerControl;

    [SerializeField] private float acceleration = 0.6f;
    [SerializeField] private float maxSpeed = 30;
    [SerializeField] private float speed = 0;
    private Vector3 rawInput;


    [SerializeField] private float dashSpeed = 15f;
    [SerializeField] private float dashLength = .3f;
    [SerializeField] private bool isDashing = false;
    [SerializeField] private bool hasDashed = false;
    [SerializeField] private Vector3 playerDirection;

    [SerializeField] private bool _canDash = true;

    public Vector3 GetRawInput()
    {
        return rawInput; 
    }

    private void Awake()
    {
        playerControl = new PlayerControls();
    }


    private void OnEnable()
    {
        playerControl.Enable();
    }

    private void OnDisable()
    {
        playerControl.Disable();
    }

    private void Update()
    {
        if (!hasDashed)
            _canDash = true;

    }

    private void FixedUpdate()
    {
        if (_canDash && isDashing) StartCoroutine(Dash());
        if (!isDashing)
        {
            PlayerMovement();
            
        }
    }


    public void OnDash(InputAction.CallbackContext ctx)
    {
        if (!isDashing)
            isDashing = ctx.performed;
    }
    public void OnAttack(InputAction.CallbackContext ctx)
    {

    }


    public void OnMovement(InputAction.CallbackContext ctx)
    {
        rawInput = new Vector3(ctx.ReadValue<Vector2>().x, 0, ctx.ReadValue<Vector2>().y);

    }

    private void PlayerMovement()
    {
        if (rawInput.x != 0 || rawInput.z != 0)
        {
            playerDirection = rawInput;
            speed = speed > maxSpeed ? maxSpeed : speed += acceleration * Time.fixedDeltaTime;
            transform.position += rawInput * speed * Time.fixedDeltaTime;
        }
        else
        {
            speed = 0;
        }

    }



    IEnumerator Dash()
    {
        float dashStartTime = 0;
        hasDashed = true;
        isDashing = true;

       
        while (dashStartTime < dashLength)
        {
            transform.position += playerDirection.normalized * dashSpeed;
            yield return null;
            dashStartTime += Time.fixedDeltaTime;
        }

        isDashing = false;
        hasDashed = false;
    }






}
