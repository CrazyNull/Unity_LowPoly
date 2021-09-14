using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grass_InstancedIndirect : MonoBehaviour
{
    public Vector2 Size;
    [Range(0f,1.0f)]
    public float Density = 0.5f;
    public int UnitMaxNum = 100;

    public Mesh instanceMesh;
    public Material instanceMaterial;
    public int subMeshIndex = 0;

    [Header("»æÖÆÊµÀýÊý")]
    public int DrawInstanceCount = 0;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };

    private int _drawInstanceCount = 0;

    void Start()
    {
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        int count = Mathf.FloorToInt(this.Size.x * this.Size.y * Density * UnitMaxNum);
        UpdateBuffers(count);
    }

    void Update()
    {
        Graphics.DrawMeshInstancedIndirect(instanceMesh, subMeshIndex, instanceMaterial, new Bounds(this.transform.position, new Vector3(100.0f, 100.0f, 100.0f)), argsBuffer);
        this.DrawInstanceCount = this._drawInstanceCount;
    }

    void UpdateBuffers(int instanceCount)
    {
        if (instanceMesh != null)
            subMeshIndex = Mathf.Clamp(subMeshIndex, 0, instanceMesh.subMeshCount - 1);
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = new ComputeBuffer(instanceCount, 16);
        Vector4[] positions = new Vector4[instanceCount];
        for (int i = 0; i < instanceCount; i++)
        {
            positions[i] = new Vector4(Random.Range(-this.Size.x * 0.5f,this.Size.x * 0.5f),0, Random.Range(-this.Size.y * 0.5f, this.Size.y * 0.5f), 0);
        }
        positionBuffer.SetData(positions);
        instanceMaterial.SetBuffer("positionBuffer", positionBuffer);

        // Indirect args
        if (instanceMesh != null)
        {
            args[0] = (uint)instanceMesh.GetIndexCount(subMeshIndex);
            args[1] = (uint)instanceCount;
            args[2] = (uint)instanceMesh.GetIndexStart(subMeshIndex);
            args[3] = (uint)instanceMesh.GetBaseVertex(subMeshIndex);
        }
        else
        {
            args[0] = args[1] = args[2] = args[3] = 0;
        }
        argsBuffer.SetData(args);
        this._drawInstanceCount = instanceCount;
    }

    void OnDisable()
    {
        if (positionBuffer != null)
            positionBuffer.Release();
        positionBuffer = null;

        if (argsBuffer != null)
            argsBuffer.Release();
        argsBuffer = null;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireCube(this.transform.position, new Vector3(this.Size.x, 0, this.Size.y));
    }
}
