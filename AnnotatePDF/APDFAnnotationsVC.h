//
//  APDFAnnotationsVC.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 A View Controller displaying a list of all Annotations of the current PDF page 
 */
@interface APDFAnnotationsVC : UITableViewController{
//    NSMutableArray *annotations;
}

/** 
 A Mutable array holding the annotations of the current PDF page 
 */
@property(nonatomic,retain)NSMutableArray* annotations;

/**
 Initializes a new View Controller with the specified annotations 
 @param annots The Annotations to display
 @returns The newly initialized View Controller
 */
-(id)initWithAnnotations:(NSMutableArray*)annots;

@end
