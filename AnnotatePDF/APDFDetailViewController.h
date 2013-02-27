//
//  APDFDetailViewController.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APDFView.h"

@class PdfMemDocument,APDFNewAnnotationVC;

/**
 The detail view controller of the split view in this iPad app.
 It displays the PDF file.
 */
@interface APDFDetailViewController : UIViewController <UISplitViewControllerDelegate,APDFViewDelegate,UIScrollViewDelegate>{
    
    /** The filepath to the current PDF file */
    NSString *pdfPath;
    
    /** A PoDoFo::PdfMemDocument of the current PDF file */
    PdfMemDocument *doc;
}    

/** The PDF filepath to the current pdf file */
@property (strong, nonatomic) id detailItem;

/** The currently opened PDF file */
@property (nonatomic, readwrite) CGPDFDocumentRef myDocumentRef;

/** The index of the currently displayed page */
@property (nonatomic, readwrite) NSInteger currentPage;

/** The count of pages of the current pdf file */
@property (nonatomic, readwrite) NSInteger maxPages;

/** The APDFView that displays the current PDF page */
@property (nonatomic, retain) APDFView *pdfView;

/**
 The name of the current pdf file including its extension. This is 
 shown in the navigation bar 
 */
@property (nonatomic, retain) NSString *pdfName;

/** The filepath of the temporary copy of the current pdf file */
@property (nonatomic, retain) NSString *temporaryFilePath;

/** The popover that shows the new annotations view controller */
@property (nonatomic, retain) UIPopoverController *nAnnotsPopover;

/** The type of a new annotation */
@property(nonatomic,retain) NSString *annotType;

/** NSNumber with BOOL value if border is on or off for a new annotation */
@property(nonatomic,retain) NSNumber* withBorder;

/** NSNumber with double value of the borderWidth of a new annotation */
@property(nonatomic,retain) NSNumber* borderWidth;

/** The color of the new Annotation */
@property(nonatomic,retain) UIColor *annotColor;

/**
 Returns the PoDoFo::PdfMemDocument of the current pdf file
 @returns The PoDoFo::PdfMemDocument of the current pdf file
 */
-(PdfMemDocument*)getDoc;

/**
 Reloads the master view controller showing the Annotations
 */
-(void)reloadAnnotationsVC;

/**
 Lets the view controller with the annotations push to the master view controller
 */
-(void)showAnnotationsVC;

/**
 Updates the title in the navigation bar with the style: currentPdf.pdf [1/3]
 That means the current pdf file's name is currentPdf.pdf and currently page 
 1 of 3 is displayed
 */
-(void)updateTitle;

/**
 Is performed by the action button in the navigation bar and toggels if 
 the new annotations popover should appear or disappear. If the popover is 
 already visible the popover gets dismissed else the new annotations view 
 controller gets shown
 @param sender The Button that triggered the event
 */
-(IBAction)showNewAnnotationsVC:(id)sender;

/**
 Initializes the values for annotType, withBorder, borderWidth and annotColor to
 default values
 */
-(void)initializeNewAnnotsValues;

@end
