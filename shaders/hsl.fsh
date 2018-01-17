#ifdef GL_ES
precision mediump float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform vec4 uparams;

void main() {
    if(v_fragmentColor.a==0.0)
        discard;
    vec4 rgba = texture2D(CC_Texture0, v_texCoord);
    if(rgba.a==0.0)
        discard;
    float h=0.0;
    float min = rgba.r;
    if(min>rgba.g)
        min=rgba.g;
    if(min>rgba.b)
        min=rgba.b;
    float max = rgba.r;
    if(max<rgba.g)
        max=rgba.g;
    if(max<rgba.b)
        max=rgba.b;
    float l=(max+min)/2.0;
    float s=0.0;
    if(max>min){
        if(l<0.5)
            s=(max-min)/2.0/l;
        else
            s=(max-min)/2.0/(1.0-l);
        if(max==rgba.r){
            if(rgba.g>rgba.b)
                h=(rgba.g-rgba.b)/(max-min);
            else
                h=(rgba.g-rgba.b)/(max-min) + 6.0;
        }
        else if(max==rgba.g)
            h=(rgba.b-rgba.r)/(max-min) + 2.0;
        else
            h=(rgba.r-rgba.g)/(max-min) + 4.0;
    }
    h=h+uparams[0];
    if(h>=6.0)
        h=h-6.0;
    s=s+uparams[1];
    if(s<0.0)
        s=0.0;
    if(s>1.0)
        s=1.0;
    float b = uparams[2]*rgba.a;
    if(b<0.0)
        l = l*(1.0+b);
    else
        l = l+(1.0-l)*b; 

    float q=l*(1.0+s);
    if(l>=0.5)
        q=l+s-l*s;
    float p=2.0*l-q;
    if(h<1.0)
        rgba=vec4(q, p+(q-p)*h, p,rgba.a);
    else if(h<2.0)
        rgba=vec4(p+(q-p)*(2.0-h), q, p,rgba.a);
    else if(h<3.0)
        rgba=vec4(p, q, p+(q-p)*(h-2.0),rgba.a);
    else if(h<4.0)
        rgba=vec4(p, p+(q-p)*(4.0-h), q,rgba.a);
    else if(h<5.0)
        rgba=vec4(p+(q-p)*(h-4.0), p, q,rgba.a);
    else
        rgba=vec4(q, p, p+(q-p)*(6.0-h),rgba.a);
    if(uparams[3]>=0.1)
    {
        vec4 trgba = vec4(v_fragmentColor.r * uparams[3], v_fragmentColor.g * uparams[3], v_fragmentColor.b * uparams[3], v_fragmentColor.a);
        if(trgba.r == 1.0)
            rgba.r = 1.0;
        else
            rgba.r = rgba.r / (1.0 - trgba.r);
        if(trgba.g == 1.0)
            rgba.g = 1.0;
        else
            rgba.g = rgba.g / (1.0 - trgba.g);
        if(trgba.b == 1.0)
            rgba.b = 1.0;
        else
            rgba.b = rgba.b / (1.0 - trgba.b);
        gl_FragColor = rgba * trgba.a;
    }
    else
        gl_FragColor = v_fragmentColor * rgba;
}
