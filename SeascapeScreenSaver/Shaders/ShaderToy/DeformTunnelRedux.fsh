
// Deform - square tunnel : REDUX
// Modifications by Stanley Hayes
// Original Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//Hsv conversion from http://ploobs.com.br/?p=1499
vec3 Hue(float a)
{
  vec3 K = vec3(3,2,1)/3.;
  return clamp(abs(fract(vec3(a)+K)*6. - vec3(3.)) - K.xxx, 0., 1.);
}

vec3 HSVtoRGB(vec3 HSV)
{
    return vec3(((Hue(HSV.x) - 1.0) * HSV.y + 1.0) * HSV.z);
}

// Shader Begin

void main( void )
{
    // normalized coordinates (-1 to 1 vertically)
    vec2 p = (-iResolution.xy + 2.0*gl_FragCoord.xy)/iResolution.y;

    // --- FROM IQ ----
    // modified distance metric. Usually distance = (x² + y²)^(1/2). By replacing all the "2" numbers
    // by 32 in that formula we can create distance metrics other than the euclidean. The higher the
    // exponent, then more square the metric becomes. More information here:    
    // http://en.wikipedia.org/wiki/Minkowski_distance
    
    //Makes everything a little trippy
    float crayStationsCoef = .01;     
    
    p.x +=  sin(pow(iGlobalTime,.5))*crayStationsCoef*10.0;    
    //p.y +=  cos(iGlobalTime)*crayStationsCoef*10.0;
    // angle of each pixel to the center of the screen
    float a = atan(p.y,p.x) + iGlobalTime * sin(iGlobalTime)*.002 + iMouse.x * .0001;
    
    
    float exp = 1.; // makes this a box if you see it fit
    //Mink.. Calculation 
    float r = pow( pow(p.x*p.x,exp) + pow(p.y*p.y,exp), 1.0/(exp * 2.0) ) + sin(iGlobalTime)*crayStationsCoef;
    a += pow(r,.5); 
           
    // index texture by angle and radious, and animate along radius    
    vec2 uv = vec2(0.5/r + 0.5*iGlobalTime + iMouse.y,                    a/3.1416 );

    // Lighting
    r -= sin(iGlobalTime)*.05;
    
    // fetch color and darken in the center
    vec3 col =  texture2D( iChannel0, uv ).xyz * r;
    
    //Lerp in Cray Mode
    col = (crayStationsCoef) * HSVtoRGB(vec3(col.r, 1.0, 1.0)) + col *(1.-crayStationsCoef);  
    col *= (sin(uv.x*5.0)*1.0 + 1.0) * .7;
    
    gl_FragColor = vec4(col, 1.0);
}

