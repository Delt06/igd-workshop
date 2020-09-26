using System;
using UnityEngine;

public class TriggerCallbacks : MonoBehaviour
{
	private void OnTriggerEnter(Collider other)
	{
		Debug.Log(other + " entered the trigger");
	}

	private void OnTriggerStay(Collider other)
	{
		Debug.Log(other + " is still inside the trigger");
	}

	private void OnTriggerExit(Collider other)
	{
		Debug.Log(other + " exited the trigger");
	}
}