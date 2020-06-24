using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Structs;
using System;

[Serializable]
public class MeshGen : MonoBehaviour
{
    int size;

    public Vector3[] vertices;
    public Data[] triangles;

    public MeshGen(Vector3 position, int size,int step){
        Grid(position,size,step);
        Triangulate();
    }

    public void Grid(Vector3 position, int size,int step){
        this.size = (size/step);
        vertices = new Vector3[(size/step)*(size/step)];
        triangles = new Data[((size-1)*(size-1)*6)];
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                vertices[i*size+j] = new Vector3((i*step)+position.x,0,(j*step)+position.z);
            }
        }
    }

    public void SetHeights(Color[] heigthMap, float scale){
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                vertices[i*size+j].y = heigthMap[j*size+i].g*scale;
            }
        }
    }

    public void SetHeights(Data[,] heigthMap, float scale){
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                vertices[i*size+j].y = heigthMap[i,j].pos.y*scale;
            }
        }
    }

    public void SetHeights(Texture2D heigthMap, float scale){
        for (int i = 0; i < size; i++)
        {
            for (int j = 0; j < size; j++)
            {
                vertices[i*size+j].y = heigthMap.GetPixel(i,j).g*scale;
            }
        }
    }

    public void Triangulate(){
		int count = -1;
		for (int i = 0; i < size-1; i++) {
			for (int j = 0; j < size-1; j++) {
                triangles[++count].pos = vertices[i*size+j];
                triangles[++count].pos = vertices[i*size+j+1];
                triangles[++count].pos = vertices[(i+1)*size+j];

                triangles[++count].pos = vertices[(i+1)*size+j];
                triangles[++count].pos = vertices[i*size+j+1];
                triangles[++count].pos = vertices[(i+1)*size+j+1];
			}
		}
    }

    public int[] GetTriangleIndexes(){
        int[] trianglesIndexes = new int[(size-1)*(size-1)*6];
		int count = -1;
		for (int i = 0; i < size-1; i++) {
			for (int j = 0; j < size-1; j++) {
                trianglesIndexes[++count] = i*size+j;
                trianglesIndexes[++count] = i*size+j+1;
                trianglesIndexes[++count] = (i+1)*size+j;

                trianglesIndexes[++count] = (i+1)*size+j;
                trianglesIndexes[++count] = i*size+j+1;
                trianglesIndexes[++count] = (i+1)*size+j+1;
			}
		}
        return trianglesIndexes;
    }

    public void SetNormals(Vector3[] normals){
        int count=-1;
        for (int i = 0; i < size-1; i++) {
			for (int j = 0; j < size-1; j++) {
                triangles[++count].normal = normals[i*size+j];
                triangles[++count].normal = normals[i*size+j+1];
                triangles[++count].normal = normals[(i+1)*size+j];

                triangles[++count].normal = normals[(i+1)*size+j];
                triangles[++count].normal = normals[i*size+j+1];
                triangles[++count].normal = normals[(i+1)*size+j+1];
			}
		}
    }

    public void CalculateUV(float tilling){
        for (int i = 0; i < triangles.Length; i++)
        {
            Vector3 pos = triangles[i].pos;
            triangles[i].uv = new Vector2((pos.x*tilling)/size,(pos.z*tilling)/size);
        }
    }

    public void CalculateNormals(){
        for (int i = 0; i < triangles.Length; i+=3)
        {
            Vector3 v = triangles[i+1].pos - triangles[i].pos;
            Vector3 u = triangles[i+2].pos - triangles[i].pos;
            Vector3 n = Vector3.Normalize(Vector3.Cross(u,v));
            triangles[i].normal = n;
            triangles[i+1].normal = n;
            triangles[i+2].normal = n;
        }
    }
}
