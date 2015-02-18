//
//  Renderer.h
//  Earth Wobbler
//
//  Created by David Mitchell on 2/20/11.
//  Copyright (c) 2011 David Mitchell. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>

@protocol Renderer <NSObject>

- (void)setFrameSize:(NSSize)newSize;
- (void)render;
- (NSString*) name;

@end
