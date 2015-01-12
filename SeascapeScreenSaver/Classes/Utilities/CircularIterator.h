//
//  CircularIterator.h
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#ifndef SeascapeScreenSaver_CircularIterator_h
#define SeascapeScreenSaver_CircularIterator_h

#import "CircularIteratorProtocol.h"

@interface CircularIterator : NSObject <CircularIteratorProtocol>

-(id) init;
-(void) addObject:(NSString*) className;
-(id) next;

@property(nonatomic, strong) NSMutableArray* objects;
@property(nonatomic, assign) int position;
@end


/*
    NSMutableArray* mutableArrayOfStuff = [[NSMutableArray alloc] init];
 
    ESRenderer* rend = [[SomeRenderer alloc] initWithSize:screenSize];
    [mutableArrayOfStuff addObject:rend];
 
    [mutableArrayOfStuff addObject:[[SomeRenderer alloc] init];
 
    // GnericCircularIterator is interface.
    CircularIteratorProtocol* cIter = [CircularIterator initWithArray:mutableArrayOfStuff];
 
    id thing = [cIter next];
    thing.whatever;
 

    // Extends CircularIterator
    ESRendererIterator rendererIter = [[ESRendererIterator alloc] init];
 
    // Optional. Should make sure renderer isn't already present.
    [rendererIter addRenderer: newRenderer];
 
    [rendererIter setScreenSize:screenSize];
 
    [rendererIter setNext];
 
    [rendererIter render];
 
 */
#endif
