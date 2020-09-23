using UnityEngine;

public sealed class MoveAlongParabola : MonoBehaviour
{
	[SerializeField] private float _a = 1f;
	[SerializeField] private float _b = 1f;

	private void Update()
	{
		_x += Time.deltaTime;
		var y = _a * _x * _x + _b * _x;
		transform.position = new Vector3(_x, y);
	}

	private float _x = 0f;
}