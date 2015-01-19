//
//  ShaderUtil.m
//  Earth Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShaderUtil.h"
#import <OpenGL/gl.h>
#import "GLUtil.h"

#define DEBUG

@interface ShaderUtil (PrivateMethods)
+ (BOOL)compileShader;
+ (BOOL)linkProgram:(GLuint)prog;
@end


@implementation ShaderUtil

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    NSLog(@"Compiling shader: %@", file);
    
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load %d shader: %@", type, file);
        return FALSE;
    } else {
        NSLog(@"Loaded shader");
    }
    
    *shader = glCreateShader(type); printOpenGLError();
    glShaderSource(*shader, 1, &source, NULL); printOpenGLError();
    glCompileShader(*shader); printOpenGLError();
    
    GLint vertex_compiled;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &vertex_compiled);
    if (vertex_compiled != GL_TRUE)
    {
        GLsizei log_length = 0;
        GLchar message[1024];
        glGetShaderInfoLog(*shader, 1024, &log_length, message);
        // Write the error to a log
        NSLog(@"Shader compile log: %s", message);
    }
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

+ (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

+ (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

+ (GLuint)loadShaders: (NSString*) fragmentShader
       andFragmentExt: (NSString*) fragmentExt
       withAttributes: (id <Attributes>) attribute
{
    return [ShaderUtil loadShaders:@"CommonVertexShader"
                     withVertexExt:@"vsh"
                 andFragmentShader:fragmentShader
                    andFragmentExt:fragmentExt
                    withAttributes:attribute];
}

/*
    Returns 0 on failure.
 */
+ (GLuint)loadShaders: (NSString*) vertexShader
        withVertexExt: (NSString*) vertexExt
    andFragmentShader: (NSString*) fragmentShader
       andFragmentExt: (NSString*) fragmentExt
       withAttributes: (id <Attributes>) attribute
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    GLuint program = glCreateProgram(); printOpenGLError();
    
    if(program == 0) {
        NSLog(@"glCreateProgram call failed with 0.  Is the context set?");
        return 0;
    }
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle bundleForClass:[self class]] pathForResource:vertexShader ofType:vertexExt];
    
    if (vertShaderPathname == nil) {
        NSLog(@"Nil getting path to vertex shader: %@.%@", vertexShader, vertexExt);
        glDeleteProgram(program);
        return 0;
    } else {
        NSLog(@"Got path to vertex shader: %@", vertShaderPathname);
    }
    
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader: %@.%@", vertexShader, vertexExt);
        glDeleteProgram(program);
        return 0;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle bundleForClass:[self class]] pathForResource:fragmentShader ofType:fragmentExt];
    
    NSString* fileInfo = [NSString stringWithFormat:@"Loading file: %@", fragShaderPathname];

    NSLog(fileInfo, fragShaderPathname);
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        glDeleteProgram(program);
        return 0;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    [attribute setProgram:program];
    
    // Bind attribute locations.
    // This needs to be done prior to linking(?).
    
    if ( [attribute respondsToSelector:@selector(bindAttributes)] )
    {
        if( [attribute bindAttributes] != GL_NO_ERROR )
        {
            glDeleteProgram(program);
            return 0;
        }
    }
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
        }
        
        return 0;
    }
    
    if( [attribute respondsToSelector:@selector(setPostLinkUniforms)] )
    {
        if( [attribute setPostLinkUniforms] != GL_NO_ERROR )
        {
            glDeleteProgram(program);
            program = 0;
        }
    }
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return program;
}

+ (void) cleanup: (GLuint)program
{
    if(program)
        glDeleteProgram(program);
}

@end
