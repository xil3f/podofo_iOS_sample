//
//  APDFView.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResizableTextView.h"

/**
 Informs the delegate that the previous or next page has to be shown
 */
@protocol APDFViewDelegate <NSObject>

/**
 The Next page should be displayed
 */
- (void) didTouchNextPage;

/**
 The previous page should be displayed
*/
- (void) didTouchPrevPage;

@end

@class APDFDetailViewController;

/**
 The View that displays the PDF page and creates new Annotations
 */
@interface APDFView : UIView<UIGestureRecognizerDelegate,UITextViewDelegate> {
    
    /**
     The Point in the view where the PDF page starts
     */
    CGPoint point;
    
    /**
     The active TextView during the creation of a new annotation. When there is no 
     creation active it should be nil
     */
    ResizableTextView *annotTextView;
    
    /**
     The DetailViewController of the SplitView of this iPad App. This ViewController displays 
     this APDFView
     */
    APDFDetailViewController* detailVC;
    
    /**
     The point where a new annotation starts during the creation of a new square annotation.
     */
    CGPoint nAnnotStartPoint;
    
    /**
     Contains on position 0: zoom of the scrollView as float NSNumber, position 1 and 2 are offset x and offset y of the scrollView as float NSNumber. If this array is not nil, the scrollViews zoom parameters will be set to these values after rendering.
     */
    NSArray *zoomValues;
}

/**
 The index of the current page that is displayed
 */
@property (nonatomic, readwrite) NSInteger currentPage;

/**
 The PDF document that is active (a page of it is displayed)
 */
@property (nonatomic, readwrite) CGPDFDocumentRef myDocumentRef;

/**
 The PDF page that is displayed
 */
@property (nonatomic, readwrite) CGPDFPageRef pdfPage;

/**
 The rect that recognices a tap and then performs an action to display the next page
 */
@property (nonatomic, readwrite) CGRect nextPageRect;

/**
 The rect that recognices a tap and then performs an action to display the previous page
 */
@property (nonatomic, readwrite) CGRect prevPageRect;

/**
 The filepath to the active PDF file
 */
@property (nonatomic, retain) NSString *pdfPath;

/**
 The delegate of the APDFView
 */
@property (nonatomic, assign) id<APDFViewDelegate> delegate;

/**
 The scale of the PDF page to match into the APDFView
 */
@property float pdfScale;

/**
 Displays page with specified index of the current PDF file 
 @param pageNum The page index
 */
- (void) displayPDFPageNumber:(NSInteger)pageNum;

/**
 Calculates the nextPageRect and prevPageRect in dependence of the view size
 */
- (void) calculateTouchZones;

/**
 Reloads the parameters myDocumentRef and pdfPage in dependence of pdfPath and currentPage
 */
- (void) reloadPdf;

/**
 Checks if a specified point is in the area where the PDF page is displayed
 @param location The point that has to be checked
 @returns YES if the point is inside, NO if the point is outside
 */
- (BOOL) locationInPdfView:(CGPoint)location;

/**
 Takes a specified view that is a subview of the APDFView and calculates its coordinates 
 in the PDF page
 @param view A subview of the APDFView
 @returns The rect of the specified view in the PDF page
 */
- (CGRect)frameInPdfForView:(UIView*)view;

/**
 Adds a Done Button to the NavigationBar with that the creation of a FreeText annotation 
 can be finished on the iPhone.
 */
- (void) showDoneButton;

/**
 Stops the creation of the current FreeText annotation by resigning its first responder on the iPhone.
 */
- (void) finishAnnotCreation:(id)sender;

/**
 Sets the zoom of the scrollView displaying the pdf file to the values defined in zoomValues
 */
- (void)restoreScrollViewZoom:(NSArray*)zoomValues;

@end
