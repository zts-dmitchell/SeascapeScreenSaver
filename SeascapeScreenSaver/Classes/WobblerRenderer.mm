//
//  WobblerRenderer.mm
//  Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "WobblerRenderer.h"
#include "ShaderUtil.h"
#include "ImageLoader.h"

#include "Vector.h"
#include "Matrix.h"

#import <AppKit/AppKit.h>

// Attribute index.
enum {
    ATTRIB_NORMAL,
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

@interface WobblerRenderer(PrivateMethods)
- (BOOL) setupTextures;
- (BOOL) makeSphereWithRadius: (GLfloat) radius
                  andLatitude: (GLint) latitude
                 andLongitude: (GLint) longitude;

@end

@implementation WobblerRenderer

mat4 m_translation;


- (id)init
{
    if ((self = [super init]))
    {
        StartRad.current[0] = 0;
        StartRad.min[0] = 0;
        StartRad.max[0] = 60;
        StartRad.delta[0] = 0.01;
        
        program = [ShaderUtil loadShaders:@"WobblerShader"
                            withVertexExt:@"vsh"
                        andFragmentShader:@"WobblerShader"
                           andFragmentExt:@"fsh"
                           withAttributes:self];
        
        if( ! program )
        {
            self = nil;
            return nil;
        }
        
        m_buffers.VertexBuffer = m_buffers.IndexBuffer = -1;
        glUseProgram(program);
        
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);

        //[self makeSphereWithRadius:0.5 andLatitude:2 andLongitude:2];
        [self makeSphereWithRadius:0.65 andLatitude:32 andLongitude:32];
        
        [self setupTextures];
        
        // Set up transforms.
        m_translation = mat4::Translate(0.0, 0.0, -2.0);
        
        glUseProgram(0);

    }
    
    return self;
}

- (void) dealloc
{
    glDeleteTextures(1, &m_texture);
    
    // TODO: Cleanup vertex buffers;
    [ShaderUtil cleanup:program];
    
    NSLog(@"WobblerRenderer going away ...");
}

- (NSString*) name {
    return @"Wobbler";
}

- (void)setFrameSize:(NSSize)newSize {
    
    m_screenSize = newSize;
    
    NSLog(@"Setting frame size: %f w by %f h", newSize.width, newSize.height);
}

float percentageX = -1.0;
float percentageY = 1.0;

- (void)render
{
    //glClearColor(0.09765625f, 0.09765625f, 0.2375f, 1.0f);
    glClearColor(.01, .01, .01, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(program);
    
    glEnableVertexAttribArray(ATTRIB_NORMAL);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.NormalBuffer);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.TexCoordBuffer);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_buffers.IndexBuffer);
    
    //////////////////////////////////////////
    //  Matrices n' Stuff
    // Set the model-view transform.
    static double angle = 0.0;
    static double incAngle = 0.2;
    
    //Quaternion quat(0.0, 0.0, angle, 0.0);
    vec3 vecRotate(0.0, 1.0, 0.0);
    mat4 rotation = mat4::Rotate(angle, vecRotate);
    
    /*
    vecRotate = vec3(1.0, 0.0, 0.0);
    rotation = rotation * rotation.Rotate(angle, vecRotate);
    
    vecRotate = vec3(0.0, 0.0, 1.0);
    rotation = rotation * rotation.Rotate(angle, vecRotate);
    */
    mat4 modelview = rotation * m_translation;
    glUniformMatrix4fv(m_uniforms.Modelview, 1, 0, modelview.Pointer());

    // There are is non-uniform scaling, so providing the tranpose.
    mat3 normalMatrix = modelview.ToMat3();
    glUniformMatrix3fv(m_uniforms.NormalMatrix, 1, 0, normalMatrix.Pointer());
    
    // Set the projection transform.
    const static float aspect = m_screenSize.width / m_screenSize.height;
    const static float zoom = 0.764;
    float lr, bt;
    if( aspect > 1.0 )
    {
        lr = 0.3 * aspect * zoom;
        bt = 0.3 * zoom;
    }
    else {
        lr = 0.3 * zoom;
        bt = 0.3 / aspect * zoom;
    }

    //mat4 projectionMatrix = mat4::Frustum(-2, 2, -h / 2.0, h / 2.0, 5, 100);
    mat4 projectionMatrix = mat4::Frustum(-lr, lr, -bt, bt, 1.0, 8.0);
    glUniformMatrix4fv(m_uniforms.Projection, 1, 0, projectionMatrix.Pointer());
    //////////////////////////////////////////
    
    ///////////////
    // Other uniform stuff
    float radianAngle = angle * Pi / 180.0 * .0002; // further descale by .02.
    percentageX = sinf(radianAngle);
    percentageY = cosf(radianAngle);
    glUniform2f(m_uniforms.Percentage, percentageX, percentageY);
    
    PARAMETER_ANIMATE(StartRad);
	glUniform1fv(m_uniforms.StartRad, 1, PARAMETER_CURRENT(StartRad));
    
    glActiveTexture(GL_TEXTURE0);
    
    glBindTexture(GL_TEXTURE_2D, m_texture);

    glDrawElements(GL_TRIANGLES, m_buffers.IndexCount, GL_UNSIGNED_SHORT, 0);
    
    glDisableVertexAttribArray(ATTRIB_NORMAL);
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_TEXCOORD);
    
    glUseProgram(0);
    
    angle += incAngle;

    if( angle > 360 )
        angle -= 360;
}

