
vec3 lightDir = normalize(vec3(4.0,3.0,4.0));
vec4 lightColor = vec4(0.7);
vec4 lightAmbient = vec4(0.2);

const vec4 iceColor = vec4(0.9,0.92,1.0,1.0);


vec3 cameraUp = vec3(0.0,1.0,0.0);
vec3 cameraRight,cameraPosition,cameraDirection;

vec3 rayPos,rayDir;

vec3 calcNormal(vec3 p1, vec3 p2, vec3 p3) {
    vec3 u = p2-p1;
    vec3 v = p3-p1;
    
    vec3 normal = vec3(u.y*v.z-u.z*v.y,
                       u.z*v.x-u.x*v.z,
                       u.x*v.y-u.y*v.x);
    
    return normalize(normal);
}

float getHeight(float x, float z) {
    return max(-5.0,
           sin(x+sin(z/4.0))*0.1 + sin(z/2.4)*2.0 +
           sin(x/18.0)*10.0 + cos(z/18.0+sin(x/14.0))*12.0
               );
}


const float fogStart = 0.5;
const float viewDist = 200.0;
const float lowTest = 5.0;
const float highTest = 0.1;
const int lowViewTimes = int(viewDist/lowTest);
const int highViewTimes = int(lowTest/highTest);

const vec4 background = vec4(126.0/255.0,192.0/255.0,238.0/255.0,1.0);



struct RayHit {
    vec3 normal;
    bool isHit,calcNormal;
};

void hightrace(inout RayHit hit) {
   for (int k = 0; k < highViewTimes; k++) {
       rayPos += rayDir*highTest;
                
       if (rayPos.y < getHeight(rayPos.x,rayPos.z)) {
           if (hit.calcNormal) {
             hit.normal = calcNormal(vec3(0.0,getHeight(rayPos.x,rayPos.z),0.0),
                                                 vec3(0.0,getHeight(rayPos.x,rayPos.z+0.1),+0.1),
                                                 vec3(0.1,getHeight(rayPos.x+0.1,rayPos.z),0.0));
           }
               
             rayPos -= rayDir*highTest;
             return;
       }
   }
}

void lowtrace(inout RayHit hit) {
    hit.isHit = false;
    
    if (rayPos.y < getHeight(rayPos.x,rayPos.z)) {
        return;
    }
    
    for (int i = 0; i < lowViewTimes; i++) {
        rayPos += rayDir*lowTest;
        
        if (rayPos.y < getHeight(rayPos.x,rayPos.z)) {
            rayPos -= rayDir*lowTest;
                        
      hightrace(hit);
            hit.isHit = true;
            return;
        }
    }
}


vec4 scenePixel() {
    RayHit hit;
    hit.calcNormal = true;
    lowtrace(hit);
    if (hit.isHit) {
        
        vec3 oldRayPos = rayPos;
        vec3 oldRayDir = rayDir;
        
        float fogAm = (length(cameraPosition-rayPos)/viewDist);
        if (fogAm >= fogStart) {
            fogAm -= fogStart;
            fogAm = (fogAm/(1.0-fogStart));
        } else {
            fogAm = 0.0;
        }
        
        vec4 samp = texture2D(iChannel0,rayPos.xz*0.1);
        
        //snow
        if (rayPos.y > 6.0) {
            if (rayPos.y > 12.0) {
                samp = texture2D(iChannel1,rayPos.xz*0.1)*1.7;
            } else {
              samp = mix(samp,
                           texture2D(iChannel1,rayPos.xz*0.1)*1.7,
                           (rayPos.y-6.0)/6.0);
            }
        } else {
            //ice
            if (rayPos.y < -4.6) {
                samp = texture2D(iChannel1,rayPos.xz*0.1);
                hit.normal = reflect(hit.normal,((samp.xyz*2.0)-vec3(1.0))*0.6);//just take a normal from the texture, since we dont have access to a normal map
                samp *= iceColor;
                
                
                rayDir = reflect(rayDir,hit.normal);
                
                
                RayHit reflHit;
                reflHit.calcNormal = true;
                lowtrace(reflHit);
                
                if (reflHit.isHit) {
                    vec4 hitCol = texture2D(iChannel0,rayPos.xz*0.1);//calc lighting color/texture color of hit
                    if (rayPos.y > 6.0) {
                        if (rayPos.y > 12.0) {
                           hitCol = texture2D(iChannel1,rayPos.xz*0.1)*1.7;
                        } else {
                    hitCol = mix(hitCol,
                           texture2D(iChannel1,rayPos.xz*0.1)*1.7,
                           (rayPos.y-6.0)/6.0); 
                        }
                    }
                    hitCol = lightAmbient*hitCol+
                             max(dot(lightDir,reflHit.normal),0.0)*lightColor*hitCol;
                     
                    samp = mix(samp,hitCol,0.4);
                } else {
                    
                    samp = mix(samp,background,0.4);
                }
                
                rayPos = oldRayPos;
                rayDir = oldRayDir;
            }
        }
        
        
        //calculate lighting
        rayDir = lightDir;
        
        RayHit lightHit;
        lightHit.calcNormal = false;
        lowtrace(lightHit);
        
        if (lightHit.isHit) {
            return mix(lightAmbient*samp, background,fogAm);
        } else {
            float am = max(dot(lightDir,hit.normal),0.0);
            if (oldRayPos.y < -4.6) {//is ice, do specular
                return mix(lightAmbient*samp + am*lightColor*samp + pow(max(0.0,dot(reflect(-lightDir, hit.normal), oldRayDir)),8.0)*vec4(0.7), background, fogAm);
            } else {
              return mix(lightAmbient*samp + am*lightColor*samp, background, fogAm);
            }
        }
    } else {
      return background;
    }
}


const float cameraMoveSpeed = 0.05;

const vec2 center = vec2(0.5,0.5);

void main(void) {
    //calculate camera
    cameraPosition = vec3(sin(iGlobalTime*cameraMoveSpeed)*180.0,15.0,cos(iGlobalTime*cameraMoveSpeed)*180.0);
    cameraDirection = normalize(-cameraPosition);
    cameraPosition.y = getHeight(cameraPosition.x,cameraPosition.z)+15.0;
    
    
  vec2 cUv = (gl_FragCoord.xy / iResolution.xy)-center;
    cUv.x *= iResolution.x/iResolution.y;
  
    //camera vectors
    cameraRight = cross(cameraDirection,cameraUp);
    cameraUp = cross(cameraRight,cameraDirection);
    
    //calculate perspective ray from uv and camera vectors
    vec3 rPoint = cUv.x*cameraRight +
                  cUv.y*cameraUp +
              cameraPosition + cameraDirection;
    
    rayDir = normalize(rPoint-cameraPosition);
    rayPos = cameraPosition;
    
    
  gl_FragColor = scenePixel();
}
