/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein

	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

// Constants
const int MAX_LIGHTS = 4; // Set equal to # of lights in scene
// must have constant value to iterate over GLSL uniform arrays. 
// https://www.khronos.org/opengl/wiki/Uniform_(GLSL)

// Inputs
in vec4 vModelViewNorm;			// Step 3
in vec4 vViewPos;				// Step 3
in vec4 vTexCoord;				// Step 3

// Uniforms
uniform sampler2D uTex_dm;		// Step 1
uniform int uLightCt;			// light count
uniform vec4 uLightPos[MAX_LIGHTS];		// Step 2
uniform vec4 uLightCol[MAX_LIGHTS];		// Step 2
uniform float uLightSz[MAX_LIGHTS];		// Step 2
uniform float uLightSzInvSq[MAX_LIGHTS];  // Step 2
// idle renderer, 459

// Outputs
out vec4 rtFragColor;

// https://www.learnopengles.com/tag/lambertian-reflectance/
// http://www.opengl-tutorial.org/beginners-tutorials/tutorial-8-basic-shading/
// Used for help, but had to implement for animal3D, just helped me understand lambert model
// https://en.wikipedia.org/wiki/Lambertian_reflectance - helped with understanding the Lambertian diffuse calculation
void main()
{
	// https://stackoverflow.com/questions/41984724/calculating-angle-between-two-vectors-in-glsl
	vec4 vert = texture2D(uTex_dm, vec2(vTexCoord)); // sample texture

	vec4 color; // declare color variable

	// Jake Lambert Attempt
	/*
		vec4 lightVec = normalize(uLightPos[i] - viewPos);
		float distance = length(uLightPos[i] - viewPos);
		lambert = dot(modelViewNorm, lightVec);
		float diffuse = lambert * (1.0 / (1.0 + (0.25 * distance * distance)));
		vec4 colorToAdd = uLightCol[i];
		color += colorToAdd;
	*/

	/*
		Variable Naming Convention:
		- L: The light-direction vector
		- L_Hat: L but normalized
		- N: Surface normal vector, incoming varying
		- C: Surface color
		- I_L: Intensity of light hitting the surface
		- I_D: Intensity of diffusely reflected light
	*/

	// Connor Lambert Attempt
	for (int i = 0; i < uLightCt; ++i)
	{
		vec4 lightVec = uLightPos[i] - vViewPos; // calculate L
		vec4 lightVecNorm = normalize(lightVec); // calculate L_Hat
		float lambert = dot(vModelViewNorm, lightVecNorm); // Calculate L dot N, which is the reflection of light

		vec4 surfaceColor = texture2D(uTex_dm, vec2(uLightPos[i]));

		vec4 diffuse = lambert * surfaceColor; // Calculate I_D = L dot N * C * I_L
		color += diffuse * vert;
	}

	vec4 outCol = clamp(color * vert, 0,1);

	rtFragColor = outCol;
}