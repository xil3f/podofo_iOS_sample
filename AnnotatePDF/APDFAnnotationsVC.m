//
//  APDFAnnotationsVC.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFAnnotationsVC.h"
#import "APDFAnnotation.h"
#import "APDFManager.h"
#import "APDFView.h"
#import "APDFDetailViewController.h"
#import "APDFAppDelegate.h"


@implementation APDFAnnotationsVC

@synthesize annotations;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Annotations";
    }
    return self;
}

-(id)initWithAnnotations:(NSMutableArray*)annots{
    self = [super init];
    if (self) {
        self.annotations = annots;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([annotations count]>0) {
        return [annotations count];
    }
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if ([annotations count]>0) {
        NSInteger row = indexPath.row;
        APDFAnnotation *annot = (APDFAnnotation *)[annotations objectAtIndex:row];
        cell.textLabel.text = [annot annotationType];
        if ([annot.annotationType isEqualToString:ANNOT_FREE_TEXT]) {
            cell.textLabel.textColor = annot.textColor; 
            cell.detailTextLabel.text = annot.textString;
        }else{
            cell.textLabel.textColor = annot.annotColor;
            cell.detailTextLabel.text = @"";
        }
    }else{
        cell.textLabel.text = @"no annotations on this page";
        cell.textLabel.textColor = [UIColor lightGrayColor]; 
        cell.detailTextLabel.text = @"";
    }
        
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        APDFAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UISplitViewController *splitViewController = (UISplitViewController *)appDelegate.window.rootViewController;
        APDFDetailViewController *detailVC = (APDFDetailViewController *)splitViewController.delegate;
        
        [APDFManager deleteAnnotationWithIndex:indexPath.row onPage:detailVC.pdfView.currentPage-1 ofDoc:[detailVC getDoc]];
        [annotations removeObjectAtIndex:indexPath.row];

        [APDFManager writePdf:[detailVC getDoc] toPath:detailVC.detailItem withTemporaryFilePath:detailVC.temporaryFilePath];
        
        [detailVC.pdfView reloadPdf];
        [detailVC.pdfView setNeedsDisplay];
        if (!([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]])) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [self.tableView reloadData];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dealloc{
    [annotations release];
    [self release];
}

@end
