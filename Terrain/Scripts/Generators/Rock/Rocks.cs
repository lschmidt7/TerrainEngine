using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rocks : MonoBehaviour
{
    public Material rockMaterial;

    [Range(0,50)]
    public int amount;

    public Vector2 size;

    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < amount; i++)
        {
            Vector3 p = new Vector3(Random.Range(size.x,size.y),0,Random.Range(size.x,size.y));
            GameObject rock = new GameObject("rock");
            rock.transform.position = p;
            rock.AddComponent<Rock>().Create(rockMaterial,8,8,new Vector3(4,3,4),Color.grey,0.5f);
            rock.transform.parent = transform;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
