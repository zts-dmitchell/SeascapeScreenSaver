#ifdef GL_ES
precision highp float;
#endif

attribute vec2 pos;

void main() {
    
    gl_Position = vec4(pos.x,pos.y, 0.0,1.0);
}