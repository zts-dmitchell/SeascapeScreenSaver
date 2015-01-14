//
//  Attribute.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/12/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@protocol Attributes <NSObject>

- (void) setProgram: (GLuint) program;
@optional
- (GLuint) bindAttributes;
- (GLuint) setPostLinkUniforms;
@end
