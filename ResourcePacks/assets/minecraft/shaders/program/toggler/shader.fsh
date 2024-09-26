#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D ControlSampler;
uniform sampler2D FlashlightSampler;
uniform sampler2D SharinganSampler;
uniform sampler2D SharinganSampler1;
uniform sampler2D SharinganSampler2;

uniform vec4 ColorModulate;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 ScreenSize;
uniform float _FOV;

in vec2 texCoord;
out vec4 fragColor;

float near = 0.1; 
float far  = 1000.0;
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0;
    return (near * far) / (far + near - z * (far - near));    
}
vec2 RotateCoordinates(vec2 pos,float theta)
{
    mat2 uvRotate = mat2(cos(theta), -sin(theta),
                        sin(theta), cos(theta));
    return uvRotate * pos;
}
float time() {
    vec3 dataTime = texelFetch(ControlSampler, ivec2(0, 0), 0).rgb;
    return dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;
}


// Flashlight Variables
const float exposure = 2.;
const float AOE = 8.;

void main() {
    vec4 prev_color = texture(DiffuseSampler, texCoord);
    vec4 overlay;
	fragColor = prev_color;
    float avg;
    float depth;
    float distance;
    float fog_factor;
    // Channel #1
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0);
    switch(int(control_color.b * 255.)) {
        case 1:
            avg = (fragColor.r + fragColor.g + fragColor.b) / 3.0;
            if (avg < 0.5) {
                fragColor.rgb = mix(vec3(avg + 0.5), vec3(0.0), 0.25);
            } else {
                fragColor.rgb = mix(vec3(avg - 0.5), vec3(1.0), 0.25);
            }
            depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);
            fog_factor = 0.025 + 0.0125 * sin(time() * 0.1 * 6.28);
            fragColor.rgb = mix(fragColor.rgb, vec3(1.0, 0., 0.), fog_factor * distance);
            // vec2 uv = texCoord;
            // float d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));
            // d = exp(-(d * AOE)) * exposure / (distance*0.15);
            // fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;
        case 2:
            fragColor = vec4(mix(fragColor.rgb, vec3(1.0, 0.0, 0.0), 0.5), fragColor.a);
            break;
        case 3:
            avg = (fragColor.r + fragColor.g + fragColor.b) / 3.0;
            if (avg < 0.5) {
                fragColor.rgb = mix(vec3(avg + 0.5), vec3(0.0), 0.25);
            } else {
                fragColor.rgb = mix(vec3(avg - 0.5), vec3(1.0), 0.25);
            }
            break;
        case 4:
            avg = (fragColor.r + fragColor.g + fragColor.b) / 3.0;
            if (avg < 0.5) {
                fragColor.rgb = mix(vec3(avg), vec3(0.0), 0.25);
            } else {
                fragColor.rgb = mix(vec3(avg), vec3(1.0), 0.25);
            }
            break;
        case 5:
            fragColor.rgb = mix(vec3((fragColor.r + fragColor.g + fragColor.b) / 3.0), vec3(0.0), 0.5);
            float ds = sqrt(pow((texCoord.x - 0.5),2.0) + pow((texCoord.y - 0.5),2.0));
            float rd = 0.1 + 0.1 * sin(time() * 6.28);
            if (ds > rd) {
                fragColor.rgb = mix(fragColor.rgb, vec3(0.0), 3.0 * (ds - rd));
            }
            break;
        case 6:
            // float size = 0.001 + texelFetch(ControlSampler, ivec2(0, 0), 0).x;
            // vec2 pos = texCoord;
            // // TODO: Make it enlarge and rotate
            // if (pos.x > 0.5 - size && pos.x < 0.5 + size && pos.y > 0.5 - size && pos.y < 0.5 + size) {
            //     vec2 image_pos = vec2(1.0 - (0.5 + size / 2.0 - pos.x) / size, 1.0 - (0.5 + size / 2.0 - pos.y) / size);
            //     overlay = texture(SharinganSampler, image_pos);
            //     if (overlay.a > 0.0 && image_pos.x > 0.25 && image_pos.x < 0.75 && image_pos.y > 0.2 && image_pos.y < 0.8) {
            //         fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a).rgb;
            //     } else {
            //         fragColor.rgb = mix(fragColor.rgb, vec3(1.0, 0.0, 0.0), 0.25).rgb;
            //     }
            // }
            float rot = 6.28 * texelFetch(ControlSampler, ivec2(0, 0), 0).x;
            vec2 trans_pos = texCoord * 2.0 - 1.0;
            vec2 image_pos = (RotateCoordinates(trans_pos, rot) + 1.0) / 2.0;
            overlay = texture(SharinganSampler, image_pos);
            fragColor.rgb = mix(fragColor.rgb, vec3(1.0, 0.0, 0.0), 0.25).rgb;
            if (overlay.a > 0.0) {
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlay.a * texelFetch(ControlSampler, ivec2(0, 0), 0).x).rgb;
            }
            break;
        case 7:
            depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
            distance = length(vec3(1., (2.*texCoord - 1.) * vec2(OutSize.x/OutSize.y,1.) * tan(radians(_FOV / 2.))) * depth);
            fragColor.rgb = mix(fragColor.rgb, vec3(1.0), 0.1 * distance);
            // vec2 uv = texCoord;
            // float d = sqrt(pow((uv.x - 0.5),2.0) + pow((uv.y - 0.5),2.0));
            // d = exp(-(d * AOE)) * exposure / (distance*0.15);
            // fragColor = vec4(fragColor.rgb*clamp(1.0 + d,0.1,10.0),1.0);
            break;
        case 8:
            float dist = sqrt(pow((texCoord.x - 0.5),2.0) + pow((texCoord.y - 0.5),2.0));
            if (sqrt(pow(texCoord.x - 0.5, 2.0)) > 0.1 || sqrt(pow(texCoord.y - 0.5, 2.0)) > 0.1) {
                // if within thickness distance from sin(time()), x
                if (sqrt(pow((texCoord.x - 0.5),2.0)) < (dist - 0.1) * 0.05) {
                    fragColor.rgb = vec3(0.0);
                } else if (
                    sqrt(
                        pow((texCoord.x - 0.5 * cos(0.785398) + sin(0.785398) * texCoord.y),2.0) + 
                        pow(texCoord.y - 0.5 * sin(0.785398) - cos(0.785398) * texCoord.y, 2.0)
                    ) < (dist - 0.1) * 0.05) {
                    fragColor.rgb = vec3(0.0);
                }
            }
            break;
        case 9:
            avg = (fragColor.r + fragColor.g + fragColor.b) / 3.0;
            if (avg < 0.5) {
                fragColor.rgb = mix(vec3(avg + 0.5), vec3(1.0, 0., 0.), 0.25);
            } else {
                fragColor.rgb = mix(vec3(avg - 0.5), vec3(1.0, 0., 0.), 0.25);
            }
            float ds2 = sqrt(pow((texCoord.x - 0.5),2.0) + pow((texCoord.y - 0.5),2.0));
            float rd2 = 0.1 + 0.1 * sin(time() * 6.28);
            if (ds2 > rd2) {
                fragColor.rgb = mix(fragColor.rgb, vec3(0.0), 3.0 * (ds2 - rd2));
            }
            float overlayAlpha = 0.5 + 0.5 * sin(time() * 6.28);
            overlay = texture(SharinganSampler1, texCoord);
            if (overlay.a > 0.0) {
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, overlayAlpha).rgb;
            }
            overlay = texture(SharinganSampler2, texCoord);
            if (overlay.a > 0.0) {
                fragColor.rgb = mix(fragColor.rgb, overlay.rgb, 1.0 - overlayAlpha).rgb;
            }
            break;
    }
}
