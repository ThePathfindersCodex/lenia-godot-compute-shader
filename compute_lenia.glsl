#[compute]

#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
	int size;
	float data[];
} my_data_buffer;

layout(set = 0, binding = 1, rgba32f) uniform image2D OUTPUT_TEXTURE;

layout(set = 0, binding = 2, std430) restrict buffer MyDataBuffer2 {
	int size;
	float data[];
} out_data_buffer;

layout(set = 0, binding = 3, std430) restrict buffer MyDataBuffer3 {
	int size;
	float data[];
} kernel_buffer;

layout(set = 0, binding = 4, std430) restrict buffer MyDataBuffer4 {
    int size;
    float data[];
} weighted_sum_buffer;

layout(set = 0, binding = 5, std430) restrict buffer MyDataBuffer5 {
    int size;
    float data[];
} growth_buffer;

layout(set = 0, binding = 6, rgba32f) uniform image2D WEIGHTED_SUM_TEXTURE;
layout(set = 0, binding = 7, rgba32f) uniform image2D GROWTH_TEXTURE;

layout(push_constant, std430) uniform Params {
	float frequency;
	float growth_m;
	float growth_s;
	float color_scheme;
} params;

float growth(float U) {
	return (exp(-pow((U-params.growth_m)/params.growth_s, 2.0) / 2.0) * 2.0 - 1.0);
}

vec4 get_color_jet(float value) {
    vec4 color;
    if (value <= 0.25) {
        // Interpolate between blue and cyan
        float t = value / 0.25;
        color = mix(vec4(0.0, 0.0, 1.0, 1.0), vec4(0.0, 1.0, 1.0, 1.0), t);
    } else if (value <= 0.5) {
        // Interpolate between cyan and yellow
        float t = (value - 0.25) / 0.25;
        color = mix(vec4(0.0, 1.0, 1.0, 1.0), vec4(1.0, 1.0, 0.0, 1.0), t);
    } else if (value <= 0.75) {
        // Interpolate between yellow and red
        float t = (value - 0.5) / 0.25;
        color = mix(vec4(1.0, 1.0, 0.0, 1.0), vec4(1.0, 0.0, 0.0, 1.0), t);
    } else {
        // Interpolate between red and dark red
        float t = (value - 0.75) / 0.25;
        color = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.5, 0.0, 0.0, 1.0), t);
    }
    return color;
}

vec4 get_color_viridis(float value) {
    vec4 color;
    if (value <= 0.25) {
        // Interpolate between dark blue and blue
        float t = value / 0.25;
        color = mix(vec4(0.267, 0.004, 0.329, 1.0), vec4(0.282, 0.140, 0.458, 1.0), t);
    } else if (value <= 0.5) {
        // Interpolate between blue and green
        float t = (value - 0.25) / 0.25;
        color = mix(vec4(0.282, 0.140, 0.458, 1.0), vec4(0.127, 0.566, 0.551, 1.0), t);
    } else if (value <= 0.75) {
        // Interpolate between green and yellow-green
        float t = (value - 0.5) / 0.25;
        color = mix(vec4(0.127, 0.566, 0.551, 1.0), vec4(0.598, 0.884, 0.282, 1.0), t);
    } else {
        // Interpolate between yellow-green and yellow
        float t = (value - 0.75) / 0.25;
        color = mix(vec4(0.598, 0.884, 0.282, 1.0), vec4(0.992, 0.906, 0.145, 1.0), t);
    }
    return color;
}

vec4 get_color_plasma(float value) {
    vec4 color;
    if (value <= 0.25) {
        // Interpolate between dark purple and purple
        float t = value / 0.25;
        color = mix(vec4(0.050, 0.029, 0.529, 1.0), vec4(0.301, 0.000, 0.598, 1.0), t);
    } else if (value <= 0.5) {
        // Interpolate between purple and orange
        float t = (value - 0.25) / 0.25;
        color = mix(vec4(0.301, 0.000, 0.598, 1.0), vec4(0.800, 0.200, 0.200, 1.0), t);
    } else if (value <= 0.75) {
        // Interpolate between orange and light orange
        float t = (value - 0.5) / 0.25;
        color = mix(vec4(0.800, 0.200, 0.200, 1.0), vec4(0.988, 0.644, 0.128, 1.0), t);
    } else {
        // Interpolate between light orange and yellow
        float t = (value - 0.75) / 0.25;
        color = mix(vec4(0.988, 0.644, 0.128, 1.0), vec4(0.940, 0.975, 0.131, 1.0), t);
    }
    return color;
}

