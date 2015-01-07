CreateShader = function( gl, tvs, tfs, nativeDebug )
{
    if( gl==null ) return {mSuccess:false, mInfo:"no GL"};

    var tmpProgram = gl.createProgram();

    var vs = gl.createShader(gl.VERTEX_SHADER);
    var fs = gl.createShader(gl.FRAGMENT_SHADER);

    gl.shaderSource(vs, tvs);
    gl.shaderSource(fs, tfs);

    gl.compileShader(vs);
    gl.compileShader(fs);

    if (!gl.getShaderParameter(vs, gl.COMPILE_STATUS))
    {
        var infoLog = gl.getShaderInfoLog(vs);
        gl.deleteProgram( tmpProgram );
        return {mSuccess:false, mInfo:infoLog};
    }

    if (!gl.getShaderParameter( fs, gl.COMPILE_STATUS))
    {
        var infoLog = gl.getShaderInfoLog(fs);
        gl.deleteProgram( tmpProgram );
        return {mSuccess:false, mInfo:infoLog};
    }

    if( nativeDebug )
    {
    var dbgext = gl.getExtension("WEBGL_debug_shaders");
    if( dbgext != null )
    {
        var hlsl = dbgext.getTranslatedShaderSource( fs );
        console.log( "------------------------\nHLSL code\n------------------------\n" + hlsl + "\n------------------------\n" );
    }
    }

    gl.attachShader(tmpProgram, vs);
    gl.attachShader(tmpProgram, fs);

    gl.deleteShader(vs);
    gl.deleteShader(fs);

    gl.linkProgram(tmpProgram);

    if( !gl.getProgramParameter(tmpProgram,gl.LINK_STATUS) )
    {
        var infoLog = gl.getProgramInfoLog(tmpProgram);
        gl.deleteProgram( tmpProgram );
        return {mSuccess:false, mInfo:infoLog};
    }

    return {mSuccess:true, mProgram:tmpProgram};
}


function createGLTexture( ctx, image, format, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(   ctx.TEXTURE_2D, texture);
    ctx.pixelStorei(   ctx.UNPACK_FLIP_Y_WEBGL, false );
    ctx.texImage2D(    ctx.TEXTURE_2D, 0, format, ctx.RGBA, ctx.UNSIGNED_BYTE, image);
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.LINEAR);
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.LINEAR_MIPMAP_LINEAR);
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.REPEAT);
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.REPEAT);
    ctx.generateMipmap(ctx.TEXTURE_2D);
    ctx.bindTexture(ctx.TEXTURE_2D, null);
}

function createGLTextureLinear( ctx, image, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(  ctx.TEXTURE_2D, texture);
    ctx.pixelStorei(  ctx.UNPACK_FLIP_Y_WEBGL, false );
    ctx.texImage2D(   ctx.TEXTURE_2D, 0, ctx.RGBA, ctx.RGBA, ctx.UNSIGNED_BYTE, image);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.LINEAR);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.LINEAR);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.CLAMP_TO_EDGE);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.CLAMP_TO_EDGE);
    ctx.bindTexture(ctx.TEXTURE_2D, null);
}


function createGLTextureNearestRepeat( ctx, image, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(ctx.TEXTURE_2D, texture);
    ctx.pixelStorei( ctx.UNPACK_FLIP_Y_WEBGL, false );
    ctx.texImage2D(ctx.TEXTURE_2D, 0, ctx.RGBA, ctx.RGBA, ctx.UNSIGNED_BYTE, image);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.NEAREST);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.NEAREST);
    ctx.bindTexture(ctx.TEXTURE_2D, null);
}

function createGLTextureNearest( ctx, image, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(ctx.TEXTURE_2D, texture);
    ctx.pixelStorei( ctx.UNPACK_FLIP_Y_WEBGL, false );
    ctx.texImage2D(ctx.TEXTURE_2D, 0, ctx.RGBA, ctx.RGBA, ctx.UNSIGNED_BYTE, image);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.NEAREST);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.NEAREST);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.CLAMP_TO_EDGE);
    ctx.texParameteri(ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.CLAMP_TO_EDGE);

    ctx.bindTexture(ctx.TEXTURE_2D, null);
}

function createEmptyTextureNearest( gl, xres, yres )
{
    var tex = gl.createTexture();
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, xres, yres, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
    gl.bindTexture(gl.TEXTURE_2D, null);
    return tex;
}

function createAudioTexture( ctx, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(   ctx.TEXTURE_2D, texture );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.LINEAR );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.LINEAR );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.CLAMP_TO_EDGE );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.CLAMP_TO_EDGE) ;
    ctx.texImage2D(    ctx.TEXTURE_2D, 0, ctx.LUMINANCE, 512, 2, 0, ctx.LUMINANCE, ctx.UNSIGNED_BYTE, null);
    ctx.bindTexture(   ctx.TEXTURE_2D, null);
}

function createKeyboardTexture( ctx, texture )
{
    if( ctx==null ) return;

    ctx.bindTexture(   ctx.TEXTURE_2D, texture );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MAG_FILTER, ctx.NEAREST );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_MIN_FILTER, ctx.NEAREST );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_S, ctx.CLAMP_TO_EDGE );
    ctx.texParameteri( ctx.TEXTURE_2D, ctx.TEXTURE_WRAP_T, ctx.CLAMP_TO_EDGE) ;
    ctx.texImage2D(    ctx.TEXTURE_2D, 0, ctx.LUMINANCE, 256, 2, 0, ctx.LUMINANCE, ctx.UNSIGNED_BYTE, null);
    ctx.bindTexture(   ctx.TEXTURE_2D, null);
}

function deleteTexture( gl, tex )
{
      gl.deleteTexture( tex );
}


//============================================================================================================

function createQuadVBO( gl )
{
    var vertices = new Float32Array( [ -1.0, -1.0,   1.0, -1.0,    -1.0,  1.0,     1.0, -1.0,    1.0,  1.0,    -1.0,  1.0] );

    var vbo = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, vbo );
    gl.bufferData( gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW );
    gl.bindBuffer( gl.ARRAY_BUFFER, null );

    return vbo;
}

//============================================================================================================

function createFBO( gl, texture0 )
{
    var fbo = gl.createFramebuffer();
    gl.bindFramebuffer( gl.FRAMEBUFFER, fbo );
    gl.framebufferTexture2D( gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, texture0, 0 );
    gl.bindFramebuffer( gl.FRAMEBUFFER, null );

    return fbo;
}

function deleteFBO( gl, fbo )
{
    gl.deleteFramebuffer( fbo );
}


//============================================================================================================

function DetermineShaderPrecission( gl )
{
    var h1 = "#ifdef GL_ES\n" +
             "precision highp float;\n" +
             "#endif\n";

    var h2 = "#ifdef GL_ES\n" +
             "precision mediump float;\n" +
             "#endif\n";

    var h3 = "#ifdef GL_ES\n" +
             "precision lowp float;\n" +
             "#endif\n";

    var vstr = "void main() { gl_Position = vec4(1.0); }\n";
    var fstr = "void main() { gl_FragColor = vec4(1.0); }\n";

    if( CreateShader( gl, vstr, h1 + fstr, false).mSuccess==true ) return h1;
    if( CreateShader( gl, vstr, h2 + fstr, false).mSuccess==true ) return h2;
    if( CreateShader( gl, vstr, h3 + fstr, false).mSuccess==true ) return h3;

    return "";
}

