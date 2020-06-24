using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Leaf : MonoBehaviour
{

    Material material;

    MeshFilter meshFilter;
    MeshRenderer meshRenderer;

    Mesh mesh;

    float thickness;
    float size=3f;

    public Vector3[] points;

    Vector3[] vectors;

    Vector3[] vertices;

    int smooth;

    void ComputeVectors(){
        for (int i = 0; i < vectors.Length; i++)
        {
            vectors[i] = (points[i+1] - points[i]).normalized;
        }
    }

    void CreateLeaf(){

        vertices = new Vector3[points.Length*2];

        Vector3 perp = Vector3.Cross(vectors[0],Vector3.up).normalized;
        vertices[0] = points[0]+perp*thickness;
        vertices[1] = points[0]-perp*thickness;

        int index = 0;

        float smoothValue = 0;

        for (int i = 2; i < vertices.Length; i+=2)
        {
            vertices[i] = vertices[i-2]+vectors[index]*size - perp*thickness*smoothValue;
            vertices[i+1] = vertices[i-1]+vectors[index]*size + perp*thickness*smoothValue;
            index++;
            smoothValue = (float)index/smooth/6;
        }

        mesh.vertices = vertices;
        
        int[] tris = new int[(vertices.Length-2)*3];
        index=0;
        
        for (int j = 0; j < tris.Length; j+=6)
        {
            tris[j] = index;
            tris[j+1] = index+1;
            tris[j+2] = index+2;

            tris[j+3] = index+2;
            tris[j+4] = index+1;
            tris[j+5] = index+3;
            index+=2;
        }

        mesh.triangles = tris;
        mesh.RecalculateNormals();
        meshFilter.mesh = mesh;
        meshRenderer.material = material;
    }

    private void OnDrawGizmos() {
        for (int i = 0; i < vertices.Length; i++)
        {
            Gizmos.DrawCube(vertices[i],0.2f*Vector3.one);
        }    
    }

    // Start is called before the first frame update
    void Start()
    {
    }

    public void Init(Vector3[] points, int smooth, float thickness, Material material){
        this.smooth = smooth;
        this.thickness = thickness;
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshFilter = gameObject.AddComponent<MeshFilter>();
        mesh = new Mesh();
        this.material = material;
        this.points = (Vector3[]) points.Clone();
        vectors = new Vector3[points.Length-1];
        ComputeVectors();
        CreateLeaf();
    }
}