using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sphere
{

    int stepCircle;
    int stepHeight;
    Vector3 radius;
    float noise;

    Vector3[] vertexes;
    int[] triangles;
    Vector2[] uvs;

    public Sphere(int stepCircle, int stepHeight, Vector3 radius, float noise){
        this.stepCircle = stepCircle;
        this.stepHeight = stepHeight;
        this.radius = radius;
        vertexes = new Vector3[(stepCircle+1)*(stepHeight+1)];
        triangles = new int[stepCircle*stepHeight*6];
        uvs = new Vector2[(stepCircle+1)*(stepHeight+1)];
        int i=0,j;
        float incXZ = 360.0f/stepCircle;
        float incY =  180.0f/(stepHeight-1);
        for (float a = -180; a <= 180; a+=incXZ)
        {
            float angle = a*Mathf.Deg2Rad;
            float x = Mathf.Cos(angle);
            float z = Mathf.Sin(angle);
            j=0;
            for (float ay = -90; ay <= 90; ay+=incY)
            {
                angle = ay*Mathf.Deg2Rad;
                if(ay==-90){
                    angle = 90*Mathf.Deg2Rad;
                }else if(ay==90){
                    angle = -90*Mathf.Deg2Rad;
                }
                float y = Mathf.Tan(angle);
                Vector3 v = new Vector3(x,y,z).normalized;
                float r = Random.Range(1.0f,1.0f+noise);
                v.x*=radius.x*r;
                v.z*=radius.z*r;
                v.y*=radius.y;
                if(a==180){
                    vertexes[i*stepHeight+j] = vertexes[j];
                }else{
                    vertexes[i*stepHeight+j] = v;
                }
                uvs[i*stepHeight+j] = new Vector2((float)i/stepCircle,(float)j/stepHeight);
                j++;
            }
            i++;
        }

        int count=-1;
        for (i = 0; i < stepCircle; i++)
        {
            for (j = 0; j < stepHeight; j++)
            {
                triangles[++count] = i*stepHeight+j;
                triangles[++count] = i*stepHeight+j+1;
                triangles[++count] = ((i+1)*stepHeight)+j;
                
                triangles[++count] = ((i+1)*stepHeight)+j;
                triangles[++count] = i*stepHeight+j+1;
                triangles[++count] = ((i+1)*stepHeight)+j+1;
            }
        }
    }

    public Vector3[] getVertex(){
        return vertexes;
    }

    public int[] getTriangles(){
        return triangles;
    }

    public Vector2[] getUvs(){
        return uvs;
    }

}
