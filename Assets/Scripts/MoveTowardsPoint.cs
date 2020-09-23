using System;
using UnityEngine;

public class MoveTowardsPoint : MonoBehaviour
{
	[SerializeField] private Transform _target = default;
	[SerializeField] private float _speed = 1f;
	[SerializeField] private Mode _mode = Mode.Better;
	
	private void Update()
	{
		switch (_mode)
		{
			case Mode.Naive:
				MoveNaive();
				break;
			case Mode.Better:
				MoveBetter();
				break;
		}
	}

	private void MoveNaive()
	{
		var direction = (_target.position - transform.position).normalized;
		transform.position += _speed * Time.deltaTime * direction;
	}

	private void MoveBetter()
	{
		var deltaDistance = _speed * Time.deltaTime;
		transform.position = Vector3.MoveTowards(transform.position, _target.position, deltaDistance);
	}

	private enum Mode
	{
		Naive, Better
	}
}