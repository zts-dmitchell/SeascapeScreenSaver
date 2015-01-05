//
//  SeascapeScreenSaverView.h
//  SeascapeScreenSaver
//
//  Based on: http://www.alejandrosegovia.net/2013/09/02/writing-a-mac-os-x-screensaver/
//
//  Created by David Mitchell on 1/4/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "SeascapeRenderer.h"

@interface SeascapeScreenSaverView : ScreenSaverView

@property (nonatomic, retain) NSOpenGLView* glView;
@property (nonatomic, strong) SeascapeRenderer* renderer;

- (NSOpenGLView*) createGLView;

@end
