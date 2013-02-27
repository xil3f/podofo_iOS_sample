//
//  DocWatchHelper.h
//  AnnotatePDF
//
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#define kDocumentChanged @"DocumentsFolderContentsDidChangeNotification"
/**
 A class used to monitor a file directory and to send notifications when changes occure
 */
@interface DocWatchHelper : NSObject
{
    CFFileDescriptorRef kqref;
    CFRunLoopSourceRef rls;
}
@property (strong) NSString *path;
+ (id) watcherForPath: (NSString *) aPath;
@end