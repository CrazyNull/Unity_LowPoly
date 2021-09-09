using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(GrassRenderer))]
public class GrassTestEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        if (Application.isPlaying && GUILayout.Button("����"))
        {
            (this.target as GrassRenderer).CreateGrassland();
        }
    }
}
