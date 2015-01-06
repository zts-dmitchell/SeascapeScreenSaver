//
//  ImageLoader.m
//  Noise Image
//
//  Created by David Mitchell on 2/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageLoader.h"
@import AppKit;

@implementation ImageLoader

+ (unsigned int) nextPowerOfTwo: (unsigned int) n
{
    n--;
    n |= n >> 1; n |= n >> 2;
    n |= n >> 4; n |= n >> 8;
    n |= n >> 16;
    n++;
    return n;
}

+ (ImageData*) load: (NSString*) path withShouldFlipVertical: (BOOL) shouldFlipVertical
{
    if( shouldFlipVertical )
        NSLog(@"shouldFlipVertical not implemented");
    
	NSImage *image;
    
    image = [[NSImage alloc] initWithContentsOfFile:path];
    
    NSLog(@"Width: %f, Height: %f", image.size.height, image.size.height);
    
    NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    
    NSLog(@"Getting bytes");
    unsigned char* bytes = [imageRep bitmapData];
    //int bitsPerPixel  = [imageRep bitsPerPixel];
    
    NSLog(@"Creating 'ImageData' instance");
    ImageData * imageData = (ImageData*) calloc(sizeof(ImageData*), 1);
    
    imageData->width  = image.size.width;
    imageData->height = image.size.height;
    imageData->bytes  = bytes;
    
    NSLog(@"Returning 'imageData'.  Is 'bytes' nil? %d", (bytes==nil));
    return imageData;

    /*
    int nextPo2Width = [self nextPowerOfTwo:image.size.width];
    int nextPo2Height = [self nextPowerOfTwo:image.size.height];
    
    int bitsPerComponent = 8;
    int bpp = bitsPerComponent / 2;
    int byteCount = nextPo2Width * nextPo2Height * bitsPerComponent;
    unsigned char* data = (unsigned char*) calloc(byteCount, 1);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmatInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context2 = CGBitmapContextCreate(data,
                                                  nextPo2Width,
                                                  nextPo2Height,
                                                  bitsPerComponent,
                                                  bpp * nextPo2Width,
                                                  colorSpace,
                                                  bitmatInfo);
    
    CGColorSpaceRelease(colorSpace);
    CGRect rect = CGRectMake(0, 0, nextPo2Width, nextPo2Height);
    CGImageSourceRef imageRef =  nsImageToCGImageRef(image);
    
    // data gets written to after this call:
    //CGContextDrawImage(context2, rect, imageRef);
    
    CGContextRelease(context2);
    
    ImageData * imageData = (ImageData*) calloc(sizeof(ImageData*), 1);
    
    imageData->width  = image.size.width;
    imageData->height = image.size.height;
    imageData->bytes  = data;
    
	return imageData;
     */
}

CGImageSourceRef nsImageToCGImageRef(NSImage* image)
{
    NSData* cocoaData = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [image representations]];
    CFDataRef carbonData = (__bridge CFDataRef)cocoaData;
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(carbonData, NULL);
    return imageSourceRef;
}

+ (void) freeImage: (ImageData*) image
{
    if( image )
    {
        free( image->bytes );
        free( image );
    }
}

@end


NSBitmapImageRep *LoadImage(NSString *path, int shouldFlipVertical)
{
    NSBitmapImageRep *bitmapimagerep;
    NSImage *image;
    image = [[NSImage alloc] initWithContentsOfFile: path];
    
    bitmapimagerep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    
    if (shouldFlipVertical)
    {
        long bytesPerRow, lowRow, highRow;
        unsigned char *pixelData, *swapRow;
        
        bytesPerRow = [bitmapimagerep bytesPerRow];
        pixelData = [bitmapimagerep bitmapData];
        
        swapRow = (unsigned char *)malloc(bytesPerRow);
        for (lowRow = 0, highRow = [bitmapimagerep pixelsHigh]-1; lowRow < highRow; lowRow++, highRow--)
        {
            memcpy(swapRow, &pixelData[lowRow*bytesPerRow], bytesPerRow);
            memcpy(&pixelData[lowRow*bytesPerRow], &pixelData[highRow*bytesPerRow], bytesPerRow);
            memcpy(&pixelData[highRow*bytesPerRow], swapRow, bytesPerRow);
        }
        free(swapRow);
    }
    
    return bitmapimagerep;
}

