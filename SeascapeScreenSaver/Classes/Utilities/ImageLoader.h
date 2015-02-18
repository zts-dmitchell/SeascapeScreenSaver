//
//  ImageLoader.h
//  Noise Image
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011-2015 David Mitchell. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef struct _ImageData
{
    int width;
    int height;
    unsigned char* bytes;
} ImageData;

#ifdef __cplusplus
extern "C" {
#endif
    
    
NSBitmapImageRep *LoadImage(NSString *path, int shouldFlipVertical);
#ifdef __cplusplus
}
#endif

@interface ImageLoader : NSObject {

}

+ (ImageData*) load: (NSString*) path
withShouldFlipVertical: (BOOL) shouldFlipVertical;
+ (void) freeImage: (ImageData*) image;

@end
