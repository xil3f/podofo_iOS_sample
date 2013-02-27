//
//  SimulatorHandling.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
This class contains wrapper functions that are necessary that the app runs on the simulator.
 */

// The part below until the start of the APDFAppDelegate is necessary to make the App run in the simulator
// start simulator part

#import <UIKit/UIKit.h>
#include <dirent.h>
#include <fnmatch.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

DIR * opendir$INODE64$UNIX2003( char * dirName );
struct dirent * readdir$INODE64( DIR * dir );
BOOL closedir$UNIX2003( DIR * dir );
int fnmatch$UNIX2003( const char * pattern, const char * string, int flags );
int write$UNIX2003( const void * buffer, size_t size, size_t count, FILE * stream );
FILE * fopen$UNIX2003( const char * fname, const char * mode );
FILE * open$UNIX2003( const char * fname, int mode );
int read$UNIX2003( FILE * fd, char * buffer, unsigned int n );
int close$UNIX2003( FILE * fd );
int stat$INODE64( const char * pcc, struct stat * pss );
int fcntl$UNIX2003( int fildes, int cmd, int one );
int fstat$INODE64( int filedes, struct stat * buf );
ssize_t pread$UNIX2003( int fildes, void *buf, size_t nbyte, off_t offset );
double strtod$UNIX2003( const char * str, char ** endptr );


DIR * opendir$INODE64$UNIX2003( char * dirName )
{
    return opendir( dirName );
}

struct dirent * readdir$INODE64( DIR * dir )
{
    return readdir( dir );
}

BOOL closedir$UNIX2003( DIR * dir )
{
    return closedir( dir );
}  

int fnmatch$UNIX2003( const char * pattern, const char * string, int flags )
{
    return fnmatch( pattern, string, flags );
}

int write$UNIX2003( const void * buffer, size_t size, size_t count, FILE * stream )
{
    return fwrite( buffer, size, count, stream );
}  

FILE * fopen$UNIX2003( const char * fname, const char * mode )
{
    return fopen( fname, mode );
}

FILE * open$UNIX2003( const char * fname, int mode )
{
    return ( FILE * ) open( fname, mode );
}

int read$UNIX2003( FILE * fd, char * buffer, unsigned int n )
{
    return read( ( int ) fd, buffer, n );
}      

int close$UNIX2003( FILE * fd )
{
    return close( ( int ) fd );
}      

int stat$INODE64( const char * pcc, struct stat * pss )
{
    return stat( pcc, pss );
}      

int fcntl$UNIX2003( int fildes, int cmd, int one )
{
    return fcntl( fildes, cmd, one );
}

int fstat$INODE64( int filedes, struct stat * buf )
{
    return fstat( filedes, buf );
}      

ssize_t pread$UNIX2003( int fildes, void *buf, size_t nbyte, off_t offset )
{
    return pread( fildes, buf, nbyte, offset );
}

double strtod$UNIX2003( const char * str, char ** endptr )
{
    return strtod( str, endptr );
}
// end simulator part