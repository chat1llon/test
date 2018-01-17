#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 uparams;

void main() {
    vec2 tmp = 2.0*(vec2(0.5,0.5)-v_texCoord);
    float r = sqrt(dot(tmp,tmp));
    float alpha = 0.0;
    float max = 1.0;
    float min = uparams[1];
    if(r<=max && r>=min){
        max = max-uparams[2];
        if(r>max)
            alpha = (1.0-(r-max)/uparams[2]);
        else if(r>max-uparams[0])
            alpha = ((r+uparams[0]-max)/uparams[0]*0.825+0.175);
        else if(uparams[1]>0.0){
            if(r>=min){
                min = min+uparams[2];
                if(r<min)
                    alpha = 1.0-(min-r)/uparams[2];
                else if(r<min+uparams[0])
                    alpha = ((min+uparams[0]-r)/uparams[0]*0.825+0.175);
                else
                    alpha = 0.175;
            }
        }
        else
            alpha = 0.175;
    }
    gl_FragColor=v_fragmentColor*alpha;
}
