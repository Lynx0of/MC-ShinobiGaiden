#version 150
in vec4 Position;

uniform vec2 InSize;
uniform vec2 OutSize;
uniform vec2 ScreenSize;

uniform sampler2D ControlSampler;

out vec2 texCoord;

float time() {
    vec3 dataTime = texelFetch(ControlSampler, ivec2(0, 0), 0).rgb;
    return dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;
}

void main(){
    float poi = texture(ControlSampler,vec2(0.0,0.0)).a;
    // same as blit_copy but you can change if u want
    float x = -1.0; 
    float y = -1.0;

    if (Position.x > 0.001){
        x = 1.0;
    }
    if (Position.y > 0.001){
        y = 1.0;
    }

    gl_Position = vec4(x, y, 0.2, 1.0);
    vec4 control_color = texelFetch(ControlSampler, ivec2(0, 1), 0);
    switch(int(control_color.b * 255.)) {
        case 1:
            if (y < 0.0) y = y - 0.3;
            else y = y + 0.3;
            if (x < 0.0) {
                gl_Position = vec4(x, y + 0.3 * sin(3.14 * time()), 0.2, 1.);
            } else {
                gl_Position = vec4(x, y - 0.3 * sin(3.14 * time()), 0.2, 1.);
            }
            break;
        case 2:
            gl_Position = vec4(-x, -y, 0.2, 1.);
            break;
        case 3:
            gl_Position = vec4(x * 2.0, y * 2.0, 0.2, 1.);
            break;
    }
    texCoord = Position.xy / OutSize;
}