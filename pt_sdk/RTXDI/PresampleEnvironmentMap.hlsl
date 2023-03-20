/*
* Copyright (c) 2023, NVIDIA CORPORATION.  All rights reserved.
*
* NVIDIA CORPORATION and its licensors retain all intellectual property
* and proprietary rights in and to this software, related documentation
* and any modifications thereto.  Any use, reproduction, disclosure or
* distribution of this software and related documentation without an express
* license agreement from NVIDIA CORPORATION is strictly prohibited.
*/

#include "RtxdiApplicationBridge.hlsli"

#include "../../external/RTXDI/rtxdi-sdk/include/rtxdi/ResamplingFunctions.hlsli"

[numthreads(RTXDI_PRESAMPLING_GROUP_SIZE, 1, 1)] 
void main(uint2 GlobalIndex : SV_DispatchThreadID) 
{    
    RAB_RandomSamplerState rng = RAB_InitRandomSampler(GlobalIndex.xy, 0);

#if RTXDI_ENABLE_PRESAMPLING
    RTXDI_PresampleEnvironmentMap(
        rng,
        t_EnvironmentPdfTexture,
        g_RtxdiBridgeConst.environmentPdfTextureSize,
        GlobalIndex.y,
        GlobalIndex.x,
        g_RtxdiBridgeConst.runtimeParams.environmentLightParams);
#endif
}