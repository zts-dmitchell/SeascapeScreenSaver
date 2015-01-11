//
//  ShaderUtil.h
//  Earth Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#pragma once
#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@protocol Attributes <NSObject>

- (void) setProgram: (GLuint) program;
@optional
- (GLuint) bindAttributes;
- (GLuint) setPostLinkUniforms;
@end


@interface ShaderUtil : NSObject

+ (GLuint)loadShaders: (NSString*) vertexShader
        withVertexExt: (NSString*) vertexExt
    andFragmentShader: (NSString*) fragmentShader
       andFragmentExt: (NSString*) fragmentExt
       withAttributes: (id <Attributes>) attribute;

+ (GLuint)loadShaders: (NSString*) fragmentShader
       andFragmentExt: (NSString*) fragmentExt
       withAttributes: (id <Attributes>) attribute;

+ (BOOL)validateProgram: (GLuint)prog;
+ (void) cleanup: (GLuint)program;
@end

