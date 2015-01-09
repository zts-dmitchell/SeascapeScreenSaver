/*
 *  GLUtil.h
 *  Noise Image
 *
 *  Created by David Mitchell on 7/14/10.
 *  Copyright 2010 None, Inc. All rights reserved.
 *
 */

#ifdef __cplusplus
extern "C" {
#endif

int GLUtil_CheckExtension( const char* pExtensionToCheck );

// Utility Functions
#if 0
#define printOpenGLError() printOglError(__FILE__, __LINE__)
#else
#define printOpenGLError()
#endif

int printOglError(const char * file, int line);

#ifdef __cpluspus
}
#endif