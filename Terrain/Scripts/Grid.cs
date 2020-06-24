using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grid
{
    
    Vector2 size;

    public struct Quad{
        public int id;
        public Vector3 pos;
        public Vector2 center;
        public bool visible;
    };

    Quad[,] grid;

    public List<int> criar = new List<int>();
    public List<int> destruir = new List<int>();

    // size is the amount of chunks
    public Grid(Vector2 size, int chunkSize){
        this.size = size;
        Vector2 iniPos = new Vector2(chunkSize/2,chunkSize/2);
        grid = new Quad[(int)size.x,(int)size.y];
        int id=0;
        for (int i = 0; i < size.x; i++)
        {
            for (int j = 0; j < size.y; j++)
            {
                grid[i,j].id = id;
                grid[i,j].pos = new Vector3(i*(chunkSize-1),0,j*(chunkSize-1));
                grid[i,j].center = new Vector2(iniPos.x+i*chunkSize,iniPos.y+j*chunkSize);
                grid[i,j].visible = false;
                id++;
            }
        }
    }

    public List<Quad> GetChunks(List<int> ids){
        List<Quad> chunks = new List<Quad>();
        for (int i = 0; i < size.x; i++)
        {
            for (int j = 0; j < size.y; j++)
            {
                if(ids.Contains(grid[i,j].id)){
                    chunks.Add(grid[i,j]);
                }
            }
        }
        return chunks;
    }

    public void Diff(List<int> newVisible,List<int> currentVisible){
        criar.Clear();
        destruir.Clear();
        List<int> difference = new List<int>();
        foreach (int id in newVisible)
        {
            if(!currentVisible.Contains(id)){
                criar.Add(id);
            }
        }
        foreach (int id in currentVisible)
        {
            if(!newVisible.Contains(id)){
                destruir.Add(id);
            }
        }
    }

    public List<int> GetVisibleChunksIds(Vector3 playerPosition, float threshold ){
        List<int> idsVisible = new List<int>();
        for (int i = 0; i < size.x; i++)
        {
            for (int j = 0; j < size.y; j++)
            {
                float dist = Vector3.Distance(grid[i,j].center,new Vector3(playerPosition.x,playerPosition.z));
                grid[i,j].visible = false;
                if(dist<threshold){
                    grid[i,j].visible = true;
                    idsVisible.Add(grid[i,j].id);
                }else{
                    grid[i,j].visible = false;
                }
            }
        }
        return idsVisible;
    }

}
