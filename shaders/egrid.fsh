#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 uparams;

void main() {
    float px = v_texCoord.x*uparams[0];
    if(px>=0.0 && px<=uparams[2])
        px = px-0.0;
    else if(px>=uparams[0]-uparams[2] && px<=uparams[0])
        px = uparams[0]-px;
    else
        px = uparams[2];
    float py = v_texCoord.y*uparams[1];
    if(py>=0.0 && py<=uparams[2])
        py = py-0.0;
    else if(py>=uparams[1]-uparams[2] && py<=uparams[1])
        py = uparams[1]-py;
    else
        py = uparams[2];
    if(px>py)
        px = py;
    if(px>uparams[2]/2.0)
        px = uparams[2]-px;
    if(px>=uparams[3])
        px = 1.0;
    else
        px = px/uparams[3];
    gl_FragColor=v_fragmentColor*px;
}
