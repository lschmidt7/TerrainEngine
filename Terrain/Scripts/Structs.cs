using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Structs{

    public struct Data{
        public Vector3 pos;
        public Vector3 normal;
        public Vector2 uv;
    };

    [System.Serializable]
    public struct Configuration{
        
        public int chunksWidth;
        
        public int chunksHeight;

        public int chunkSize;

        public int viwedChunks;
    };

    [System.Serializable]
    public struct Sculp{
        public bool editing;
        public float impact;
        public float area;
        public float max;
        public float min;
        public bool up;
    };

    [System.Serializable]
    public struct Tesselation{
        public Texture DispTex;
        public float TessValue;
        [Range(0,1)]
        public float DispValue;
    }

    [System.Serializable]
    public struct Tex{
        public Texture2D map;
        public float tilling;
        [Range(0,0.1f)]
        public float blend;
        public Color color;
    };

    public struct GrassPoint{
        public Vector3 pos;
        public Vector3 dir;
    };

}
