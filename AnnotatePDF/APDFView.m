//
//  APDFView.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFView.h"
#import "APDFAppDelegate.h"
#import "PDFPageRenderer.h"
#import <QuartzCore/QuartzCore.h>
#import "APDFAnnotation.h"
#import "APDFDetailViewController.h"
#import "APDFManager.h"

#define TOUCHWIDTH  50

@implementation APDFView

@synthesize currentPage;
@synthesize myDocumentRef;
@synthesize pdfPage;
@synthesize nextPageRect;
@synthesize prevPageRect;
@synthesize delegate;
@synthesize pdfScale;
@synthesize pdfPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [tapGesture setNumberOfTouchesRequired:1];
        [tapGesture setNumberOfTapsRequired:1];
        tapGesture.delegate = self;
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.delegate = self;
        
        [self addGestureRecognizer:tapGesture];
        [self addGestureRecognizer:longPressGesture];
        [tapGesture release];
        [longPressGesture release];
        
        self.backgroundColor = [UIColor clearColor];
        
        pdfScale = 1;
        
        zoomValues = nil;
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    }
    return self;
}

- (void) calculateTouchZones {
    
    nextPageRect = CGRectMake(self.frame.size.width - TOUCHWIDTH, 0, TOUCHWIDTH, self.frame.size.height);
    prevPageRect = CGRectMake(0, 0, TOUCHWIDTH, self.frame.size.height);
    
}



- (void) displayPDFPageNumber:(NSInteger)pageNum {
    
    
    NSInteger maxPage;
    
    if(pageNum < 1)
        return;
    
    maxPage = CGPDFDocumentGetNumberOfPages(myDocumentRef);
    
    if(pageNum > maxPage)
        return;
    
    
    self.currentPage = pageNum;
    
    
    self.pdfPage = CGPDFDocumentGetPage(myDocumentRef, currentPage);
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPDFPageRef page = self.pdfPage;
    
    CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    int pageRotation = CGPDFPageGetRotationAngle(page);
    
    CGSize pageVisibleSize = CGSizeMake(cropBox.size.width, cropBox.size.height);
    if ((pageRotation == 90) || (pageRotation == 270) ||(pageRotation == -90)) {
        pageVisibleSize = CGSizeMake(cropBox.size.height, cropBox.size.width);
    }
    
    CGRect displayRectangle = self.frame;
    
    float scaleX = displayRectangle.size.width / pageVisibleSize.width;
    float scaleY = displayRectangle.size.height / pageVisibleSize.height;
    float scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Offset relative to top left corner of rectangle where the page will be displayed
    float offsetX = 0;
    float offsetY = 0;
    
    float rectangleAspectRatio = displayRectangle.size.width / displayRectangle.size.height;
    float pageAspectRatio = pageVisibleSize.width / pageVisibleSize.height;
    
    if (pageAspectRatio < rectangleAspectRatio) {
        // The page height is proportional larger than the view height, so it is placed at center on the horizontal
        offsetX = (displayRectangle.size.width - pageVisibleSize.width * scale) / 2;
    }
    else { 
        // The page width is proportional bigger than the view width, so it is placed at center on the vertical
        offsetY = (displayRectangle.size.height - pageVisibleSize.height * scale) / 2;
    }
    
    CGPoint topLeftPage = 
    CGPointMake(displayRectangle.origin.x + offsetX, displayRectangle.origin.y + offsetY);
    
    point = topLeftPage;

    [PDFPageRenderer renderPage:page inContext:ctx atPoint:topLeftPage withZoom:scale * 100];

    pdfScale = scale;
    
    if(zoomValues != nil){
        [self restoreScrollViewZoom:zoomValues];
        [zoomValues release];
        zoomValues = nil;
    }
}

