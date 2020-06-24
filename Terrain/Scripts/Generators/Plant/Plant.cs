using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Plant : MonoBehaviour
{

    public Material material;

    [Range(1,10)]
    public int leafs;

    public AnimationCurve curve;

    public int smooth;

    Vector3[] points;

    [Range(1,10)]
    public float thickness=1.2f;

    

    Vector3[] RotateCurve(float angle){
        Vector3[] newPoints = (Vector3[]) points.Clone();
        for (int i = 0; i < points.Length; i++)
        {
            float mag = Vector3.Distance(new Vector3(0,points[i].y,0),points[i]);
            Vector3 newPoint = new Vector3(Mathf.Cos(angle)*mag,points[i].y,Mathf.Sin(angle)*mag);
            newPoints[i] = newPoint;
        }
        return newPoints;
    }

    void CreateLeafs(){
        float angle = 0;
        for (int i = 0; i < leafs; i++)
        {
            Vector3[] newPoints = RotateCurve(angle);
            GameObject leaf = new GameObject("Leaf");
            leaf.transform.parent = transform;
            Leaf leafScript = leaf.AddComponent<Leaf>();
            leafScript.Init(newPoints,smooth,thickness,material);
            angle += ((2f*Mathf.PI)/leafs);
        }
    }


    // Start is called before the first frame update
    void Start()
    {
        points = new Vector3[smooth];
        float jump = 1f/smooth;
        for (int i = 0; i < smooth; i++)
        {
            float v = curve.Evaluate(i*jump);
            points[i] = new Vector3(i*jump,v,0);
        }
        CreateLeafs();
    }
}