using UnityEngine;

public class MoveLocalWorld : MonoBehaviour
{
	[SerializeField] private Vector3 _velocity = default;
	[SerializeField] private Mode _mode = Mode.Local;

	private void Update()
	{
		switch (_mode)
		{
			case Mode.Local:
				transform.localPosition += _velocity * Time.deltaTime;
				break;
			case Mode.World:
				transform.position += _velocity * Time.deltaTime;
				break;
		}
	}

	private enum Mode
	{
		Local, World
	}
}