vec4 get_color_red_blue(float value) {
    vec4 color;
    float midpoint = 0.5;
    if (value < midpoint) {
        // Interpolate between blue and gray
        float t = value / midpoint;
        color = mix(vec4(0.0, 0.0, 1.0, 1.0), vec4(0.5, 0.5, 0.5, 1.0), t);
    } else {
        // Interpolate between gray and red
        float t = (value - midpoint) / midpoint;
        color = mix(vec4(0.5, 0.5, 0.5, 1.0), vec4(1.0, 0.0, 0.0, 1.0), t);
    }
    return color;
}

void main() {
    uint pos = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * my_data_buffer.size;
    float sum = 0;
    
    // Calculate the weighted sum
    for (int i = 0; i < kernel_buffer.size; i++) {
        int tmp_kernel_pos_x = int(gl_GlobalInvocationID.x) + i - kernel_buffer.size / 2;
        tmp_kernel_pos_x = tmp_kernel_pos_x - my_data_buffer.size * int(tmp_kernel_pos_x >= my_data_buffer.size) + my_data_buffer.size * int(tmp_kernel_pos_x < 0);
        for (int j = 0; j < kernel_buffer.size; j++) {
            int tmp_kernel_pos_y = int(gl_GlobalInvocationID.y) + j - kernel_buffer.size / 2;
            tmp_kernel_pos_y = tmp_kernel_pos_y - my_data_buffer.size * int(tmp_kernel_pos_y >= my_data_buffer.size) + my_data_buffer.size * int(tmp_kernel_pos_y < 0);
            int tmp_kernel_pos = tmp_kernel_pos_x + tmp_kernel_pos_y * my_data_buffer.size;
            sum += my_data_buffer.data[tmp_kernel_pos] * kernel_buffer.data[i + kernel_buffer.size * j];
        }
    }
    
    // Store weighted sum in buffer
    weighted_sum_buffer.data[pos] = sum;
	
    // Calculate growth value
    float growth_val = growth(sum);
	
    // Store growth value in buffer
    growth_buffer.data[pos] = growth_val;
    
    // Update main data buffer (out_data_buffer)
    out_data_buffer.data[pos] = clamp(my_data_buffer.data[pos] + params.frequency * growth_val, 0.0, 1.0);
    // Write to the output texture
    vec4 pixel = vec4(1.0, 1.0, 1.0, 1.0);
	// TODO fix me: bleh... if blocks
	if (params.color_scheme==0) {
		pixel.xyz = vec3(out_data_buffer.data[pos]);
	} else if (params.color_scheme==1) {
		pixel = get_color_red_blue(out_data_buffer.data[pos]);
	} else if (params.color_scheme==2) {
		pixel = get_color_plasma(out_data_buffer.data[pos]);
	} else if (params.color_scheme==3) {
		pixel = get_color_viridis(out_data_buffer.data[pos]);
	} else if (params.color_scheme==4) {
		pixel = get_color_jet(out_data_buffer.data[pos]);
	}
    imageStore(OUTPUT_TEXTURE, ivec2(gl_GlobalInvocationID.xy), pixel);
    
	// Write the weighted sum to the weighted sum texture
	vec4 weighted_sum_pixel = vec4(1.0, 1.0, 1.0, 1.0);
	//weighted_sum_pixel.xyz = vec3(weighted_sum_buffer.data[pos]);
	weighted_sum_pixel = get_color_jet(weighted_sum_buffer.data[pos]);
    imageStore(WEIGHTED_SUM_TEXTURE, ivec2(gl_GlobalInvocationID.xy), weighted_sum_pixel);

    // Write the growth value to the growth texture
	vec4 growth_pixel = vec4(1.0, 1.0, 1.0, 1.0);
	//growth_pixel.xyz = vec3(growth_buffer.data[pos]);
	growth_pixel = get_color_plasma(growth_buffer.data[pos]);
    imageStore(GROWTH_TEXTURE, ivec2(gl_GlobalInvocationID.xy), growth_pixel);
}