#pragma -
#pragma Handle Gestures
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self];
        if ([self locationInPdfView:location]) {
            if ([detailVC.annotType isEqualToString:ANNOT_SQUARE]) {
                ResizableTextView *textView = [[ResizableTextView alloc] initWithFrame:CGRectMake(location.x, location.y, 5, 5)];
                [textView setBackgroundColor:[UIColor clearColor]];
                textView.layer.borderColor = detailVC.annotColor.CGColor;
                textView.layer.borderWidth = [detailVC.borderWidth doubleValue]*pdfScale;
                annotTextView = textView;
                [self addSubview:textView];
                nAnnotStartPoint = location;
            }else if([detailVC.annotType isEqualToString:ANNOT_FREE_TEXT]){
                ResizableTextView *textView = [[ResizableTextView alloc] initWithFrame:CGRectMake(location.x, location.y, 20, 20)];
                [textView setBackgroundColor:[UIColor clearColor]];
                textView.font = [UIFont fontWithName:@"Helvetica" size:pdfScale*13];
                textView.delegate = self;
                
                if ([detailVC.withBorder boolValue]) {
                    textView.layer.borderColor = detailVC.annotColor.CGColor;
                    textView.layer.borderWidth = [detailVC.borderWidth doubleValue]*pdfScale;
                }
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    annotTextView=textView;
                    [self showDoneButton];
                }
                
                [self addSubview:textView];
                [textView setEditable:YES];
                [textView becomeFirstResponder];
                [textView release];
            }
        }
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if([detailVC.annotType isEqualToString:ANNOT_SQUARE]){
            CGPoint location = [recognizer locationInView:self];
            CGFloat width = fabsf(location.x - nAnnotStartPoint.x);
            CGFloat height = fabsf(location.y - nAnnotStartPoint.y);
            CGFloat xValue = (location.x<nAnnotStartPoint.x) ? location.x : nAnnotStartPoint.x;
            CGFloat yValue = (location.y<nAnnotStartPoint.y) ? location.y : nAnnotStartPoint.y;
            [annotTextView setFrame:CGRectMake(xValue, yValue, width, height)];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([detailVC.annotType isEqualToString:ANNOT_SQUARE]) {
            UIScrollView *scrollView = (UIScrollView*)detailVC.view;
            CGRect frame = [self frameInPdfForView:annotTextView];
            [APDFManager createSquareAnnotationOnPage:currentPage-1 doc:[detailVC getDoc] rect:frame borderWidth:[detailVC.borderWidth doubleValue] title:@"AnnotatePDF" bOpen:YES color:detailVC.annotColor];
            [APDFManager writePdf:[detailVC getDoc] toPath:detailVC.detailItem withTemporaryFilePath:detailVC.temporaryFilePath];
            
            [annotTextView removeFromSuperview];
            annotTextView = nil;
            [self reloadPdf];
            
            CGFloat tmpZoom = scrollView.zoomScale;
            CGPoint tmpOffset = scrollView.contentOffset;
            NSArray* zoomvalues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:tmpZoom], [NSNumber numberWithFloat:tmpOffset.x], [NSNumber numberWithFloat:tmpOffset.y], nil];
            zoomValues = [zoomvalues retain];
            
            scrollView.zoomScale = 1.0;
            [self setNeedsDisplay];
            [detailVC reloadAnnotationsVC];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:self];
    
    if(CGRectContainsPoint(nextPageRect, location)) {
        
        if([delegate respondsToSelector:@selector(didTouchNextPage)])
            [delegate didTouchNextPage];
    }
    else {
        if(CGRectContainsPoint(prevPageRect, location)) {
            if([delegate respondsToSelector:@selector(didTouchPrevPage)])
                [delegate didTouchPrevPage];
        }
    }
}

