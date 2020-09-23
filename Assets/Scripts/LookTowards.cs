using UnityEngine;

public class LookTowards : MonoBehaviour
{
	[SerializeField] private Transform _target = default;

	private void Update()
	{
		transform.LookAt(_target);
	}
}