#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 uparams;

void main() {
    gl_FragColor=v_fragmentColor;
}
