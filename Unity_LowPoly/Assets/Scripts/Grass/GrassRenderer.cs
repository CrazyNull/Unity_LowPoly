using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassRenderer : MonoBehaviour
{
    public Mesh GrassMesh = null;
    public Material GrassMaterial = null;

    [Range(0f,1f)]
    public float Density = 0.25f;
    [Range(1,500)]
    public int GrassNum = 50;


    protected List<Matrix4x4[]> Matrix4x4s = null;

    // Start is called before the first frame update
    void Start()
    {
        //Shader.SetGlobalVector("_GrassOffsetCenter",Vector4.zero);
        //Shader.SetGlobalVector("_GrassOffsetCenter", SphereObj.position);
        //Shader.SetGlobalFloat("_GrassOffsetRadius", SphereObj.GetComponent<SphereCollider>().radius);
    }

    // Update is called once per frame
    void Update()
    {
        if (null != Matrix4x4s)
        {
            for (int i = 0; i < Matrix4x4s.Count; ++i)
            {
                Matrix4x4[] chunk = Matrix4x4s[i];
                Graphics.DrawMeshInstanced(this.GrassMesh, 0, this.GrassMaterial, chunk);
            }
        }
    }

    public void CreateGrassland()
    {
        float x = this.GetComponent<BoxCollider>().size.x;
        float z = this.GetComponent<BoxCollider>().size.z;
        int num = (int)(x * z * Density * (float)GrassNum);
        List<Matrix4x4> list = new List<Matrix4x4>();
        for (int i = 0; i < num; ++i)
        {
            Vector3 pos = new Vector3(Random.Range(-x * 0.5f, x * 0.5f), 0, Random.Range(-z * 0.5f, z * 0.5f));
            list.Add(Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one));
        }

        Matrix4x4s = new List<Matrix4x4[]>();
        List<Matrix4x4> temp = new List<Matrix4x4>();
        for (int i = 0; i < list.Count; ++i)
        {
            temp.Add(list[i]);
            if (temp.Count >= 1023 || i == list.Count - 1)
            {
                Matrix4x4s.Add(temp.ToArray());
                temp.Clear();
            }
        }
    }
}
