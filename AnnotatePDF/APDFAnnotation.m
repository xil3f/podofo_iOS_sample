//
//  APDFAnnotation.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFAnnotation.h"

@implementation APDFAnnotation
@synthesize annotationType,font,textString,annotationView;
@synthesize textColor;
@synthesize textAlignment;
@synthesize borderWidth;
@synthesize annotColor;

-(id)initWithPDFDictionary:(CGPDFDictionaryRef)annotDict andType:(NSString *)type{
    self=[super init];
    self.annotationType = type;
    
    if ([type isEqualToString:@"FreeText"]){
        
        CGPDFStringRef fontTypeRef;
        if(CGPDFDictionaryGetString(annotDict, "DA", &fontTypeRef)) {
            NSString* fontType = [(NSString *)CGPDFStringCopyTextString(fontTypeRef) autorelease];
            
//            NSRange wordRange = NSMakeRange(0,6);
            NSArray *firstWords = [fontType componentsSeparatedByString:@" "];
//            NSLog(@"font split:%@",firstWords);
            NSString *tempStr = [firstWords objectAtIndex:0];
            fontType = [tempStr substringFromIndex:1];
            
            tempStr=[firstWords objectAtIndex:1];
            NSInteger fontSize = [tempStr intValue];
            if ([firstWords count]>5) {
                CGFloat red = [[firstWords objectAtIndex:3] floatValue];
                CGFloat green = [[firstWords objectAtIndex:4] floatValue];
                CGFloat blue = [[firstWords objectAtIndex:5] floatValue];
                self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
            }
            else{
                self.textColor = [UIColor blackColor];
            }            
            self.font = [UIFont fontWithName:fontType size:fontSize];
//            NSLog(@"font type:%@, font size:%f",fontType,fontSize);
        }
        else{
            textColor=[UIColor blackColor];
            self.font = [UIFont fontWithName:@"Helvetica" size:13];
        }
        CGPDFInteger textAlignmentRef;
        if (CGPDFDictionaryGetInteger(annotDict, "Q", &textAlignmentRef)) {
            switch (textAlignmentRef) {
                case 1:
                    self.textAlignment = UITextAlignmentCenter;
                    break;
                case 2:
                    self.textAlignment = UITextAlignmentRight;
                    break;
                    
                default:
                    self.textAlignment = UITextAlignmentLeft;
                    break;
            }
        }
        else self.textAlignment = UITextAlignmentLeft;
        
        CGPDFStringRef textStringRef;
        if(CGPDFDictionaryGetString(annotDict, "Contents", &textStringRef)) {
            self.textString = [(NSString *)CGPDFStringCopyTextString(textStringRef) autorelease];
//            NSLog(@"%@",textString);
        }
        
    }
    CGPDFArrayRef borderArray;
    if (CGPDFDictionaryGetArray(annotDict, "Border",&borderArray)){
        int cArrayCount = CGPDFArrayGetCount( borderArray );
        for( int k = 0; k < cArrayCount; ++k ) {
            CGPDFObjectRef borderObj;
            if(!CGPDFArrayGetObject(borderArray, k, &borderObj)) {
                break;
            }
            CGPDFReal border;
            if(!CGPDFObjectGetValue(borderObj, kCGPDFObjectTypeReal, &border)) {
                break;
            }
//            NSLog(@"BorderStyle %i: %f",k,border);
            if (k==2) {
                self.borderWidth = border;
            }
        }   
    }   
    else{
        self.borderWidth = 1;
    }
    
    CGPDFDictionaryRef borderStyleDict;
    if (CGPDFDictionaryGetDictionary(annotDict, "BS",&borderStyleDict)){
        CGPDFReal borderStyleWidth;
        if(CGPDFDictionaryGetNumber(borderStyleDict, "W", &borderStyleWidth)){
//            NSLog(@"BorderWidth:%f",borderStyleWidth);
            self.borderWidth = borderStyleWidth;
        }
    }
    
    return self;
}

- (void)dealloc {
    [annotationView release];
    [annotationType release];
    [textString release];
    [font release];
    [textColor release];
    [annotColor release];
    
    [super dealloc];
}
@end