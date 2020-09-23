using UnityEngine;

public sealed class ForceModes : MonoBehaviour
{
	[SerializeField] private ForceMode _forceMode = default;
	[SerializeField] private Vector3 _value = default;

	private void FixedUpdate()
	{
		switch (_forceMode)
		{
			case ForceMode.Force: // default force mode
				_rigidbody.AddForce(_value);
				break;
			case ForceMode.Acceleration:
				_rigidbody.AddForce(_value, ForceMode.Acceleration);
				break;
		}
	}

	private void Start()
	{
		switch (_forceMode)
		{
			case ForceMode.Impulse:
				_rigidbody.AddForce(_value, ForceMode.Impulse);
				break;
			case ForceMode.VelocityChange:
				_rigidbody.AddForce(_value, ForceMode.VelocityChange);
				break;
		}
	}

	private void Awake()
	{
		_rigidbody = GetComponent<Rigidbody>();
	}

	private Rigidbody _rigidbody;
}