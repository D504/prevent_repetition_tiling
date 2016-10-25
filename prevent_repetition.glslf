// Use 4 lookups
// Lookups count can be reduced to 3 without quality losing
// Noise function is taken from here (https://www.shadertoy.com/view/4djSRW)

#define HASHSCALE3 vec3(.1031, .1030, .0973)
vec2 noise(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
	p3 += dot(p3, p3.yzx+19.19);
	return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

vec2 random_uv(vec2 tuv, float offset) {
	return tuv + noise(floor(tuv) + offset);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 tuv = (1.0 + abs(20.0 * sin(2.0 / 10.0))) * uv;

	vec2 new_tuv0 = random_uv(tuv, 0.0);
	vec2 new_tuv1 = random_uv(tuv + vec2(0.0, 0.5), 1.0);
	vec2 new_tuv2 = random_uv(tuv + vec2(0.5, 0.0), 2.0);
	vec2 new_tuv3 = random_uv(tuv + 0.5, 3.0);

  vec2 fr_tuv = fract(tuv);
	//vec2 mix_c = smoothstep(0.625, 0.875, fr_tuv) + (1.0 - smoothstep(0.125, 0.375, fr_tuv));
	vec2 mix_c = smoothstep(0.125, 0.375, abs(fr_tuv - 0.5));
	vec4 unrep =
		mix(
			mix(
				texture2D(iChannel0, new_tuv0)
				,
				texture2D(iChannel0, new_tuv1)
				,
				mix_c.y
			)
			,
			mix(
				texture2D(iChannel0, new_tuv2)
				,
				texture2D(iChannel0, new_tuv3)
				,
				mix_c.y
			)
			,
			mix_c.x
		);
	vec4 rep = texture2D(iChannel0, tuv);
	fragColor = uv[0] > 0.5? rep: unrep;
}
