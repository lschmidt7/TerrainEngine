using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Structs;

public class Terrain : MonoBehaviour
{
    public Transform player;

    [Range(100,420)]
    public float VisibleThreshold;

    public Texture2D heightMap;
    public float scale;

    public Configuration config;

    public Shader shader;

    public ComputeShader compute;

    public Sculp sculp;

    public Tesselation tesselation;

    public Tex textures;

    Grid grid;

    // Start is called before the first frame update

    List<GameObject> chunks = new List<GameObject>();

    public void CreateChunk(Vector3 pos, int id){
        GameObject chunk = new GameObject("chunk");
        chunks.Add(chunk);
        chunk.transform.position = pos;
        chunk.transform.parent = transform;
        Chunk chunkScript = chunk.AddComponent<Chunk>();
        chunkScript.SetShader(shader,compute);
        chunkScript.Create(config.chunkSize,id,new Vector2(pos.x,pos.z));
        chunkScript.UpdateSculp();
        chunkScript.UpdateTexture();
        chunkScript.UpdateLight();
        chunkScript.SetHeight(heightMap,scale);
        chunkScript.UpdateChunk();
    }

    public void UpdateChunks(List<Grid.Quad> criar, List<int> destruir){

        List<GameObject> unloadList = new List<GameObject>();
        foreach (GameObject chunk in chunks)
        {
            int id = chunk.GetComponent<Chunk>().GetId();
            if(destruir.Contains(id)){
                unloadList.Add(chunk);
            }
        }
        foreach (GameObject chunk in unloadList)
        {
            chunks.Remove(chunk);
            chunk.GetComponent<Chunk>().Unload();
        }

        foreach (Grid.Quad quad in criar)
        {
            CreateChunk(quad.pos,quad.id);
        }
    }

    void Start()
    {
        grid = new Grid(new Vector2(config.chunksWidth,config.chunksHeight),config.chunkSize);
        List<int> idsVisible = grid.GetVisibleChunksIds(player.position,VisibleThreshold);
        List<Grid.Quad> quads = grid.GetChunks(idsVisible);
        
        textures.tilling = config.chunksWidth;
        float x = config.chunksWidth*config.chunkSize;
        float y = config.chunksHeight*config.chunkSize;
        transform.position = new Vector3(x/2-1,0,y/2-1);
        transform.localScale = new Vector3(x/10.2f,1,y/10.2f);

        foreach (Grid.Quad quad in quads)
        {
            CreateChunk(quad.pos,quad.id);
        }
    }

    List<int> GetCurrentVisibleIds(){
        List<int> ids = new List<int>();
        foreach (GameObject chunk in chunks)
        {
            ids.Add(chunk.GetComponent<Chunk>().GetId());
        }
        return ids;
    }

    void Update(){
        List<int> newVisibles = grid.GetVisibleChunksIds(player.position,VisibleThreshold);
        grid.Diff(newVisibles,GetCurrentVisibleIds());
        List<Grid.Quad> quadsToCreate = grid.GetChunks(grid.criar);
        UpdateChunks(quadsToCreate,grid.destruir);
    }

}