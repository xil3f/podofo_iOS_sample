//
//  APDFDetailViewController.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 6/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFDetailViewController.h"
#import "PDFPageRenderer.h"
#import "podofo.h"
#import "APDFManager.h"
#import "APDFAnnotationsVC.h"
#import "APDFAppDelegate.h"
#import "APDFNewAnnotationVC.h"
#import "APDFAnnotation.h"

@interface APDFDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation APDFDetailViewController

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize myDocumentRef;
@synthesize currentPage;
@synthesize pdfView;
@synthesize maxPages;
@synthesize pdfName;
@synthesize temporaryFilePath;
@synthesize nAnnotsPopover;
@synthesize annotType,annotColor,withBorder,borderWidth;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem && ![_detailItem isEqualToString:newDetailItem]) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }else{
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self showAnnotationsVC];
        }
    }

//    if (self.masterPopoverController != nil) {
//        [self.masterPopoverController dismissPopoverAnimated:YES];
//    }    
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem && ![self.detailItem isEqualToString:@""]) {
        
        UIScrollView * scrollView=(UIScrollView *) self.view;
        [scrollView setZoomScale:1.0];
        
        CFURLRef pdfURL = (CFURLRef)[NSURL fileURLWithPath:self.detailItem];
        myDocumentRef = CGPDFDocumentCreateWithURL(pdfURL);
        
        maxPages = CGPDFDocumentGetNumberOfPages(myDocumentRef);
        
        [self.pdfView removeFromSuperview];
        self.pdfView = nil;
        APDFView *tmpView = [[APDFView alloc] initWithFrame:self.view.frame];
        self.pdfView = tmpView;
        [tmpView release];
        
        self.pdfView.pdfPath = self.detailItem;
        self.pdfView.delegate = self;
        [self.pdfView reloadPdf];
        
        //add pdfView to default view as a subview
        [self.view addSubview:pdfView];
        
        [pdfView calculateTouchZones];
        
        self.currentPage = 1;
        [pdfView displayPDFPageNumber:1];
        
        doc = [APDFManager createPdfForFileAtPath:self.detailItem];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self showAnnotationsVC];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *scrollView =[[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    
    scrollView.minimumZoomScale=1.0;//0.25;
    
    scrollView.maximumZoomScale=6.0;//5.0;
    
    scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    scrollView.delegate = self;
    self.view=nil;
    self.view = scrollView;
    _detailItem = @"";
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        [APDFManager createCopy];
    }
    [self initializeNewAnnotsValues];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    UIScrollView * scrollView=(UIScrollView *) self.view;
    scrollView.maximumZoomScale = 1.0;
    [scrollView setZoomScale:1.0];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    UIScrollView * scrollView=(UIScrollView *) self.view ;
    scrollView.contentSize = scrollView.frame.size;
    pdfView.frame = scrollView.frame;
    [pdfView setNeedsDisplay];
    scrollView.maximumZoomScale = 6;
    
    [self.pdfView calculateTouchZones];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

-(void)dealloc{
    [pdfPath release];
    [temporaryFilePath release];
    [pdfView release];
    pdfView = nil;
    [nAnnotsPopover release];
    [annotColor release];
    [annotType release];
    [withBorder release];
    [borderWidth release];
    
    CGPDFDocumentRelease(myDocumentRef);
    [super dealloc];
}

#pragma -
#pragma APDFViewDelegate methods

- (void) didTouchNextPage {
    NSLog(@"Did touch next page");
    
    if(currentPage < maxPages) {
        currentPage = currentPage+1;
        UIScrollView * scrollView=(UIScrollView *) self.view;
        [scrollView setZoomScale:1.0];
        [pdfView displayPDFPageNumber:currentPage];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self reloadAnnotationsVC];
        }
        [self updateTitle];
    }
    
}


