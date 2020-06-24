using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Structs;

public class Grass : MonoBehaviour
{

    public Texture2D map; // definition where grass can be put
    public Texture2D heigthMap;
    

    [Range(1,5000)]
    public int amount;
    public Vector2 size;
    public float offset;
    ComputeBuffer grassBuffer;

    GrassPoint[] points;

    Material material;

    // Start is called before the first frame update
    void Start()
    {

        material = GetComponent<Renderer>().material;

        points  = new GrassPoint[amount];
        int i=0;
        while(i<amount)
        {
            GrassPoint g;
            g.pos = new Vector3(Random.Range(size.x,size.y),0,Random.Range(size.x,size.y));
            float h = heigthMap.GetPixel((int)g.pos.x,(int)g.pos.z).r;
            g.pos.y = h*20;

            g.dir = new Vector3(Random.Range(-1f,1f),0,Random.Range(-1f,1f)).normalized;

            int tx = (int) (map.width*g.pos.x/size.y);
            int ty = (int) (map.height*g.pos.z/size.y);

            Color c = map.GetPixel(tx,ty);
            if(c.g > 0.9f && c.b < 0.5f && c.b < 0.5f){
                points[i] = g;
                i++;
            }
        }

        grassBuffer = new ComputeBuffer(amount,24);
        grassBuffer.SetData(points);
        material.SetBuffer("buffer",grassBuffer);
    }

    void OnRenderObject(){
        material.SetPass (0);
        Graphics.DrawProceduralNow (MeshTopology.Points, grassBuffer.count, 1);
    }
}
