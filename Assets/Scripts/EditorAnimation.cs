using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Random = UnityEngine.Random;

public class EditorAnimation : MonoBehaviour
{
    private void OnDrawGizmos()
    {
        if (EditorApplication.isPlaying) return;
        var animator = GetComponent<Animator>();
        animator.Play("Run");
        animator.Update(Time.deltaTime);
    }
}
