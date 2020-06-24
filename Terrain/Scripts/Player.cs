using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{

    [Range(0.1f,2)]
    public float velocity;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetKey(KeyCode.W)){
            transform.position += transform.forward*velocity;
        }
        if(Input.GetKey(KeyCode.S)){
            transform.position -= transform.forward*velocity;
        }

        if(Input.GetKey(KeyCode.D)){
            transform.Rotate(0,3,0);
        }else if(Input.GetKey(KeyCode.A)){
            transform.Rotate(0,-3,0);
        }
    }
}
