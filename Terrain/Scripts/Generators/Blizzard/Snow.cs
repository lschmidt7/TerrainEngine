using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Snow : MonoBehaviour {

	private ComputeBuffer buffer;

	public Material m;

	public Vector2 size;

	float time=0f;

	[Range(10,100)]
	public int startHeight;

	[Range(1,60000)]
	public int snowAmount = 1;

	Vector3[] flakes;

	public float _Velocity=1.0f;

	void Start () {
		buffer = new ComputeBuffer (snowAmount,12);
		flakes = new Vector3[snowAmount];
		Vector3 pos;
		for(int i=0;i<snowAmount;i++){
			pos.y = startHeight*Random.Range(0,1f);
			pos.x = size.x * Random.Range(-1f,1f);
			pos.z = size.y * Random.Range(-1f,1f);
			flakes[i] = pos;

		}
		buffer.SetData (flakes);
		m.SetBuffer ("buffer",buffer);
		m.SetFloat("_StartHeight",startHeight);
	}

	void OnRenderObject(){

		m.SetPass (0);
		Graphics.DrawProceduralNow (MeshTopology.Points,buffer.count,1);
	}

	void Update () {
		
	}
}