- (void) didTouchPrevPage {
    NSLog(@"Did touch prev page");
    
    if(currentPage > 1) {
        currentPage = currentPage - 1;
        UIScrollView * scrollView=(UIScrollView *) self.view;
        [scrollView setZoomScale:1.0];
        [pdfView displayPDFPageNumber:currentPage];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self reloadAnnotationsVC];
        }
        [self updateTitle];
    }
}

//scrollview delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView

{
    return self.pdfView;
}

-(PdfMemDocument *)getDoc{
    return doc;
}

-(void)reloadAnnotationsVC{
    APDFAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    UISplitViewController *splitViewController = (UISplitViewController *)appDelegate.window.rootViewController;
    UINavigationController *masterNC = [splitViewController.viewControllers objectAtIndex:0];
    if([[masterNC topViewController] isKindOfClass:[APDFAnnotationsVC class]]){
        NSMutableArray* annots = [APDFManager getAnnotationsArrayForPage:self.pdfView.pdfPage];
        APDFAnnotationsVC *annotsVC = (APDFAnnotationsVC*)[masterNC topViewController];
        annotsVC.annotations = annots;
        [annotsVC.tableView reloadData];
    }
}

-(void)showAnnotationsVC{
    APDFAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    UISplitViewController *splitViewController = (UISplitViewController *)appDelegate.window.rootViewController;
    UINavigationController *masterNC = [splitViewController.viewControllers objectAtIndex:0];
    NSMutableArray* annots = [APDFManager getAnnotationsArrayForPage:self.pdfView.pdfPage];
    APDFAnnotationsVC *annotsVC = [[APDFAnnotationsVC alloc] initWithAnnotations:annots];
    [masterNC pushViewController:annotsVC animated:YES];
    [annotsVC release];
}

-(void)updateTitle{
    self.title = [self.pdfName stringByAppendingFormat:@" [%i/%i]",currentPage,maxPages];
}

-(void)showNewAnnotationsVC:(id)sender{
    if ([nAnnotsPopover isPopoverVisible]) {
        [nAnnotsPopover dismissPopoverAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"showNewAnnots" sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showNewAnnots"]) {
        UINavigationController *navController = (UINavigationController*)segue.destinationViewController;
        APDFNewAnnotationVC *nAnnotsVC = (APDFNewAnnotationVC*)[navController topViewController];
        nAnnotsVC.annotType = self.annotType;
        nAnnotsVC.withBorder = self.withBorder;
        nAnnotsVC.borderWidth = self.borderWidth;
        nAnnotsVC.annotColor = self.annotColor;
        [nAnnotsVC initUIElements];
        
        [nAnnotsVC addObserver:self forKeyPath:@"annotType" options:0 context:nil];
        [nAnnotsVC addObserver:self forKeyPath:@"withBorder" options:0 context:nil];
        [nAnnotsVC addObserver:self forKeyPath:@"borderWidth" options:0 context:nil];
        [nAnnotsVC addObserver:self forKeyPath:@"annotColor" options:0 context:nil];
        
        [nAnnotsPopover release];
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue*)segue;
        nAnnotsPopover = [[popoverSegue popoverController] retain];
    }
}

-(void)initializeNewAnnotsValues{
    self.annotType = ANNOT_FREE_TEXT;
    self.withBorder = [NSNumber numberWithBool:NO];
    self.borderWidth = [NSNumber numberWithDouble:1.0];
    self.annotColor = [UIColor blackColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {       
    APDFNewAnnotationVC *nAnnotsVC = (APDFNewAnnotationVC*)object;
    if ([keyPath isEqualToString:@"annotType"]) {
        self.annotType = nAnnotsVC.annotType;
    }
    if ([keyPath isEqualToString:@"withBorder"]) {
        self.withBorder = nAnnotsVC.withBorder;
    }
    if ([keyPath isEqualToString:@"borderWidth"]) {
        self.borderWidth = nAnnotsVC.borderWidth;
    }
    if ([keyPath isEqualToString:@"annotColor"]) {
        self.annotColor = nAnnotsVC.annotColor;
    }
}

@end
