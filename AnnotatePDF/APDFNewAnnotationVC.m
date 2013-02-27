//
//  APDFNewAnnotationVC.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFNewAnnotationVC.h"
#import "APDFAnnotation.h"

#define MAX_BorderWidth 3.0

#define MIN_BorderWidth 0.1

@implementation APDFNewAnnotationVC

@synthesize segmentedControl, colorCell, borderSwitch, borderSwitchCell, borderWidthCell;
@synthesize annotType,annotColor,withBorder,borderWidth;
@synthesize borderWidthTextField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.title = @"New Annotation";
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 287.0);
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
    return YES;
}

#pragma mark - Table view data source


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSString *text = [textField text];
    double number = [text floatValue];
    if (segmentedControl.selectedSegmentIndex==0)
    {
        if (!number || number>MAX_BorderWidth || number<0) {
            return NO;
        }
    }else{
        if (!number || number>MAX_BorderWidth || number<MIN_BorderWidth) {
            return NO;
        }
    }
    self.borderWidth = [NSNumber numberWithDouble:number];
    return YES;
}

#pragma mark - Custom UI methods
-(void)colorSelected:(id)sender{
    for (UIView *colorView in [[colorCell contentView] subviews]) {
        [colorView setBackgroundColor:[UIColor clearColor]];
    }
    UIButton *colorButton = (UIButton*)sender;
    [colorButton.superview setBackgroundColor:[UIColor cyanColor]];
    self.annotColor = [colorButton backgroundColor];
}

-(void)selectedSegmentChanged:(id)sender{
    if (segmentedControl.selectedSegmentIndex==0) {
        //select the black color because only black text annotations are possible at the moment
        [self colorSelected:[[[colorCell.contentView viewWithTag:5] subviews] objectAtIndex:0]];
        self.annotType = ANNOT_FREE_TEXT;
    }
    if (segmentedControl.selectedSegmentIndex==1) {
        [borderSwitch setOn:(YES) animated:YES];
        [self borderSwitchChanged:nil];
        self.annotType = ANNOT_SQUARE;
    }
    [borderSwitchCell setUserInteractionEnabled:(segmentedControl.selectedSegmentIndex==0)];
    [colorCell setUserInteractionEnabled:(segmentedControl.selectedSegmentIndex==1)];
}

-(void)borderSwitchChanged:(id)sender{
    [borderWidthCell setUserInteractionEnabled:borderSwitch.on];
    self.withBorder = [NSNumber numberWithBool:borderSwitch.on];
}

-(void)initUIElements{
    if ([annotType isEqualToString:ANNOT_FREE_TEXT]) {
        [self.segmentedControl setSelectedSegmentIndex:0];
    }
    if ([annotType isEqualToString:ANNOT_SQUARE]) {
        [self.segmentedControl setSelectedSegmentIndex:1];
        for (int i=1; i<6; i++) {
            UIButton *colorButton = [[[colorCell.contentView viewWithTag:i] subviews] objectAtIndex:0];
            if ([annotColor isEqual:[colorButton backgroundColor]]) {
                [self colorSelected:colorButton];
            }
        }
    }
    [self selectedSegmentChanged:nil];
    
    borderSwitch.on = [withBorder boolValue];
    [borderSwitch setOn:[withBorder boolValue] animated:NO];
    [self borderSwitchChanged:nil];
    borderWidthTextField.text = [NSString stringWithFormat:@"%.1f",[borderWidth doubleValue]];    
}

-(void)dealloc{
    [borderSwitch release];
    [segmentedControl release];
    [colorCell release];
    [borderSwitchCell release];
    [borderWidthCell release];
    [annotColor release];
    [annotType release];
    [borderWidth release];
    [withBorder release];
    [borderWidthTextField release];
    [super dealloc];
}

@end
