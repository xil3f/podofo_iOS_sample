//
//  PDFPageRenderer.h
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
//  renderAnnotationsForPage:inContext added by Felix Kopp
//

#import <Foundation/Foundation.h>

/**
 Provides rendering functions for PDF pages and PDF annotations
 */
@interface PDFPageRenderer : NSObject {

}

/**
 Draws a specified PDF page in a specified context. The drawing beginns at a specified point. The page
 will be displayed with a specified zoom
 @param page The PDF page that has to be drawn
 @param context The context in that the page should be drawn
 @param point The point in the context where the page should start
 @param zoom The zoom the page should be drawn with
 */
+ (void) renderPage:(CGPDFPageRef)page inContext:(CGContextRef)context atPoint:(CGPoint)point withZoom:(float)zoom;

/**
 Draws the annotations of a specified page in a specified context
 @param page The PDF page that holds the annotations
 @param context The context in that the annotations should be drawn
 */
+ (void) renderAnnotationsForPage:(CGPDFPageRef)page inContext:(CGContextRef)context;


@end
