using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Structs;
using System.IO;
using System.Xml.Serialization;


public class Chunk : MonoBehaviour
{

    public bool editing;
    public bool wireframe;
    MeshGen mesh;
    Material material;
    ComputeBuffer buffer;
    ComputeBuffer vertices;
    ComputeShader compute;

    MeshCollider coll;

    Mesh mesh_for_collider;

    int kernel, kernel_2;

    int id;
    Vector2 pos;

    int chunkSize;

    bool chunckClicked = false;

    public int GetId(){
        return id;
    }

    public void UpdateSculp()
    {
        GameObject terrain = GameObject.Find("Terrain");
        Sculp sculp = terrain.GetComponent<Terrain>().sculp;
        compute.SetFloat("sculpImpact",sculp.impact);
        compute.SetFloat("sculpArea",sculp.area);
        compute.SetFloat("sculpHeightMaxLimit",sculp.max);
        compute.SetFloat("sculpHeightMinLimit",sculp.min);
        compute.SetBool("sculpUp",sculp.up);
        editing = sculp.editing;

        Tesselation tesselation = terrain.GetComponent<Terrain>().tesselation;
        material.SetFloat("_Smooth",tesselation.DispValue);

        material.SetFloat("sculpArea",sculp.area/chunkSize);
        material.SetInt("editing",editing==true ? 1 : 0);
    }

    public void SetShader(Shader shader, ComputeShader compute)
    {
        material = new Material(shader);
        this.compute = Instantiate(compute);
    }

    public void Create(int chunkSize, int id, Vector2 pos)
    {
        this.pos = pos;
        this.chunkSize = chunkSize;
        this.id = id;

        mesh = new MeshGen(transform.position,chunkSize,1);
        mesh.CalculateUV(100);
        mesh.CalculateNormals();

        coll = gameObject.AddComponent<MeshCollider>();

        buffer = new ComputeBuffer ( ( (chunkSize - 1) * (chunkSize - 1) * 6 ) ,32);
        vertices = new ComputeBuffer( chunkSize * chunkSize , 12 );

        buffer.SetData(mesh.triangles);
        vertices.SetData(mesh.vertices);

        material.SetBuffer("buffer",buffer);

        kernel_2 = compute.FindKernel("DeformVertex");
        compute.SetBuffer(kernel_2,"vertices",vertices);

        kernel = compute.FindKernel("Deform");
        compute.SetBuffer(kernel,"buffer",buffer);
    }

    public void SetHeight(Texture2D heightMap, float scale){
        Color[] sub_map = heightMap.GetPixels((int)pos.x,(int)pos.y,chunkSize,chunkSize);
        mesh.SetHeights(sub_map,scale);
        mesh.Triangulate();
        vertices.SetData(mesh.vertices);
        buffer.SetData(mesh.triangles);
    }

    // UPDATE vertexes, triangles and collider of the chunk
    public void UpdateChunk()
    {
        vertices.GetData(mesh.vertices);
        buffer.GetData(mesh.triangles);

        UpdateCollider();
        mesh.SetNormals(mesh_for_collider.normals);
        mesh.Triangulate();

        buffer.SetData(mesh.triangles);
        vertices.SetData(mesh.vertices);
    }

    public void UpdateCollider()
    {
        mesh_for_collider = new Mesh();
        Vector3[] vertexes = new Vector3[chunkSize*chunkSize];
        for (int i = 0; i < chunkSize; i++)
        {
            for (int j = 0; j < chunkSize; j++)
            {
                vertexes[i*chunkSize+j] = mesh.vertices[i*chunkSize+j] - transform.position;
            }
        }
        mesh_for_collider.vertices = vertexes;
        mesh_for_collider.triangles = mesh.GetTriangleIndexes();
        mesh_for_collider.RecalculateNormals();
        coll.sharedMesh = mesh_for_collider;
    }

    public void UpdateLight()
    {
        GameObject light = GameObject.FindGameObjectWithTag("Light").gameObject;
        material.SetVector("_LightPos",light.transform.position);
        material.SetVector("_LightDir",light.transform.forward);
        material.SetFloat("_LightAmbient",1); 
    }

    public void UpdateTexture()
    {
        GameObject terrain = GameObject.Find("Terrain");
        Tex tex = terrain.GetComponent<Terrain>().textures;
        material.SetTexture("_Map",tex.map);
        material.SetFloat("_Tilling",tex.tilling);
        material.SetFloat("_BlendRate",tex.blend);
    }

    void OnRenderObject(){
        material.SetPass (0);
        if(wireframe){
            Graphics.DrawProceduralNow (MeshTopology.LineStrip, buffer.count, 1);
        }else{
            Graphics.DrawProceduralNow (MeshTopology.Triangles, buffer.count, 1);
        }
    }

    void Start()
    {
        wireframe = false;
    }

    void Update()
    {
        Ray ray = UnityEngine.Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast (ray, out hit))
        {
            Vector3 p = hit.point;
            material.SetVector("_MousePos",p/chunkSize);
        }
        if(Input.GetMouseButton(0) && editing){
            ray = UnityEngine.Camera.main.ScreenPointToRay(Input.mousePosition);

            if (Physics.Raycast (ray, out hit))
            {
                chunckClicked = true;
                Vector3 p = hit.point;
                compute.SetFloat("mouse_x",p.x);
                compute.SetFloat("mouse_z",p.z);
                compute.Dispatch(kernel,mesh.triangles.Length/3,1,1);
                compute.Dispatch(kernel_2,mesh.vertices.Length,1,1);
            }
        }
        if(Input.GetMouseButtonUp(0) && chunckClicked){
            chunckClicked = false;
            UpdateChunk();
        }
        if(Input.GetMouseButtonDown(1)){
            UpdateLight();
            UpdateSculp();
            UpdateTexture();
        }

        if(Input.GetKeyDown(KeyCode.P)){ // save terrain chunks
            XmlSerializer serializer = new XmlSerializer(typeof(Vector3[]));
            StreamWriter writer = new StreamWriter("Assets\\Terrain\\Data\\Chunk"+id+".xml");
            serializer.Serialize(writer.BaseStream, mesh.vertices);
            writer.Close();
        }
        if(Input.GetKeyDown(KeyCode.L)){ // load terrain chunks
            
            Stream stream = new MemoryStream();
            var xmlSerializer = new XmlSerializer(typeof(Vector3[]));
            
            if(Application.platform == RuntimePlatform.WindowsPlayer ) {
                TextAsset text = Resources.Load("Chunk"+id+".xml") as TextAsset;
                stream = new MemoryStream(text.bytes);//throws NullReference error
                mesh.vertices = (Vector3[]) xmlSerializer.Deserialize(stream);
                stream.Close();
            }
            else {
                if(File.Exists("Assets\\Terrain\\Data\\Chunk"+id+".xml")){
                    XmlSerializer serializer = new XmlSerializer(typeof(Vector3[]));
                    StreamReader reader = new StreamReader("Assets\\Terrain\\Data\\Chunk"+id+".xml");
                    
                    mesh.vertices = (Vector3[]) serializer.Deserialize(reader.BaseStream);
                    reader.Close();
                    mesh.Triangulate();
                    buffer.SetData(mesh.triangles);
                    vertices.SetData(mesh.vertices);

                    UpdateChunk();
                }
            }
        }
    }

    public void Unload(){
        Destroy(this.gameObject);
    }
}