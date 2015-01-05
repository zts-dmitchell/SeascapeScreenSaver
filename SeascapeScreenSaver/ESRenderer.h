//
//  Renderer.h
//  Earth Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@protocol ESRenderer <NSObject>

- (void)setFrameSize:(NSSize)newSize;
- (void)render;
//- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end
