using System;
using System.Collections.Generic;
using UnityEngine;

public class CollisionWorkaround : MonoBehaviour
{
	private void OnCollisionEnter(Collision other)
	{
		_contacts.Add(other.collider);
	}

	private void FixedUpdate()
	{
		foreach (var contact in _contacts)
		{
			Debug.Log("Do work with " + contact);
		}
	}

	private void OnCollisionExit(Collision other)
	{
		_contacts.Remove(other.collider);
	}

	private HashSet<Collider> _contacts = new HashSet<Collider>();
}