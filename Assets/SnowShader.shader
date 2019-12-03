// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/SnowShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Cull Off ZWrite Off ZTest Always
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent-10" }

		//Pass // 1 render screen space shadows
		//{
		//	CGPROGRAM

		//	float4 GetViewSpacePosition(float2 coord)
		//	{
		//		float depth = fixDepth(_MainTex.SampleLevel(sampler_MainTex, coord.xy, 0));

		//		float4 viewPosition = mul(ProjectionMatrixInverse, float4(coord.x * 2.0 - 1.0, coord.y * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0));
		//		viewPosition /= viewPosition.w;

		//		return viewPosition;
		//	}

		//	float3 ProjectBack(float4 viewPos)
		//	{
		//		viewPos = mul(ProjectionMatrix, float4(viewPos.xyz, 0.0));
		//		viewPos.xyz /= viewPos.w;
		//		viewPos.xyz = viewPos.xyz * 0.5 + 0.5;
		//		return viewPos.xyz;
		//	}

		//	float rand(float2 coord)
		//	{
		//		return saturate(frac(sin(dot(coord, float2(12.9898, 78.223))) * 43758.5453));
		//	}
		//	ENDCG
		//}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			float4x4 _ViewProjectInverse;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float3 worldDirection : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				float4 D = mul(_ViewProjectInverse, float4((v.uv.x) * 2 - 1, (v.uv.y) * 2 - 1, 0.5, 1));
				D.xyz /= D.w;
				D.xyz -= _WorldSpaceCameraPos;
				float4 D0 = mul(_ViewProjectInverse, float4(0, 0, 0.5, 1));
				D0.xyz /= D0.w;
				D0.xyz -= _WorldSpaceCameraPos;
				o.worldDirection = D.xyz / length(D0.xyz);

				return o;
            }

			sampler2D _MainTex;
			sampler2D _CameraDepthNormalsTexture;
			float4x4 _CamToWorld;

			sampler2D _SnowTex;
			float _SnowTexScale;
			float _DepthLimit;

			float _ShadowAmount;

			fixed _BottomThreshold;
			fixed _TopThreshold;

			sampler2D _ShadowTex;

			half4 frag(v2f i) : SV_Target
			{
				half3 normal;
				float depth;

				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
				normal = mul((float3x3)_CamToWorld, normal);

				half snowAmount = dot(float3(0, 1, 0), normal);
				half scale = (_BottomThreshold + 1 - _TopThreshold) / 1 + 1;
				snowAmount = saturate((snowAmount - _BottomThreshold) * scale);

				float3 WD = i.worldDirection * depth;
				float3 W = WD + _WorldSpaceCameraPos / _ProjectionParams.z;
				W *= _SnowTexScale * _ProjectionParams.z;

				half4 col = tex2D(_MainTex, i.uv);
				half4 shad = lerp(half4(1, 1, 1, 1), tex2D(_ShadowTex, i.uv), _ShadowAmount);

				half4 snowColor = tex2D(_SnowTex, W.xz) * shad;

				if (depth < _DepthLimit) {
					return lerp(col, snowColor, snowAmount);
				} else {
					col.a = 0;
					return col;
				}
			}
            ENDCG
        }
    }
}
