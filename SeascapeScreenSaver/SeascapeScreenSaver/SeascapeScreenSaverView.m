//
//  SeascapeScreenSaverView.m
//  SeascapeScreenSaver
//
//  Based on: http://www.alejandrosegovia.net/2013/09/02/writing-a-mac-os-x-screensaver/
//  Another tutorial: http://www.mactech.com/articles/mactech/Vol.21/21.06/SaveOurScreens/index.html
//
//  Created by David Mitchell on 1/4/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import "SeascapeScreenSaverView.h"
#import "SeascapeRenderer.h"
#import "WobblerRenderer.h"
#import <OpenGL/gl.h>

@implementation SeascapeScreenSaverView

id<ESRenderer> renderers[2];


- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        
        // New code:
        // Stuff from web
        self.glView = [self createGLView];
        [self addSubview:self.glView];
        
        // My stuff
        [self.glView.openGLContext makeCurrentContext];
        renderers[0] = [[SeascapeRenderer alloc] init];
        renderers[1] = [[WobblerRenderer alloc] init];
        
        self.frameNumber = 0;
        self.currentRendererId = 0;
        self.renderer = renderers[self.currentRendererId];
        // End New Code
        
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

// From the website:
- (NSOpenGLView *)createGLView
{
    NSOpenGLPixelFormatAttribute attribs[] = {
        NSOpenGLPFAAccelerated,
        0
    };
    
    NSOpenGLPixelFormat* format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    NSOpenGLView* glview = [[NSOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
    
    NSAssert(glview, @"Unable to create OpenGL view!");
    
    return glview;
}

- (void)dealloc
{
    [self.glView removeFromSuperview];
    self.glView = nil;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

#pragma mark Code from Website:

#ifdef ORIG_AOF
- (void)animateOneFrame
{
    [self.glView.openGLContext makeCurrentContext];
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    static float vertices[] = {
        1.0f, -1.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        -1.0f, -1.0f, 0.0f
        
    };
    
    static float colors[] = {
        1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 1.0f,
        0.0f, 0.0f, 1.0f
    };
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(3, GL_FLOAT, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    glFlush();
    [self setNeedsDisplay:YES];
    return;
}
#else
- (void)animateOneFrame {
    
    if(++self.frameNumber % 10000 == 0) {
        NSLog(@"Number of frames for %@ so far: %lu", [self.renderer name], self.frameNumber);

        [self.glView.openGLContext makeCurrentContext];
        
        [self stopAnimation];
        
        self.currentRendererId = !self.currentRendererId;
        self.renderer = renderers[self.currentRendererId];
        [self startAnimation];
    }
    
    [self.renderer render];
    
    glFlush();
    [self setNeedsDisplay:YES];
}
#endif

- (void)setFrameSize:(NSSize)newSize
{
    self.screenSize = newSize;
    [super setFrameSize:newSize];
    [self.glView setFrameSize:newSize];
    
    self.renderer = renderers[1];
    [self.renderer setFrameSize:newSize];
    self.renderer = renderers[0];
    [self.renderer setFrameSize:newSize];
}

@end
