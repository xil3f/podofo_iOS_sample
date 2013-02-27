//
//  APDFManager.m
//  AnnotatePDF
//
//  Created by Felix Kopp on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APDFManager.h"
#import "APDFAnnotation.h"
#import "ResizableTextView.h"
#import "podofo.h"

//using namespace PoDoFo;

@implementation APDFManager

+(void)createFreeTextAnnotationOnPage:(NSInteger)pageIndex doc:(PdfMemDocument*)aDoc rect:(CGRect)aRect borderWidth:(double)bWidth title:(NSString*)title content:(NSString*)content bOpen:(Boolean)bOpen color:(UIColor*)color {
    PoDoFo::PdfMemDocument *doc = (PoDoFo::PdfMemDocument *) aDoc;
    PoDoFo::PdfPage* pPage = doc->GetPage(pageIndex);
    if (! pPage) {
        // couldn't get that page
        return;
    }
    PoDoFo::PdfAnnotation* anno;
    PoDoFo::EPdfAnnotation type= PoDoFo::ePdfAnnotation_FreeText;
    
    PoDoFo::PdfRect rect;
    rect.SetBottom(aRect.origin.y);
    rect.SetLeft(aRect.origin.x);
    rect.SetHeight(aRect.size.height);
    rect.SetWidth(aRect.size.width);
    
    anno = pPage->CreateAnnotation(type , rect);
    
    PoDoFo::PdfString sTitle(reinterpret_cast<const PoDoFo::pdf_utf8*>([title UTF8String]));
    PoDoFo::PdfString sContent(reinterpret_cast<const PoDoFo::pdf_utf8*>([content UTF8String]));
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    
    anno->SetTitle(sTitle);
    anno->SetContents(sContent);
//    anno->SetColor(red, green, blue);
    anno->SetOpen(bOpen);
    anno->SetBorderStyle(0, 0, bWidth);
}

+(void)createSquareAnnotationOnPage:(NSInteger)pageIndex doc:(PdfMemDocument*)aDoc rect:(CGRect)aRect borderWidth:(double)bWidth title:(NSString*)title bOpen:(Boolean)bOpen color:(UIColor*)color
{
    PoDoFo::PdfMemDocument* doc = (PoDoFo::PdfMemDocument *)aDoc;
    PoDoFo::PdfPage* pPage = doc->GetPage(pageIndex);
    if (! pPage) {
        // couldn't get that page
        return;
    }
    PoDoFo::PdfAnnotation* anno;
    PoDoFo::EPdfAnnotation type= PoDoFo::ePdfAnnotation_Square;
    
    PoDoFo::PdfRect rect;
    rect.SetBottom(aRect.origin.y);
    rect.SetLeft(aRect.origin.x);
    rect.SetHeight(aRect.size.height);
    rect.SetWidth(aRect.size.width);
    
    anno = pPage->CreateAnnotation(type , rect);
    
    PoDoFo::PdfString sTitle(reinterpret_cast<const PoDoFo::pdf_utf8*>([title UTF8String]));
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
    }
    
    if (bWidth == 0) {
        bWidth = 1.0;
    }
        
    anno->SetTitle(sTitle);
    anno->SetColor(red, green, blue);
    anno->SetOpen(bOpen);
    anno->SetBorderStyle(0, 0, bWidth);
}

+(void)deleteAnnotationWithIndex:(NSInteger)annotIndex onPage:(NSInteger)pageIndex ofDoc:(PdfMemDocument *)aDoc
{
    PoDoFo::PdfMemDocument* doc = (PoDoFo::PdfMemDocument *)aDoc;
    PoDoFo::PdfPage *pPage = doc->GetPage(pageIndex);
    
    pPage->DeleteAnnotation(annotIndex);
}

+(PdfMemDocument*)createPdfForFileAtPath:(NSString*)path
{    
    PoDoFo::PdfMemDocument* doc = new PoDoFo::PdfMemDocument([path UTF8String]);
    
    return (PdfMemDocument*)doc;
}

+(NSString*)createCopyForFile:(NSString*)path
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tmp = [documentsDirectory stringByAppendingPathComponent:@"/tmp.apdf"];
    
    if ([fileManager fileExistsAtPath:tmp] == YES) {
        [fileManager removeItemAtPath:tmp error:&error];
    }

    [fileManager copyItemAtPath:path toPath:tmp error:&error];
    
    return tmp;
}

+(void)writePdf:(PdfMemDocument*)aDoc toPath:(NSString *)path withTemporaryFilePath:(NSString*)tmpPath
{
    PoDoFo::PdfMemDocument* doc = (PoDoFo::PdfMemDocument *)aDoc;
    
    doc->Write([tmpPath UTF8String]);
    
//    doc->~PdfMemDocument();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:path] == YES) {
        [fileManager removeItemAtPath:path error:&error];
    }
    [fileManager copyItemAtPath:tmpPath toPath:path error:&error];
}

