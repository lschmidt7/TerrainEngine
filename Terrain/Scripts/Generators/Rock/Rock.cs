using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rock : MonoBehaviour
{

    /*public Material mat;
    public int stepCircle;
    public int stepHeight;
    public Vector3 radius;
    public Color color;
    [Range(0.0f,1.0f)]
    public float noise;*/

    Mesh mesh;


    public void Create(Material mat, int stepCircle, int stepHeight, Vector3 radius, Color color,float noise){
        MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
        mesh = new Mesh();
        
        Sphere s = new Sphere(stepCircle,stepHeight,radius,noise);

        mesh.vertices = s.getVertex();
        mesh.triangles = s.getTriangles();
        mesh.uv = s.getUvs();
        mesh.RecalculateNormals();
        
        meshFilter.mesh = mesh;
        meshRenderer.material = mat;

        mat.SetColor("_Color",color);
    }

    // Start is called before the first frame update
    void Start()
    {

        

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