- (BOOL) setupTextures
{
    NSBundle *bundle;
    NSString * string;
    NSBitmapImageRep *bitmapimagerep;
    NSRect rect;
    
    bundle = [NSBundle bundleForClass: [self class]];
    
    string = [bundle pathForResource: @"Day" ofType: @"jpg"];
    //string = [bundle pathForResource: @"tex2" ofType: @"jpg"];
    //string = [bundle pathForResource: @"stars-wallpapers-5-600x512" ofType: @"jpg"];
    
    if( string == nil )
    {
        NSLog(@"Unable to load image file." );
        return false;
    }
    else 
    {
        bitmapimagerep = LoadImage(string, 0    );
        
        if( bitmapimagerep == nil )
        {
            NSLog(@"Unable to load image file: %@", string );
            return false;
        }            
    }
    
    rect = NSMakeRect(0, 0, [bitmapimagerep pixelsWide], [bitmapimagerep pixelsHigh]);
    
    /* day texture */
    glActiveTexture(GL_TEXTURE0);
    
    // Load the texture
    glGenTextures(1, &m_texture);
    glBindTexture(GL_TEXTURE_2D, m_texture);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, rect.size.width, rect.size.height, 0,
                 (([bitmapimagerep hasAlpha])?(GL_RGBA):(GL_RGB)), GL_UNSIGNED_BYTE,
                 [bitmapimagerep bitmapData]);
    
    return true;
}

- (BOOL) makeSphereWithRadius: (GLfloat) radius
                  andLatitude: (GLint) latitude
                 andLongitude: (GLint) longitude
{
    const GLint geometryDataLength = 3 * (latitude+1) * (longitude+1);
    const GLint normalDataLength =  3 * (latitude+1) * (longitude+1);
    const GLint texCoordDataLength =  2 * (latitude+1) * (longitude+1);
    const GLint indexDataLength = 6 * latitude * longitude;
    
    GLfloat geometryData[ geometryDataLength ];
    GLfloat normalData[ normalDataLength ];
    GLfloat texCoordData[ texCoordDataLength ];
    GLushort indexData[ indexDataLength ];
    
    GLint positionNormal = 0;
    GLint positionTexCoord = 0;
    GLint positionGeometry = 0;
    GLint positionIndex = 0;
    
    float pi = 3.1415;
    
    for(float latNumber = 0; latNumber <= latitude; ++latNumber)
    {
        for (float longNumber = 0; longNumber <= longitude; ++longNumber)
        {
            GLfloat theta = latNumber * pi / latitude;
            GLfloat phi = longNumber * 2.0 * pi / longitude;
            GLfloat sinTheta = sin(theta);
            GLfloat sinPhi = sin(phi);
            GLfloat cosTheta = cos(theta);
            GLfloat cosPhi = cos(phi);
            
            GLfloat x = cosPhi * sinTheta;
            GLfloat y = cosTheta;
            GLfloat z = sinPhi * sinTheta;
            GLfloat u = 1.0-(longNumber/longitude);
            GLfloat v = latNumber/latitude;
            
            normalData[ positionNormal++ ] = x;
            normalData[ positionNormal++ ] = y;
            normalData[ positionNormal++ ] = z;
            
            texCoordData[ positionTexCoord++ ] = u;
            texCoordData[ positionTexCoord++ ] = v;
            
            geometryData[ positionGeometry++ ] = radius * x;
            geometryData[ positionGeometry++ ] = radius * y;
            geometryData[ positionGeometry++ ] = radius * z;
        }
    }
    
    for (GLushort latNumber = 0; latNumber < latitude; ++latNumber) 
    {
        for (GLushort longNumber = 0; longNumber < longitude; ++longNumber)
        {
            GLushort first = (latNumber * (longitude+1)) + longNumber;
            GLushort second = first + longitude + 1;
            
            // Reverse the image.
            indexData[ positionIndex++ ] = first + 1;
            indexData[ positionIndex++ ] = second;
            indexData[ positionIndex++ ] = first ;
            
            indexData[ positionIndex++ ] = first + 1;
            indexData[ positionIndex++ ] = second + 1;
            indexData[ positionIndex++ ] = second;    
        }
    }
    
    glGenBuffers(1, &m_buffers.NormalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.NormalBuffer);
    glBufferData(GL_ARRAY_BUFFER, normalDataLength * sizeof(GLfloat),
                 normalData, GL_STATIC_DRAW);
    
    glGenBuffers(1, &m_buffers.VertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.VertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, geometryDataLength * sizeof(GLfloat),
                 geometryData, GL_STATIC_DRAW);
    
    glGenBuffers(1, &m_buffers.TexCoordBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_buffers.TexCoordBuffer);
    glBufferData(GL_ARRAY_BUFFER, texCoordDataLength * sizeof(GLfloat),
                 texCoordData, GL_STATIC_DRAW);
        
    glGenBuffers(1, &m_buffers.IndexBuffer);
    m_buffers.IndexCount = indexDataLength;
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_buffers.IndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexDataLength * sizeof(GLushort),
                 indexData, GL_STREAM_DRAW);
    
    return true;
    
}