+(NSMutableArray *)getAnnotationsArrayForPage:(CGPDFPageRef)pPage{
    NSMutableArray* pdfAnnots = [[NSMutableArray alloc] init];
    
    CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(pPage);
    CGPDFArrayRef outputArray;
    if(!CGPDFDictionaryGetArray(pageDictionary, "Annots", &outputArray)) {
        [pdfAnnots release];
        return nil;
    }
    else{
        int arrayCount = CGPDFArrayGetCount( outputArray );
        for( int j = 0; j < arrayCount; ++j ) {
            CGPDFObjectRef aDictObj;
            if(!CGPDFArrayGetObject(outputArray, j, &aDictObj)) {
                break;
            }
            
            CGPDFDictionaryRef annotDict;
            if(!CGPDFObjectGetValue(aDictObj, kCGPDFObjectTypeDictionary, &annotDict)) {
                break;
            }
            
            const char *annotationType;
            CGPDFDictionaryGetName(annotDict, "Subtype", &annotationType);
            
            NSString* type = [NSString stringWithUTF8String:annotationType];
            
            CGPDFArrayRef rectArray;
            if(!CGPDFDictionaryGetArray(annotDict, "Rect", &rectArray)) {
                break;
            }
            
            int arrayCount = CGPDFArrayGetCount( rectArray );
            CGPDFReal coords[4];
            for( int k = 0; k < arrayCount; ++k ) {
                CGPDFObjectRef rectObj;
                if(!CGPDFArrayGetObject(rectArray, k, &rectObj)) {
                    break;
                }
                
                CGPDFReal coord;
                if(!CGPDFObjectGetValue(rectObj, kCGPDFObjectTypeReal, &coord)) {
                    break;
                }
                
                coords[k] = coord;
            }               
            
            CGRect rect = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
            
            UIColor *annotColor = [UIColor blackColor];
            CGPDFArrayRef colorArray;
            if(CGPDFDictionaryGetArray(annotDict, "C", &colorArray)) {
                int cArrayCount = CGPDFArrayGetCount( colorArray );
                CGPDFReal colors[3];
                for( int k = 0; k < cArrayCount; ++k ) {
                    CGPDFObjectRef colorObj;
                    if(!CGPDFArrayGetObject(colorArray, k, &colorObj)) {
                        break;
                    }
                    CGPDFReal color;
                    if(!CGPDFObjectGetValue(colorObj, kCGPDFObjectTypeReal, &color)) {
                        break;
                    }
                    colors[k] = color;
                }               
                annotColor=[UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1]; 
                
            }          
            rect.size.width -= rect.origin.x;
            rect.size.height -= rect.origin.y;
            
            //to show the annotation on the right position a +5 is needed. It may
            //be needed because the content inset Top of the ResizableTextView is set 
            //to -5 ?Dont know why this effects the y value of the frame?
            rect.origin.y +=5;
            
            APDFAnnotation *annotation = [[APDFAnnotation alloc] initWithPDFDictionary:annotDict andType:type];
            annotation.annotColor = annotColor;
            
            // FreeText annotations are identified by FreeText name stored in Subtype key in annotation dictionary.
            if ([type isEqualToString:ANNOT_FREE_TEXT]){                
                ResizableTextView *annotationView = [[ResizableTextView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
                annotationView.font = annotation.font;
                annotationView.text = annotation.textString;
                annotationView.textColor = annotation.textColor;
                annotationView.backgroundColor = [UIColor clearColor];
                annotationView.textAlignment = annotation.textAlignment;
                [annotationView setEditable:YES];
                
                if (annotation.borderWidth != 0) {
                    annotationView.layer.borderColor = annotation.textColor.CGColor;
                    annotationView.layer.borderWidth = annotation.borderWidth;
                }
                
                annotation.annotationView = annotationView;
                [annotationView release];
            }else if ([type isEqualToString:ANNOT_SQUARE]){
                ResizableTextView *squareView = [[ResizableTextView alloc] initWithFrame:rect];
                squareView.backgroundColor = [UIColor clearColor];
                squareView.layer.borderColor = annotColor.CGColor;
                squareView.layer.borderWidth = annotation.borderWidth;
                
                annotation.annotationView = squareView;
                [squareView release];
            }else if([type isEqualToString:ANNOT_HIGHLIGHT]){
                ResizableTextView *highlightView = [[ResizableTextView alloc] initWithFrame:rect];
                highlightView.backgroundColor=annotColor;
                highlightView.alpha = 0.5;
                
                annotation.annotationView = highlightView;
                [highlightView release];
            }else{
            // you may support more annotations
            }
            
            [pdfAnnots addObject:annotation];
            [annotation release];
        }
    }
    return [pdfAnnots autorelease];
}

+(NSArray *)getPdfPathsOfArray:(NSArray *)paths{
    NSMutableArray* resultArray = [NSMutableArray array];
    for (int i=0; i<[paths count]; i++) {
        NSString* path = (NSString*)[paths objectAtIndex:i];
        if ([path hasSuffix:@".pdf"]) {
            [resultArray addObject:path];
        }
    }
    paths = [NSArray arrayWithArray:resultArray];
    return paths;
}

@end