-(void)dealloc{
    CGPDFDocumentRelease(myDocumentRef);
    [super dealloc];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (![textView.text isEqualToString:@""]) {
        UIScrollView *scrollView = (UIScrollView*)detailVC.view;
        CGRect frame = [self frameInPdfForView:textView];
        
        double bWidth = 0;
        if ([detailVC.withBorder boolValue]) {
            bWidth = [detailVC.borderWidth doubleValue];
        }
        [APDFManager createFreeTextAnnotationOnPage:currentPage-1 doc:[detailVC getDoc] rect:frame borderWidth:bWidth title:@"AnnotatePDF" content:textView.text bOpen:YES color:[UIColor blackColor]];
        [APDFManager writePdf:[detailVC getDoc] toPath:detailVC.detailItem withTemporaryFilePath:detailVC.temporaryFilePath];
        
        [textView removeFromSuperview];
        [self reloadPdf];
        
        CGFloat tmpZoom = scrollView.zoomScale;
        CGPoint tmpOffset = scrollView.contentOffset;
        NSArray* zoomvalues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:tmpZoom], [NSNumber numberWithFloat:tmpOffset.x], [NSNumber numberWithFloat:tmpOffset.y], nil];
        zoomValues = [zoomvalues retain];

        scrollView.zoomScale = 1.0;
        [self setNeedsDisplay];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [detailVC reloadAnnotationsVC];

        }else if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            annotTextView = nil;
        }
    }
    else{
        [textView removeFromSuperview];
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    if (textView.hasText) {//only adjust the size of the textView when there 
        //is text in it
        
        [textView setScrollsToTop:YES];
        [textView setScrollEnabled:NO];
        
        CGFloat size=textView.contentSize.width;
        NSLog(@"%f",size);
        
        CGRect frame = textView.frame;
        frame.size.height = textView.contentSize.height-6; 
        frame.size.width = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(INT64_MAX, INT64_MAX) lineBreakMode:UILineBreakModeMiddleTruncation].width + 25*pdfScale;
        textView.frame = frame;
    }
    else{//there is no text in the text view
        //set the default values if needed!
        
    }
}

-(void)reloadPdf{
    CFURLRef pdfURL = (CFURLRef)[NSURL fileURLWithPath:pdfPath];
    myDocumentRef = CGPDFDocumentCreateWithURL(pdfURL);
    self.pdfPage = CGPDFDocumentGetPage(myDocumentRef, currentPage);
}

-(BOOL)locationInPdfView:(CGPoint)location{
    CGRect pdfViewRect = CGRectMake(point.x, point.y, self.frame.size.width-2*point.x, self.frame.size.height-2*point.y);
    if (CGRectContainsPoint(pdfViewRect, location)) {
        return YES;
    }
    else return NO;
}

-(CGRect)frameInPdfForView:(UIView *)aView{
    UIScrollView *scrollView = (UIScrollView*)detailVC.view;
    CGFloat zoom = scrollView.zoomScale;
    
    CGRect cropBox = CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox);
    
    CGRect frame = aView.frame;
    
    frame.size.height = ((aView.frame.size.height) / pdfScale);
    frame.size.width = ((aView.frame.size.width) / pdfScale);
    
    frame.origin.x = (aView.frame.origin.x-point.x) * cropBox.size.width / (self.frame.size.width/zoom - 2* point.x);
    frame.origin.y = cropBox.size.height- (aView.frame.origin.y-point.y) * cropBox.size.height / (self.frame.size.height/zoom- 2* point.y)- frame.size.height;
    
    return frame;
}

-(void)setDelegate:(id<APDFViewDelegate>)aDelegate{
    // do not retain! This is an "assign" property
    delegate = aDelegate;

    detailVC = (APDFDetailViewController*)delegate;
}

-(void)showDoneButton{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishAnnotCreation:)];
    [detailVC.navigationItem setRightBarButtonItem:doneButton animated:YES];
    [doneButton release];
}

-(void)finishAnnotCreation:(id)sender{
    [annotTextView resignFirstResponder];
    [detailVC.navigationItem setRightBarButtonItem:nil animated:YES];
}

-(void)restoreScrollViewZoom:(NSArray*)values{
    CGFloat zoom=[(NSNumber*)[values objectAtIndex:0] floatValue];
    CGPoint offset = CGPointMake([(NSNumber*)[values objectAtIndex:1] floatValue],[(NSNumber*)[values objectAtIndex:2] floatValue]);
    UIScrollView *scrollView = (UIScrollView*)detailVC.view;
    scrollView.zoomScale=zoom;
    scrollView.contentOffset = offset;
}

@end
