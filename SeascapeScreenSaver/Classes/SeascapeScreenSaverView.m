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

#import <OpenGL/gl.h>

@interface SeascapeScreenSaverView(PrivateMethods)
@property (nonatomic, assign) NSSize screenSize;
@end

@implementation SeascapeScreenSaverView

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
        
        self.frameNumber = 0;
        self.currentRendererId = 0;
        self.rendererIterator = [[ESRendererIterator alloc] init];
        // End New Code
        
        [self setAnimationTimeInterval:1/60.0];
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

    [self.glView.openGLContext makeCurrentContext];

    if(self.frameNumber++ % 10000 == 0) {
        NSLog(@"Number of frames for %@ so far: %lu", [self.rendererIterator getClassName], self.frameNumber);

        [self stopAnimation];
        
        [self.rendererIterator setNext];
        NSLog(@"Switched to new renderer: %@", [self.rendererIterator getClassName]);

        [self startAnimation];
    }
    
    [self.rendererIterator render];
    
    glFlush();
    [self setNeedsDisplay:YES];
}
#endif
- (void)setFrameSize:(NSSize)newSize
{
    self.screenSize = newSize;
    
    [super setFrameSize:newSize];
    [self.glView setFrameSize:newSize];
    
    [self.rendererIterator setFrameSize:newSize];
}

@end
