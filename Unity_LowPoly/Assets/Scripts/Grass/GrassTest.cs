using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassTest : MonoBehaviour
{
    public GameObject GrassPrefab = null;
    public int GrassNum = 100;
    public Transform SphereObj = null;


    // Start is called before the first frame update
    void Start()
    {
        Shader.SetGlobalVector("_GrassOffsetCenter",Vector4.zero);
    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_GrassOffsetCenter", SphereObj.position);
        Shader.SetGlobalFloat("_GrassOffsetRadius", 0.5f);
    }

    public void CreateGrassland()
    {
        for (int i = 0; i < this.transform.childCount; ++i)
        {
            GameObject.DestroyImmediate(this.transform.GetChild(i).gameObject);
            --i;
        }
        float x = this.GetComponent<BoxCollider>().size.x;
        float z = this.GetComponent<BoxCollider>().size.z;
        for (int i = 0; i < GrassNum; ++i)
        {
            GameObject grass = GameObject.Instantiate<GameObject>(this.GrassPrefab, this.transform);
            grass.transform.localPosition = new Vector3(Random.Range(-x * 0.5f,x * 0.5f),0,Random.Range(-z * 0.5f, z * 0.5f));
            grass.transform.Rotate(0, Random.Range(0,360), 0);
        }
    }
}
