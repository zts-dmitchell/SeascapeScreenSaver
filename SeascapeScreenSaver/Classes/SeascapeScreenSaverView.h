//
//  SeascapeScreenSaverView.h
//  SeascapeScreenSaver
//
//  Based on: http://www.alejandrosegovia.net/2013/09/02/writing-a-mac-os-x-screensaver/
//  Another tutorial: http://www.mactech.com/articles/mactech/Vol.21/21.06/SaveOurScreens/index.html
//
//  Created by David Mitchell on 1/4/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "ESRenderer.h"
#import "RendererIterator.h"

@interface SeascapeScreenSaverView : ScreenSaverView

@property (nonatomic, retain) NSOpenGLView* glView;
@property (nonatomic, assign) int currentRendererId;
@property (nonatomic, assign) unsigned long frameNumber;
@property (nonatomic, assign) NSSize screenSize;
@property (nonatomic, assign) unsigned long iterationsPerRenderer;
@property (nonatomic, strong) RendererIterator* rendererIterator;
@property (nonatomic, strong) NSDictionary* properties;
- (NSOpenGLView*) createGLView;

@end
