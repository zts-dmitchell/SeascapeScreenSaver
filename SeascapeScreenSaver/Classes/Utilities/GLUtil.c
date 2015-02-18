/*
 *  GLUtil.c
 *  Noise Image
 *
 *  Created by David Mitchell on 7/14/10.
 *  Copyright 2010-2015 David Mitchell. All rights reserved.
 *
 */
#import <OpenGL/gl.h>
#import <string.h>
#import <stdio.h>

int GLUtil_CheckExtension( const char* pExtensionToCheck )
{
    const char* pExtension = (const char*)glGetString( GL_EXTENSIONS );
    
    if( 0 == pExtension )
    {
        return 0;
    }

    if( 0 < strstr( pExtension, pExtensionToCheck ))
    {
        return 1;
    }
	
	printf("Extention check for %s: %s\n",
		   pExtensionToCheck, pExtension );
	
    return 0;
}

int printOglError(const char *file, int line)
{
    //
    // Returns 1 if an OpenGL error occurred, 0 otherwise.
    //
    GLenum glErr;
    int    retCode = 0;
    
    glErr = glGetError();
    while (glErr != GL_NO_ERROR)
    {
        //printf("glError in file %s @ line %d: %s\n", file, line, gluErrorString(glErr));
        printf("glError in file %s @ line %d: %d\n", file, line, glErr);
        retCode = 1;
        glErr = glGetError();
    }
    return retCode;
}
