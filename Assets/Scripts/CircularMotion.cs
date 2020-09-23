using UnityEngine;

public sealed class CircularMotion : MonoBehaviour
{
	[SerializeField] private Transform _center = default;
	[SerializeField] private float _speed = 1f;

	private void FixedUpdate()
	{
		var accelerationMagnitude = _speed * _speed / Radius;
		var acceleration = Direction * accelerationMagnitude;
		
		_rigidbody.AddForce(acceleration, ForceMode.Acceleration);
	}

	private float Radius => Vector3.Distance(_rigidbody.position, _center.position);

	private Vector3 Direction => (_center.position - _rigidbody.position).normalized;

	private void Awake()
	{
		_rigidbody = GetComponent<Rigidbody>();
		_rigidbody.velocity = Vector3.forward * _speed;
	}

	private Rigidbody _rigidbody;

	private void OnDrawGizmos()
	{
		if (_center != null)
		{
			Gizmos.color = Color.red;
			Gizmos.DrawSphere(_center.position, 0.2f);
		}
	}
}