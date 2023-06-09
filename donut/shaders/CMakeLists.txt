#
# Copyright (c) 2014-2021, NVIDIA CORPORATION. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


include(../compileshaders.cmake)

file(GLOB donut_shaders
	"*.hlsl"
	"passes/*.hlsl"
	"../include/donut/shaders/*.hlsli"
	"../include/donut/shaders/*.h"
)

if(DONUT_SHADERS_OUTPUT_DIR)
	set(output_base ${DONUT_SHADERS_OUTPUT_DIR})
else()
	set(output_base ${CMAKE_CURRENT_BINARY_DIR})
endif()

if(NVRHI_WITH_SHADER_COMPILER)
	donut_compile_shaders_all_platforms(
		TARGET donut_shaders
		CONFIG ${CMAKE_CURRENT_LIST_DIR}/DonutShaders.cfg
		FOLDER Donut
		OUTPUT_BASE ${output_base}
		SOURCES ${donut_shaders}
	)
endif()
