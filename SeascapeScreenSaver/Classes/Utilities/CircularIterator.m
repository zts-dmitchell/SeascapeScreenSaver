//
//  CircularIterator.m
//  SeascapeScreenSaver
//
//  Created by David Mitchell on 1/11/15.
//  Copyright (c) 2015 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircularIterator.h"

@implementation CircularIterator

-(id) init {
    
    self = [super init];
    
    if(self != nil) {
        
        self.objects = [[NSMutableArray alloc] init];
        self.position = 0;
    }
    
    return self;
}

-(void) addObject:(NSString*) className {

    NSLog(@"Adding class: %@", className);
    [self.objects addObject:className];
}

-(id) next {
    
    int count = (int)self.objects.count;
    
    return [self.objects objectAtIndex:self.position++ % count];
}

-(unsigned long) count {
    return [self.objects count];
}

@end

