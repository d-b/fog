Shader "Fog Shader/Fog"
{
    Properties {
        [Enum(Linear, 0, Exp, 1, ExpSqrd, 2)]
        _Mode ("Mode", int) = 2
        _Density ("Density", Range(0.0, 5.0)) = 0.5
        _Start ("Start", Range(0, 200)) = 0
        _End ("End", Range(0, 200)) = 10
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent+500"
        }

        Pass
        {
            Cull Off
            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            #define PM UNITY_MATRIX_P

            uniform int _Mode;
            uniform float _Density;
            uniform float _Start;
            uniform float _End;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                float4 grabPos : TEXCOORD2;
                float4 worldDirection : TEXCOORD3;
            };

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            inline float4 CalculateFrustumCorrection()
            {
                float x1 = -PM._31/(PM._11*PM._34);
                float x2 = -PM._32/(PM._22*PM._34);
                return float4(x1, x2, 0, PM._33/PM._34 + x1*PM._13 + x2*PM._23);
            }

            inline float CorrectedLinearEyeDepth(float z, float B)
            {
                return 1.0 / (z*(1/PM._34) + B);
            }

            float ComputeFog(float z)
            {
                half fog = 0.0;
                if (_Mode == 0) {
                    fog = (_End - z) / (_End - _Start);
                } else if(_Mode == 1) {
                    fog = exp2(-_Density * z);
                } else if(_Mode == 2) {
                    fog = _Density * z;
                    fog = exp2(-fog * fog);
                }
                return saturate(fog);
            }

            float ComputeLinearEyeDepth(v2f i) {
                float perspectiveDivide = 1.0f / i.vertex.w;
                float4 direction = i.worldDirection * perspectiveDivide;
                float2 screenpos = i.grabPos.xy * perspectiveDivide;
                float z = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenpos);
                return CorrectedLinearEyeDepth(z, direction.w);
            }

            v2f vert(appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.worldDirection.xyz = o.worldPos.xyz - _WorldSpaceCameraPos;
                o.worldDirection.w = dot(o.vertex, CalculateFrustumCorrection());
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float fog = 1.0 - ComputeFog(ComputeLinearEyeDepth(i));
                return half4(0, 0, 0, fog);
            }
            ENDCG
        }

    }

    CustomEditor "FogShader.GUI"
}
