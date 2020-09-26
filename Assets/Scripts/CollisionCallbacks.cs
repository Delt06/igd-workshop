using System;
using UnityEngine;

public class CollisionCallbacks : MonoBehaviour
{
	private void OnCollisionEnter(Collision other)
	{
		Debug.Log("Contact began");
		Debug.Log("Collision impulse" + other.impulse);
		Debug.Log("Contacted with " + other.gameObject);
	}

	private void OnCollisionStay(Collision other)
	{
		Debug.Log("Contact continues");
		// pitfall: will not be called if objects sleep
	}

	private void OnCollisionExit(Collision other)
	{
		Debug.Log("Contact ended");
	}
}