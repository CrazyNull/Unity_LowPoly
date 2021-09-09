using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(GrassTest))]
public class GrassTestEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (GUILayout.Button("´´½¨"))
        {
            (this.target as GrassTest).CreateGrassland();
        }
    }
}
