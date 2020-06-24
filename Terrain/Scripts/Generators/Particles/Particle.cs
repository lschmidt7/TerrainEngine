using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Particle : MonoBehaviour
{

    Material material;

    [Range(1,100)]
    public int numPoints;

    [Range(0.2f,4f)]
    public float density;

    [Range(0.1f,10)]
    public float flowVelocity;

    [Range(0.01f,0.5f)]
    public float particleSize;

    float densityChange;
    float numPointsChange;
    float flowVelocityChange;
    float particleSizeChange;
    

    void Generate(){
        material = GetComponent<MeshRenderer>().material;
        material.SetInt("_NumOfPoints",numPoints);
        material.SetFloat("_FlowVelocity",flowVelocity);
        material.SetFloat("_CircleSize",particleSize);
        Vector3[] points = new Vector3[numPoints];
        ComputeBuffer buffer = new ComputeBuffer(numPoints,sizeof(float)*3);
        for (int i = 0; i < numPoints; i++)
        {
            Vector3 pos = new Vector3(Random.Range(-density,density),Random.Range(-2*density,density),Random.Range(-density,density));
            points[i]=pos+transform.position;
        }
        buffer.SetData(points);
        material.SetBuffer("points",buffer);
        material.SetPass(0);
    }

    // Start is called before the first frame update
    void Start()
    {   
        numPointsChange = numPoints;
        densityChange = density;
        flowVelocityChange = flowVelocity;
        particleSizeChange = particleSize;
        Generate();
    }

    // Update is called once per frame
    void Update()
    {
        if(density!=densityChange || numPoints!=numPointsChange || flowVelocity!=flowVelocityChange || particleSize!=particleSizeChange){
            Generate();
            densityChange=density;
            numPointsChange = numPoints;
            flowVelocityChange = flowVelocity;
            particleSizeChange = particleSize;
        }
    }
}
