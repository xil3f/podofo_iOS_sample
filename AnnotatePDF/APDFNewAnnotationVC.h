//
//  APDFNewAnnotationVC.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 A View Controller that holds the current parameters for a new Annotation.
 It is designed for being presented in a Popover.
 It lets the user change the parameters for a new Annotation.
 */
@interface APDFNewAnnotationVC : UITableViewController<UITextFieldDelegate>

/** Annotation type Segmented Control in GUI */
@property(nonatomic,retain) IBOutlet UISegmentedControl *segmentedControl;

/** The TableViewCell holding the color picker in GUI */
@property(nonatomic,retain) IBOutlet UITableViewCell *colorCell;

/** The TableViewCell holding the Swich to activate/deactivate the annotation border in GUI */
@property(nonatomic,retain) IBOutlet UITableViewCell *borderSwitchCell;

/** The TableViewCell holding the Text Field defining the border Width in GUI */
@property(nonatomic,retain) IBOutlet UITableViewCell *borderWidthCell;

/** The Switch to activate/deactivate the annotation border in GUI */
@property(nonatomic,retain) IBOutlet UISwitch *borderSwitch;

/** TextField defining the border width in GUI */
@property(nonatomic,retain) IBOutlet UITextField *borderWidthTextField;

/** A string holding the current type for a new Annotation */
@property(nonatomic,retain) NSString *annotType;

/** NSNumber with BOOL value if border is on or off */
@property(nonatomic,retain) NSNumber* withBorder;

/** NSNumber with double value of the borderWidth */
@property(nonatomic,retain) NSNumber* borderWidth;

/** The color of the new Annotation */
@property(nonatomic,retain) UIColor *annotColor;

/**
 Selects the color of the specified UIButton sender.
 Performed by an IBAction.
 @param sender The UIButton that is pressed
 */
-(IBAction)colorSelected:(id)sender;

/**
 Selects the new Annotation type segment specified by UISegmentedControl sender.
 Performed by an IBAction.
 @param sender The UISegmentedControl that is pressed
 */
-(IBAction)selectedSegmentChanged:(id)sender;

/**
 Selects if the border is on or off. It is called when the border switch changed.
 Performed by an IBAction.
 @param sender The UISwitch that changed
 */
-(IBAction)borderSwitchChanged:(id)sender;

/**
 Initializes the UI elements to show the stored values of 
 annotType, withBorder, borderWidth, annotColor 
 */
-(void)initUIElements;

@end
