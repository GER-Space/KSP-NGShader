Shader "ShaderNG/TypeA"
{
	Properties
	{
		[Header(Texture Maps)]
	_MainTex("_MainTex (RGB spec(A))", 2D) = "gray" {}
	_BumpMap("_BumpMap", 2D) = "bump" {}
	_Color("_Color", Color) = (1,1,1,1)
		[Header(Shininess)]
	_SpecColor("_SpecColor", Color) = (0.5, 0.5, 0.5, 1)
		[Header(Emissive)]
	_Emissive("_Emissive (RGB)", 2D) = "white" {}
	_EmissiveColor("_EmissiveColor", Color) = (0,0,0,1)
		[Header(Effects)]
	_Opacity("_Opacity", Range(0,1)) = 1
		_RimFalloff("_RimFalloff", Range(0.01,5)) = 0.1
		_RimColor("_RimColor", Color) = (0,0,0,0)
		_TemperatureColor("_TemperatureColor", Color) = (0,0,0,0)
		_BurnColor("Burn Color", Color) = (1,1,1,1)
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM

#pragma surface surf BlinnPhongSmooth keepalpha
#pragma target 3.0

		sampler2D _MainTex;
	sampler2D _BumpMap;

	float4 _EmissiveColor;
	sampler2D _Emissive;

	float _Opacity;
	float _RimFalloff;
	float4 _RimColor;
	float4 _TemperatureColor;
	float4 _BurnColor;
	float4 _Color;


	struct Input
	{
		float2 uv_MainTex;
		float2 uv_BumpMap;
		float2 uv_Emissive;
		float3 viewDir;
		INTERNAL_DATA
	};

	inline fixed4 LightingBlinnPhongSmooth(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
	{
		s.Normal = normalize(s.Normal);
		half3 h = normalize(lightDir + viewDir);

		fixed diff = max(0, dot(s.Normal, lightDir));

		float nh = max(0, dot(s.Normal, h));
		float spec = pow(nh, s.Specular*128.0) * s.Gloss * s.Alpha;

		fixed4 c;
		c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * (_SpecColor.rgb + s.Albedo.rgb) / 2 * spec) * (atten);
		c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
		return c;
	}

	float4 _LocalCameraPos;
	float4 _LocalCameraDir;


	void surf(Input IN, inout SurfaceOutput o)
	{
		float4 color = tex2D(_MainTex,(IN.uv_MainTex)) * _BurnColor * _Color;
		float4 emissive = tex2D(_Emissive, (IN.uv_Emissive));
		//float4 reftint = tex2D(_ReflectionMask, (IN.uv_ReflectionMask));
		float3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

		half rim = 1.0 - saturate(dot(normalize(IN.viewDir), normal));

		float3 emission = (_RimColor.rgb * pow(rim, _RimFalloff)) * _RimColor.a;
		emission += _TemperatureColor.rgb * _TemperatureColor.a;
		emission += (emissive.rgb * _EmissiveColor.rgb) * _EmissiveColor.a;

		//float4 fog = UnderwaterFog(IN.worldPos, color);

		o.Albedo = color.rgb;
		//o.Emission = emission;
		o.Gloss = color.a;
		o.Specular = max(0.01, color.a);
		o.Normal = normal;

		//reflcol *= color.a;
		//o.Emission = emission + (reflcol.rgb  * color.a);
		o.Emission = emission;

		o.Emission *= _Opacity * emissive.a;
		o.Alpha = _Opacity * emissive.a;

	}
	ENDCG
	}
		Fallback "Diffuse"
}