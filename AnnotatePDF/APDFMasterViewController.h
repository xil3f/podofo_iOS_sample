//
//  APDFMasterViewController.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class APDFDetailViewController,DocWatchHelper;

/**
 The master view controller of the split view in this iPad app.
 It shows the content of the shared Documents directory of the app
 and lets the user select a PDF file
 */
@interface APDFMasterViewController : UITableViewController

/**
 The detail view controller of the split view in this iPad app
 */
@property (strong, nonatomic) APDFDetailViewController *detailViewController;

/**
 An Array with the paths to all PDF files in the shared Documents 
 directory
 */
@property (nonatomic, retain) NSArray* pathsArray;

/**
 The Notification Center that monitors the shared Documents 
 directory
 */
@property (nonatomic, retain) DocWatchHelper* helper;

/**
 Is called when the shared Documents directory changes
 @param notification The notification sent by the DocWatchHelper
 */
- (void) contentsChanged:(NSNotification *)notification;

@end
