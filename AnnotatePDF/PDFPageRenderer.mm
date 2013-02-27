//
//  PDFPageRenderer.m
//
//  Created by Sorin Nistor on 3/21/11.
//  Copyright 2011 iPDFdev.com. All rights reserved.
//
//    Copyright (c) 2011 Sorin Nistor. All rights reserved. This software is provided 'as-is', 
//    without any express or implied warranty. In no event will the authors be held liable for 
//    any damages arising from the use of this software. Permission is granted to anyone to 
//    use this software for any purpose, including commercial applications, and to alter it 
//    and redistribute it freely, subject to the following restrictions:
//    1. The origin of this software must not be misrepresented; you must not claim that you 
//    wrote the original software. If you use this software in a product, an acknowledgment 
//    in the product documentation would be appreciated but is not required.
//    2. Altered source versions must be plainly marked as such, and must not be misrepresented 
//    as being the original software.
//    3. This notice may not be removed or altered from any source distribution.
//
//  Changes by Felix Kopp on 8/31/12
//

#import "PDFPageRenderer.h"
#import "APDFAnnotation.h"
#import "APDFManager.h"
#import "ResizableTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "podofo.h"
#import "fontconfig.h"

@implementation PDFPageRenderer

+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point withZoom: (float) zoom{
	NSLog(@"x:%f, y:%f",point.x,point.y);
	CGRect cropBox = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
	int rotate = CGPDFPageGetRotationAngle(page);

    CGContextFlush(context);    
	
    CGContextSaveGState(context);
	
	// Setup the coordinate system.
	// Top left corner of the displayed page must be located at the point specified by the 'point' parameter.
	CGContextTranslateCTM(context, point.x, point.y);
	
	// Scale the page to desired zoom level.
	CGContextScaleCTM(context, zoom / 100, zoom / 100);
	
	// The coordinate system must be set to match the PDF coordinate system.
	switch (rotate) {
		case 0:
			CGContextTranslateCTM(context, 0, cropBox.size.height);
			CGContextScaleCTM(context, 1, -1);
			break;
		case 90:
			CGContextScaleCTM(context, 1, -1);
			CGContextRotateCTM(context, -M_PI / 2);
			break;
		case 180:
		case -180:
			CGContextScaleCTM(context, 1, -1);
			CGContextTranslateCTM(context, cropBox.size.width, 0);
			CGContextRotateCTM(context, M_PI);
			break;
		case 270:
		case -90:
			CGContextTranslateCTM(context, cropBox.size.height, cropBox.size.width);
			CGContextRotateCTM(context, M_PI / 2);
			CGContextScaleCTM(context, -1, 1);
			break;
	}
	
    
    CGRect clipRect = CGRectMake(0, 0, cropBox.size.width, cropBox.size.height);
	CGContextAddRect(context, clipRect);
	CGContextClip(context);
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context, clipRect);
	
	CGContextTranslateCTM(context, -cropBox.origin.x, -cropBox.origin.y);
    
	CGContextDrawPDFPage(context, page);
    
    [self renderAnnotationsForPage:page inContext:context];
    
	CGContextRestoreGState(context);
}

+ (void) renderAnnotationsForPage:(CGPDFPageRef) page inContext:(CGContextRef) context{
    NSMutableArray *pdfAnnots = [APDFManager getAnnotationsArrayForPage:page];

    for (int idx=0; idx<[pdfAnnots count]; idx++) {
        APDFAnnotation *annot = [pdfAnnots objectAtIndex:idx];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, annot.annotationView.frame.origin.x, annot.annotationView.frame.origin.y);
        CGAffineTransform verticalFlip = CGAffineTransformMake(1, 0, 0, -1, 0, annot.annotationView.frame.size.height);
        CGContextConcatCTM(ctx, verticalFlip);
        [annot.annotationView.layer renderInContext:context];
        CGContextRestoreGState(ctx);
    }
}

@end
