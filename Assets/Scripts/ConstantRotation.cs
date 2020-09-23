using UnityEngine;

public sealed class ConstantRotation : MonoBehaviour
{
	[SerializeField] private Vector3 _angularSpeed = Vector3.zero;

	private void Update()
	{
		transform.Rotate(_angularSpeed * Time.deltaTime);
	}
}