/////////////////////////////////////////
// Protocol Implementations
- (void) setProgram: (GLuint) newProgram
{
    program = newProgram;
}
    
- (GLuint) bindAttributes
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_NORMAL, "vNormal");
    glBindAttribLocation(program, ATTRIB_VERTEX, "vPosition");
    glBindAttribLocation(program, ATTRIB_TEXCOORD, "vTexCoord");
    
    return 0;
}

- (GLuint) setPostLinkUniforms
{
    if( program < 1 )
    {
        NSLog(@"Error: program variable not set");
        return GL_INVALID_VALUE;
    }
        
    m_attributes.Position = glGetAttribLocation(program, "vPosition");
    
    if( m_attributes.Position == -1 )
        NSLog(@"Failed to get attribute location for 'vPosition'");

    m_attributes.TextureCoord = glGetAttribLocation(program, "vTexCoord");
    
    if( m_attributes.TextureCoord == -1 )
        NSLog(@"Failed to get attribue location for vTexCoord");
    
    m_attributes.Normal = glGetAttribLocation(program, "vNormal");
    
    if( m_attributes.Normal == -1 )
        NSLog(@"Failed to get attribute location for 'vNormal'");
    
    m_uniforms.Projection = glGetUniformLocation(program, "Projection");
    
    if( m_uniforms.Projection == -1 )
        NSLog(@"Failed to get uniform location for 'Projection'" );
    
    m_uniforms.Modelview = glGetUniformLocation(program, "Modelview");
    
    if( m_uniforms.Modelview == -1 )
        NSLog(@"Failed to get uniform location for 'Modelview'");
    
    m_uniforms.NormalMatrix = glGetUniformLocation(program, "Normal");
    
    if( m_uniforms.NormalMatrix == -1 )
        NSLog(@"Failed to get uniform location for 'Normal'");
              
    m_uniforms.StartRad = glGetUniformLocation(program, "StartRad");
    
    if( m_uniforms.StartRad == -1 )
        NSLog(@"Failed to get uniform for 'StartRad'");
    
    m_uniforms.Sampler = glGetUniformLocation(program, "Sampler");
    
    if( m_uniforms.Sampler == -1 )
        NSLog(@"Failed to get uniform location for 'Sampler'");

    m_uniforms.Percentage = glGetUniformLocation(program, "Percentage");
    
    if( m_uniforms.Percentage == -1 )
        NSLog(@"Failed to get uniform location for 'Percentage'");
    
    glUniform1i(m_uniforms.Sampler, 0);

    return GL_NO_ERROR;
}

@end
