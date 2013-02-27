//
//  APDFAnnotation.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The identifier for FreeText annotations
 */
#define ANNOT_FREE_TEXT         @"FreeText"

/**
 The identifier for Highlight annotations
 */
#define ANNOT_HIGHLIGHT         @"Highlight"

/**
 The identifier for Square annotations
 */
#define ANNOT_SQUARE            @"Square"

@class ResizableTextView;

/**
 A class that models an annotation with a given annotation type, and 
 parameters that specify the annotation. For FreeText Annotatons the font
 type, the text and the text color are specified. For Square and Highlight
 annotations the property a annotation color is specified instead of 
 the text color. All Annotations hold a view that has the right size and 
 contains the annotation. This view can be drawn into the PDF.
 */
@interface APDFAnnotation : NSObject

/**
 Defines the type of the annotation. In this version only the three types:
 FreeText, Highlight and Square are supported
 */
@property(nonatomic,retain) NSString * annotationType;

/**
 Defines the font of a FreeText annotation. If no font is defined 
 as default font will be used [UIFont fontWithName:@"Helvetica" size:13]
 */
@property(nonatomic,retain) UIFont * font;

/**
 The text of a FreeText annotation
 */
@property(nonatomic,retain) NSString * textString;

/**
 The view showing the annoatation. For Square and Highlight annotations 
 there is simply no text
 */
@property(nonatomic,retain) ResizableTextView * annotationView;

/**
 The text color of a FreeText annotation
 */
@property(nonatomic,retain) UIColor* textColor;

/**
 The color of a Square or Highlight annotation
 */
@property(nonatomic,retain) UIColor* annotColor;

/**
 The alignment of a the text in a FreeText annotation
 */
@property UITextAlignment textAlignment;

/**
 The border Width of a Square or FreeText annotation. If the FreeText 
 annotation is without border this value should be 0
 */
@property CGFloat borderWidth;

/**
 Initializes an APDFAnnotation with a specified PDF dictionary containing 
 the annotation properties and a specified type
 @param annotDict The CGPDFDictionaryRef containing the annotation properties
 @param type The annotation type
 @return The newly initialized APDFAnnotation
 */
-(id)initWithPDFDictionary:(CGPDFDictionaryRef)annotDict andType:(NSString*)type;
@end
