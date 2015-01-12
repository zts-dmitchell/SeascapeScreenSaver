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
#import "MountainsRenderer.h"
#import "SomewhereIn1993Renderer.h"
#import "SymmetricOriginsRenderer.h"
#import "MorningCityRenderer.h"

#import <OpenGL/gl.h>

@interface SeascapeScreenSaverView(PrivateMethods)
@property (nonatomic, assign) NSSize screenSize;
@end

@implementation SeascapeScreenSaverView

const int g_countOfRenderers = 2; // Disable the Mountains.3;

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
        //self.renderer = [self nextRenderer];
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

    if(++self.frameNumber % 100 == 0) {
        //NSLog(@"Number of frames for %@ so far: %lu", [self.renderer name], self.frameNumber);

        [self stopAnimation];
        
        [self.rendererIterator setNext];
        //self.renderer = [self nextRenderer];
        //NSLog(@"Switched to new renderer: %@", [self.renderer name]);

        [self startAnimation];
    }
    
    //[self.renderer render];
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
    
    //if(self.renderer != nil)
        //[self.renderer setFrameSize:newSize];
    [self.rendererIterator setFrameSize:newSize];
}

#pragma mark Iterater Stuff
/*
-(id<ESRenderer>) nextRenderer {

        self.renderer = nil;

    switch(self.currentRendererId++ % g_countOfRenderers) {
        case 2:
            self.renderer = [[MountainsRenderer alloc] init];
            break;
            
        case 1:
            self.renderer = [[WobblerRenderer alloc] init];
            break;
            
        default:
            NSLog(@"Unknown renderer"); // Fall through
        //case 0: self.renderer = [[SeascapeRenderer alloc] init];
        //case 0: self.renderer = [[SymmetricOriginsRenderer alloc] init];
        //case 0: self.renderer = [[SomewhereIn1993Renderer alloc] init];
        case 0: self.renderer = [[MorningCityRenderer alloc] init];
            
    }
    
    [self.renderer setFrameSize:self.screenSize];
    
    return self.renderer;
}
 */
@end
