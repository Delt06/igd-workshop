using System.Collections;
using UnityEngine;

public sealed class ShootWithSpheres : MonoBehaviour
{
	[SerializeField] private float _speed = 1f;

	private void Update()
	{
		if (!Input.GetMouseButtonDown(0)) return;

		var bullet = GameObject.CreatePrimitive(PrimitiveType.Sphere);
		bullet.name = "Bullet";
		
		var ray = _camera.ScreenPointToRay(Input.mousePosition);
		bullet.transform.localScale = 0.25f * Vector3.one;
		bullet.transform.position = ray.origin;
		
		var body = bullet.AddComponent<Rigidbody>();
		body.velocity = ray.direction * _speed;
		body.mass = 0.5f;
		
		StartCoroutine(DestroyAfterDelay(bullet));
	}

	private IEnumerator DestroyAfterDelay(GameObject obj)
	{
		yield return new WaitForSeconds(10f);
		Destroy(obj);
	}

	private void Awake()
	{
		_camera = Camera.main;
	}

	private Camera _camera;
}