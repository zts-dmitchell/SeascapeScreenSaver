#ifdef GL_ES
precision highp float;
#endif

attribute vec2 pos;

void main() {
    
    //vec2 rotated;
    //rotated.y = -pos.x;
    //rotated.x = pos.y;
    //gl_Position = vec4(pos.xy *.5,0.0,1.0);
    gl_Position = vec4(pos.x,pos.y, 0.0,1.0);
}