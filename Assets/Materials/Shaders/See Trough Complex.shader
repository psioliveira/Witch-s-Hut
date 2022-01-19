Shader "See Through Objects"
{
    Properties
    {
        [NoScaleOffset] _Texture2D("Texture2D", 2D) = "white" {}
        _Color("Color", Color) = (0, 0, 0, 0)
        _Position("Player Pos", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        smoothness("smoothness", Range(0, 1)) = 0.5
        opacity("opacity", Range(0, 1)) = 1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
    #pragma multi_compile _ _GBUFFER_NORMALS_OCT
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile _ DOTS_INSTANCING_ON
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.Emission = float3(0, 0, 0);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 4.5
    #pragma exclude_renderers gles gles3 glcore
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 NormalTS;
    float3 Emission;
    float Metallic;
    float Smoothness;
    float Occlusion;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Emission = float3(0, 0, 0);
    surface.Metallic = 0;
    surface.Smoothness = 0.5;
    surface.Occlusion = 1;
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthOnly"
    Tags
    {
        "LightMode" = "DepthOnly"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On
    ColorMask 0

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 NormalTS;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.NormalTS = IN.TangentSpaceNormal;
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        float4 uv2 : TEXCOORD2;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float3 Emission;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.Emission = float3(0, 0, 0);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

    ENDHLSL
}
Pass
{
        // Name: <None>
        Tags
        {
            "LightMode" = "Universal2D"
        }

        // Render State
        Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma only_renderers gles gles3 glcore d3d11
    #pragma multi_compile_instancing
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float4 interp1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _Texture2D_TexelSize;
float4 _Color;
float2 _Position;
float _Size;
float smoothness;
float opacity;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Texture2D);
SAMPLER(sampler_Texture2D);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0 = UnityBuildTexture2DStructNoScale(_Texture2D);
    float4 _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.tex, _Property_bc304cfc11e04f9b9e5eb40a8f35595a_Out_0.samplerstate, IN.uv0.xy);
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_R_4 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.r;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_G_5 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.g;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_B_6 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.b;
    float _SampleTexture2D_c5c235e05de148afa61347d91b53653d_A_7 = _SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0.a;
    float4 _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0 = _Color;
    float4 _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2;
    Unity_Multiply_float(_SampleTexture2D_c5c235e05de148afa61347d91b53653d_RGBA_0, _Property_ed9aa7a3081a48eabe68b02e270cf590_Out_0, _Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2);
    float _Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0 = opacity;
    float _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0 = smoothness;
    float4 _ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0 = _Position;
    float2 _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3;
    Unity_Remap_float2(_Property_34d2e5f755884d10b5ba680ca68cebe0_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3);
    float2 _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2;
    Unity_Add_float2((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), _Remap_a35d44a16c694f28abfafbe2e6168d22_Out_3, _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2);
    float2 _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_818508f0eecb4a7bab9f96137a751c04_Out_0.xy), float2 (1, 1), _Add_27ede42adc4a488ea62e4106501a8ac9_Out_2, _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3);
    float2 _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2;
    Unity_Multiply_float(float2(2, 2), _TilingAndOffset_bfffed9518864614a30e72f310c71ccc_Out_3, _Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2);
    float2 _Subtract_551422cfecab49cdbd3b373e47914959_Out_2;
    Unity_Subtract_float2(_Multiply_e1855d8284cd4185a9ce3adcf1997db2_Out_2, float2(1, 1), _Subtract_551422cfecab49cdbd3b373e47914959_Out_2);
    float _Divide_e1f41acf89e144768d91a03c24c56733_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e1f41acf89e144768d91a03c24c56733_Out_2);
    float _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0 = _Size;
    float _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2;
    Unity_Multiply_float(_Divide_e1f41acf89e144768d91a03c24c56733_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0, _Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2);
    float2 _Vector2_fffb6984bc224164b255602eece79ee6_Out_0 = float2(_Multiply_8b4e589a3dc44bd58c7e96aaafb96a8d_Out_2, _Property_0c3f0da82ccc44b8ad904bda7f8d9d5a_Out_0);
    float2 _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2;
    Unity_Divide_float2(_Subtract_551422cfecab49cdbd3b373e47914959_Out_2, _Vector2_fffb6984bc224164b255602eece79ee6_Out_0, _Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2);
    float _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1;
    Unity_Length_float2(_Divide_8b83b585607f49f68870a6f9edfdf1f8_Out_2, _Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1);
    float _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1;
    Unity_OneMinus_float(_Length_0b1c75e0db6e42c38e6292cd7ba714db_Out_1, _OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1);
    float _Saturate_64991fa308504128a045804a5f939c53_Out_1;
    Unity_Saturate_float(_OneMinus_44bfa5eb5b1a467abba24ef30e1c36dd_Out_1, _Saturate_64991fa308504128a045804a5f939c53_Out_1);
    float _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3;
    Unity_Smoothstep_float(0, _Property_00fd1d8461a244ee855c757ff53cb5a8_Out_0, _Saturate_64991fa308504128a045804a5f939c53_Out_1, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3);
    float _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2;
    Unity_Multiply_float(_Property_99889f1ec4ed4359b4bdbb70e435814a_Out_0, _Smoothstep_473d3c5f30b64cc4848e426e4155cf2c_Out_3, _Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2);
    float _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    Unity_OneMinus_float(_Multiply_432b2abe5a734c9f8f8b4df149ea089b_Out_2, _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1);
    surface.BaseColor = (_Multiply_a685ce6d523943dba3258d9c56304e1c_Out_2.xyz);
    surface.Alpha = _OneMinus_1e32f30a67fc481892f901f4a7f64221_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

    ENDHLSL
}
    }
        CustomEditorForRenderPipeline "ShaderGraph.PBRMasterGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        FallBack "Hidden/Shader Graph/FallbackError"
}