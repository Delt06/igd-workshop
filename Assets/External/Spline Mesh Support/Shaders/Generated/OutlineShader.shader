﻿// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

Shader "OutlineShader"
{
	Properties
	{
		[TCP2HeaderHelp(Base)]
		_BaseColor ("Color", Color) = (1,1,1,1)
		[TCP2ColorNoAlpha] _HColor ("Highlight Color", Color) = (0.75,0.75,0.75,1)
		[TCP2ColorNoAlpha] _SColor ("Shadow Color", Color) = (0.2,0.2,0.2,1)
		_BaseMap ("Albedo", 2D) = "white" {}
		[TCP2Separator]

		[TCP2Header(Ramp Shading)]
		
		_RampThreshold ("Threshold", Range(0.01,1)) = 0.5
		_RampSmoothing ("Smoothing", Range(0.001,1)) = 0.1
		[TCP2Separator]

		[TCP2HeaderHelp(Emission)]
		[TCP2ColorNoAlpha] [HDR] _Emission ("Emission Color", Color) = (0,0,0,1)
		[TCP2Separator]
		
		[TCP2HeaderHelp(Rim Outline)]
		[TCP2ColorNoAlpha] _RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.5)
		_RimMin ("Rim Min", Range(0,2)) = 0.5
		_RimMax ("Rim Max", Range(0,2)) = 1
		[TCP2Separator]
		
		[TCP2HeaderHelp(Normal Mapping)]
		[NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" {}
		[TCP2Separator]
		[HideInInspector] __BeginGroup_ShadowHSV ("Shadow Line", Float) = 0
		_ShadowLineThreshold ("Threshold", Range(0,1)) = 0.5
		_ShadowLineSmoothing ("Smoothing", Range(0.001,0.1)) = 0.015
		_ShadowLineStrength ("Strength", Float) = 1
		_ShadowLineColor ("Color (RGB) Opacity (A)", Color) = (0,0,0,1)
		[HideInInspector] __EndGroup ("Shadow Line", Float) = 0
		
		[TCP2HeaderHelp(Outline)]
		_OutlineWidth ("Width", Range(0.1,4)) = 1
		_OutlineColorVertex ("Color", Color) = (0,0,0,1)
		//This property will be ignored and will draw the custom normals GUI instead
		[TCP2OutlineNormalsGUI] __outline_gui_dummy__ ("_unused_", Float) = 0
		[TCP2Separator]

		[ToggleOff(_RECEIVE_SHADOWS_OFF)] _ReceiveShadowsOff ("Receive Shadows", Float) = 1

		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType"="Opaque"
		}

		HLSLINCLUDE
		#define fixed half
		#define fixed2 half2
		#define fixed3 half3
		#define fixed4 half4

		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
		
		// Cubic pulse function
		// Adapted from: http://www.iquilezles.org/www/articles/functions/functions.htm (c) 2017 - Inigo Quilez - MIT License
		float linearPulse(float c, float w, float x)
		{
			x = abs(x - c);
			if (x > w)
			{
				return 0;
			}
			x /= w;
			return 1 - x;
		}
		
		// Built-in renderer (CG) to SRP (HLSL) bindings
		#define UnityObjectToClipPos TransformObjectToHClip
		#define _WorldSpaceLightPos0 _MainLightPosition
		
		ENDHLSL

		// Outline Include
		HLSLINCLUDE
		
		// Shader Properties
		float _OutlineWidth;
		fixed4 _OutlineColorVertex;
		sampler2D _BumpMap;
		sampler2D _BaseMap;
		float4 _BaseMap_ST;
		fixed4 _BaseColor;
		half4 _Emission;
		float _RampThreshold;
		float _RampSmoothing;
		float _ShadowLineThreshold;
		float _ShadowLineStrength;
		float _ShadowLineSmoothing;
		fixed4 _ShadowLineColor;
		float _RimMin;
		float _RimMax;
		fixed4 _RimColor;
		fixed4 _SColor;
		fixed4 _HColor;

		struct appdata_outline
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		#if TCP2_COLORS_AS_NORMALS
			float4 vertexColor : COLOR;
		#endif
		// TODO: need a way to know if texcoord1 is used in the Shader Properties
		#if TCP2_UV2_AS_NORMALS
			float2 uv2 : TEXCOORD1;
		#endif
			float4 tangent : TANGENT;
			UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		struct v2f_outline
		{
			float4 vertex : SV_POSITION;
			float4 vcolor : TEXCOORD0;
			float3 pack1 : TEXCOORD1; /* pack1.xyz = worldPos */
			UNITY_VERTEX_INPUT_INSTANCE_ID
			UNITY_VERTEX_OUTPUT_STEREO
		};

		v2f_outline vertex_outline (appdata_outline v)
		{
			v2f_outline output = (v2f_outline)0;

			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_TRANSFER_INSTANCE_ID(v, output);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			// Shader Properties Sampling
			float __outlineWidth = ( _OutlineWidth );
			float4 __outlineColorVertex = ( _OutlineColorVertex.rgba );

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			output.pack1.xyz = worldPos;
		
		#ifdef TCP2_COLORS_AS_NORMALS
			//Vertex Color for Normals
			float3 normal = (v.vertexColor.xyz*2) - 1;
		#elif TCP2_TANGENT_AS_NORMALS
			//Tangent for Normals
			float3 normal = v.tangent.xyz;
		#elif TCP2_UV2_AS_NORMALS
			//UV2 for Normals
			float3 n;
			//unpack uv2
			v.uv2.x = v.uv2.x * 255.0/16.0;
			n.x = floor(v.uv2.x) / 15.0;
			n.y = frac(v.uv2.x) * 16.0 / 15.0;
			//- get z
			n.z = v.uv2.y;
			//- transform
			n = n*2 - 1;
			float3 normal = n;
		#else
			float3 normal = v.normal;
		#endif
			float size = 1;
		
		#if !defined(SHADOWCASTER_PASS)
			output.vertex = UnityObjectToClipPos(v.vertex.xyz + normal * __outlineWidth * size * 0.01);
		#else
			v.vertex = v.vertex + float4(normal,0) * __outlineWidth * size * 0.01;
		#endif
		
			output.vcolor.xyzw = __outlineColorVertex;
			return output;
		}

		float4 fragment_outline (v2f_outline input) : SV_Target
		{
			UNITY_SETUP_INSTANCE_ID(input);
			UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

			// Shader Properties Sampling
			float4 __outlineColor = ( float4(1,1,1,1) );

			half4 outlineColor = __outlineColor * input.vcolor.xyzw;
			return outlineColor;
		}

		ENDHLSL
		// Outline Include End
		Pass
		{
			Name "Main"
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM
			// Required to compile gles 2.0 with standard SRP library
			// All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 3.0

			// -------------------------------------
			// Material keywords
			//#pragma shader_feature _ALPHATEST_ON
			#pragma shader_feature _ _RECEIVE_SHADOWS_OFF

			// -------------------------------------
			// Universal Render Pipeline keywords
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

			// -------------------------------------

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing

			#pragma vertex Vertex
			#pragma fragment Fragment

			// Uniforms
			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END

			// vertex input
			struct Attributes
			{
				float4 vertex       : POSITION;
				float3 normal       : NORMAL;
				float4 tangent      : TANGENT;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			// vertex output / fragment input
			struct Varyings
			{
				float4 positionCS     : SV_POSITION;
				float3 normal         : NORMAL;
				float4 worldPosAndFog : TEXCOORD0;
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord    : TEXCOORD1; // compute shadow coord per-vertex for the main light
			#endif
			#ifdef _ADDITIONAL_LIGHTS_VERTEX
				half3 vertexLights : TEXCOORD2;
			#endif
				float3 pack0 : TEXCOORD3; /* pack0.xyz = tangent */
				float3 pack1 : TEXCOORD4; /* pack1.xyz = bitangent */
				float2 pack2 : TEXCOORD5; /* pack2.xy = texcoord0 */
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Varyings Vertex(Attributes input)
			{
				Varyings output = (Varyings)0;

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				// Texture Coordinates
				output.pack2.xy.xy = input.texcoord0.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				output.shadowCoord = GetShadowCoord(vertexInput);
			#endif

				VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normal, input.tangent);
			#ifdef _ADDITIONAL_LIGHTS_VERTEX
				// Vertex lighting
				output.vertexLights = VertexLighting(vertexInput.positionWS, vertexNormalInput.normalWS);
			#endif

				// world position
				output.worldPosAndFog = float4(vertexInput.positionWS.xyz, 0);

				// normal
				output.normal = NormalizeNormalPerVertex(vertexNormalInput.normalWS);

				// tangent
				output.pack0.xyz = vertexNormalInput.tangentWS;
				output.pack1.xyz = vertexNormalInput.bitangentWS;

				// clip position
				output.positionCS = vertexInput.positionCS;

				return output;
			}

			half4 Fragment(Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				float3 positionWS = input.worldPosAndFog.xyz;
				float3 normalWS = NormalizeNormalPerPixel(input.normal);
				half3 viewDirWS = SafeNormalize(GetCameraPositionWS() - positionWS);
				half3 tangentWS = input.pack0.xyz;
				half3 bitangentWS = input.pack1.xyz;
				half3x3 tangentToWorldMatrix = half3x3(tangentWS.xyz, bitangentWS.xyz, normalWS.xyz);

				// Shader Properties Sampling
				float4 __normalMap = ( tex2D(_BumpMap, input.pack2.xy.xy).rgba );
				float4 __albedo = ( tex2D(_BaseMap, input.pack2.xy.xy).rgba );
				float4 __mainColor = ( _BaseColor.rgba );
				float __alpha = ( __albedo.a * __mainColor.a );
				float __ambientIntensity = ( 1.0 );
				float3 __emission = ( _Emission.rgb );
				float __rampThreshold = ( _RampThreshold );
				float __rampSmoothing = ( _RampSmoothing );
				float __shadowLineThreshold = ( _ShadowLineThreshold );
				float __shadowLineStrength = ( _ShadowLineStrength );
				float __shadowLineSmoothing = ( _ShadowLineSmoothing );
				float4 __shadowLineColor = ( _ShadowLineColor.rgba );
				float __rimMin = ( _RimMin );
				float __rimMax = ( _RimMax );
				float3 __rimColor = ( _RimColor.rgb );
				float __rimStrength = ( 1.0 );
				float3 __shadowColor = ( _SColor.rgb );
				float3 __highlightColor = ( _HColor.rgb );

				// Normal Mapping
				half4 normalMap = __normalMap;
				half3 normalTS = UnpackNormal(normalMap);
				normalWS = mul(normalTS, tangentToWorldMatrix);

				half ndv = max(0, dot(viewDirWS, normalWS));
				half ndvRaw = ndv;

				// main texture
				half3 albedo = __albedo.rgb;
				half alpha = __alpha;
				half3 emission = half3(0,0,0);
				
				albedo *= __mainColor.rgb;

				// main light: direction, color, distanceAttenuation, shadowAttenuation
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord = input.shadowCoord;
			#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
				float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
			#else
				float4 shadowCoord = float4(0, 0, 0, 0);
			#endif
				Light mainLight = GetMainLight(shadowCoord);

				// ambient or lightmap
				// Samples SH fully per-pixel. SampleSHVertex and SampleSHPixel functions
				// are also defined in case you want to sample some terms per-vertex.
				half3 bakedGI = SampleSH(normalWS);
				half occlusion = 1;
				half3 indirectDiffuse = bakedGI;
				indirectDiffuse *= occlusion * albedo * __ambientIntensity;
				emission += __emission;

				half3 lightDir = mainLight.direction;
				half3 lightColor = mainLight.color.rgb;
				half atten = mainLight.shadowAttenuation * mainLight.distanceAttenuation;

				half ndl = dot(normalWS, lightDir);
				half3 ramp;
				
				half rampThreshold = __rampThreshold;
				half rampSmooth = __rampSmoothing * 0.5;
				ndl = saturate(ndl);
				ramp = smoothstep(rampThreshold - rampSmooth, rampThreshold + rampSmooth, ndl);

				// apply attenuation
				ramp *= atten;

				//Shadow Line
				float ndlAtten = ndl * atten;
				float shadowLineThreshold = __shadowLineThreshold;
				float shadowLineStrength = __shadowLineStrength;
				float shadowLineSmoothing = __shadowLineSmoothing;
				float shadowLine = min(linearPulse(ndlAtten, shadowLineSmoothing, shadowLineThreshold) * shadowLineStrength, 1.0);
				half4 shadowLineColor = __shadowLineColor;
				ramp = lerp(ramp.rgb, shadowLineColor.rgb, shadowLine * shadowLineColor.a);
				half3 color = half3(0,0,0);
				// Rim Outline
				half rim = 1 - ndvRaw;
				rim = ( rim );
				half rimMin = __rimMin;
				half rimMax = __rimMax;
				rim = smoothstep(rimMin, rimMax, rim);
				half3 rimColor = __rimColor;
				half rimStrength = __rimStrength;
				albedo.rgb = lerp(albedo.rgb, rimColor, rim * rimStrength);
				half3 accumulatedRamp = ramp * max(lightColor.r, max(lightColor.g, lightColor.b));
				half3 accumulatedColors = ramp * lightColor.rgb;

				// Additional lights loop
			#ifdef _ADDITIONAL_LIGHTS
				uint additionalLightsCount = GetAdditionalLightsCount();
				for (uint lightIndex = 0u; lightIndex < additionalLightsCount; ++lightIndex)
				{
					Light light = GetAdditionalLight(lightIndex, positionWS);
					half atten = light.shadowAttenuation * light.distanceAttenuation;
					half3 lightDir = light.direction;
					half3 lightColor = light.color.rgb;

					half ndl = dot(normalWS, lightDir);
					half3 ramp;
					
					ndl = saturate(ndl);
					ramp = smoothstep(rampThreshold - rampSmooth, rampThreshold + rampSmooth, ndl);

					// apply attenuation (shadowmaps & point/spot lights attenuation)
					ramp *= atten;

					//Shadow Line
					float ndlAtten = ndl * atten;
					float shadowLineThreshold = __shadowLineThreshold;
					float shadowLineStrength = __shadowLineStrength;
					float shadowLineSmoothing = __shadowLineSmoothing;
					float shadowLine = min(linearPulse(ndlAtten, shadowLineSmoothing, shadowLineThreshold) * shadowLineStrength, 1.0);
					half4 shadowLineColor = __shadowLineColor;
					ramp = lerp(ramp.rgb, shadowLineColor.rgb, shadowLine * shadowLineColor.a);
					accumulatedRamp += ramp * max(lightColor.r, max(lightColor.g, lightColor.b));
					accumulatedColors += ramp * lightColor.rgb;

				}
			#endif
			#ifdef _ADDITIONAL_LIGHTS_VERTEX
				color += input.vertexLights * albedo;
			#endif

				accumulatedRamp = saturate(accumulatedRamp);
				half3 shadowColor = (1 - accumulatedRamp.rgb) * __shadowColor;
				accumulatedRamp = accumulatedColors.rgb * __highlightColor + shadowColor;
				color += albedo * accumulatedRamp;

				// apply ambient
				color += indirectDiffuse;

				color += emission;

				return half4(color, alpha);
			}
			ENDHLSL
		}

		//Outline
		Pass
		{
			Name "Outline"
			Cull Front

			HLSLPROGRAM
			#pragma vertex vertex_outline
			#pragma fragment fragment_outline
			#pragma target 3.0
			#pragma multi_compile TCP2_NONE TCP2_COLORS_AS_NORMALS TCP2_TANGENT_AS_NORMALS TCP2_UV2_AS_NORMALS
			#pragma multi_compile_instancing
			ENDHLSL
		}
		// Depth & Shadow Caster Passes
		HLSLINCLUDE
		#if defined(SHADOW_CASTER_PASS) || defined(DEPTH_ONLY_PASS)

			#define fixed half
			#define fixed2 half2
			#define fixed3 half3
			#define fixed4 half4

			float3 _LightDirection;

			CBUFFER_START(UnityPerMaterial)
			CBUFFER_END

			struct Attributes
			{
				float4 vertex   : POSITION;
				float3 normal   : NORMAL;
				float4 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float4 positionCS     : SV_POSITION;
				float3 normal         : NORMAL;
				float3 pack0 : TEXCOORD0; /* pack0.xyz = positionWS */
				float2 pack1 : TEXCOORD1; /* pack1.xy = texcoord0 */
			#if defined(DEPTH_ONLY_PASS)
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			#endif
			};

			float4 GetShadowPositionHClip(Attributes input)
			{
				float3 positionWS = TransformObjectToWorld(input.vertex.xyz);
				float3 normalWS = TransformObjectToWorldNormal(input.normal);

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

			#if UNITY_REVERSED_Z
				positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#else
				positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
			#endif

				return positionCS;
			}

			Varyings ShadowDepthPassVertex(Attributes input)
			{
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);
				#if defined(DEPTH_ONLY_PASS)
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				#endif

				// Texture Coordinates
				output.pack1.xy.xy = input.texcoord0.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.vertex.xyz);
				VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normal);
				float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
				output.normal = NormalizeNormalPerVertex(vertexNormalInput.normalWS);
				output.pack0.xyz = vertexInput.positionWS;

				#if defined(DEPTH_ONLY_PASS)
					output.positionCS = TransformObjectToHClip(input.vertex.xyz);
				#elif defined(SHADOW_CASTER_PASS)
					output.positionCS = GetShadowPositionHClip(input);
				#else
					output.positionCS = float4(0,0,0,0);
				#endif

				return output;
			}

			half4 ShadowDepthPassFragment(Varyings input) : SV_TARGET
			{
				#if defined(DEPTH_ONLY_PASS)
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				#endif

				float3 positionWS = input.pack0.xyz;

				// Shader Properties Sampling
				float4 __albedo = ( tex2D(_BaseMap, input.pack1.xy.xy).rgba );
				float4 __mainColor = ( _BaseColor.rgba );
				float __alpha = ( __albedo.a * __mainColor.a );

				float3 normalWS = NormalizeNormalPerPixel(input.normal);
				half3 viewDirWS = SafeNormalize(GetCameraPositionWS() - positionWS);
				half ndv = max(0, dot(viewDirWS, normalWS));
				half ndvRaw = ndv;

				half3 albedo = __albedo.rgb;
				half alpha = __alpha;
				half3 emission = half3(0,0,0);
				return 0;
			}

		#endif
		ENDHLSL

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			// Required to compile gles 2.0 with standard srp library
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			// using simple #define doesn't work, we have to use this instead
			#pragma multi_compile SHADOW_CASTER_PASS

			// -------------------------------------
			// Material Keywords
			//#pragma shader_feature _ALPHATEST_ON
			//#pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing

			#pragma vertex ShadowDepthPassVertex
			#pragma fragment ShadowDepthPassFragment
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0

			HLSLPROGRAM

			// Required to compile gles 2.0 with standard srp library
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma target 2.0

			// -------------------------------------
			// Material Keywords
			// #pragma shader_feature _ALPHATEST_ON
			// #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing

			// using simple #define doesn't work, we have to use this instead
			#pragma multi_compile DEPTH_ONLY_PASS

			#pragma vertex ShadowDepthPassVertex
			#pragma fragment ShadowDepthPassFragment
			
			ENDHLSL
		}

		// Depth prepass
		// UsePass "Universal Render Pipeline/Lit/DepthOnly"

	}

	FallBack "Hidden/InternalErrorShader"
	CustomEditor "ToonyColorsPro.ShaderGenerator.MaterialInspector_SG2"
}

/* TCP_DATA u config(unity:"2019.4.1f1";ver:"2.4.5";tmplt:"SG2_Template_URP";features:list["UNITY_5_4","UNITY_5_5","UNITY_5_6","UNITY_2017_1","UNITY_2018_1","UNITY_2018_2","UNITY_2018_3","UNITY_2019_1","UNITY_2019_2","UNITY_2019_3","RIM_OUTLINE","EMISSION","OUTLINE","SHADOW_LINE","BUMP","TEMPLATE_LWRP"];flags:list[];keywords:dict[RENDER_TYPE="Opaque",RampTextureDrawer="[TCP2Gradient]",RampTextureLabel="Ramp Texture",SHADER_TARGET="3.0",RIM_LABEL="Rim Outline"];shaderProperties:list[];customTextures:list[]) */
/* TCP_HASH 5e76578c12804773f7b6618793cef7e5 */
