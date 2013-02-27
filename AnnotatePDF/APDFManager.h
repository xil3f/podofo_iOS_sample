//
//  APDFManager.h
//  AnnotatePDF
//
//  Created by Felix Kopp on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class PdfMemDocument;

/**
 Provides class methods that are used for PDF file/annotation creation and manipulation.
 For the manipulation the PoDoFo library is used
 */
@interface APDFManager : NSObject

/**
 Creates a FreeText annotaion for the specified page of a specified Document with the specified parameters
 and saves the annotation directly into the PDF file
 @param pageIndex The index of the page in the pdf starting with 0
 @param aDoc The PoDoFo::PdfMemDocument that specifies the PDF file
 @param aRect The CGRect that defines the position and size of the annotation in the PDF file
 @param bWidth The border width of the Annotation. Has to be 0 if no border should be there
 @param title The title of the new PDF annotation
 @param content The text of the FreeText annotation
 @param bOpen Defines if the Annotation should be opend (shown) immediatly
 @param color The UIColor of the Annotation. In this version only black FreeText Annotations are possible
 */
+(void)createFreeTextAnnotationOnPage:(NSInteger)pageIndex doc:(PdfMemDocument*)aDoc rect:(CGRect)aRect borderWidth:(double)bWidth title:(NSString*)title content:(NSString*)content bOpen:(Boolean)bOpen color:(UIColor*)color;

/**
 Creates a Square annotaion for the specified page of a specified Document with the specified parameters
 and saves the annotation directly into the PDF file
 @param pageIndex The index of the page in the pdf starting with 0
 @param aDoc The PoDoFo::PdfMemDocument that specifies the PDF file
 @param aRect The CGRect that defines the position and size of the annotation in the PDF file
 @param bWidth The border width of the Annotation. The Value cannot be 0 for Square annotations. If it is zero, 
 the value will be set to 1.0 by default
 @param title The title of the new PDF annotation
 @param bOpen Defines if the Annotation should be opend (shown) immediatly
 @param color The UIColor of the Annotation
 */
+(void)createSquareAnnotationOnPage:(NSInteger)pageIndex doc:(PdfMemDocument*)aDoc rect:(CGRect)aRect borderWidth:(double)bWidth title:(NSString*)title bOpen:(Boolean)bOpen color:(UIColor*)color;

/**
 Deletes the Annotation at the specified index for the specified page of a specified Document. The annotation
 is directly deleted from the Document and the Document gets saved
 @param annotIndex The index of the annotation in the Annotatins Array of a Document
 @param pageIndex The index of the page in the pdf starting with 0
 @param doc The PoDoFo::PdfMemDocument that specifies the PDF file
 */
+(void)deleteAnnotationWithIndex:(NSInteger)annotIndex onPage:(NSInteger)pageIndex ofDoc:(PdfMemDocument*)doc;

/**
 Creates a PoDoFo::PdfMemDocument for a PDF file at the specified filepath
 @param path The filepath of the PDF file
 @returns The created PoDoFo::PdfMemDocument representing the PDF file
 */
+(PdfMemDocument*)createPdfForFileAtPath:(NSString*)path;

/**
 Creates a temporary file with the extension .apdf that is a copy of the PDF file at the specified filepath
 and returns the path to the temporary file. This is necessary to perform saving of the PDF file because PoDoFo
 is not able to save back to the original file.
 @param path The filepath of the file to copy
 @returns The filepath of the temporary copy
 */
+(NSString*)createCopyForFile:(NSString*)path;

/**
 Saves a specified PoDoFo::PdfMemDocument to PDF file in the shared Documents directory
 @param aDoc The PoDoFo::PdfMemDocument that specifies the PDF file
 @param path The path where the PDF file should be stored
 @param tmpPath The path of the temporary copy of the PDF file
 */
+(void)writePdf:(PdfMemDocument*)aDoc toPath:(NSString*)path withTemporaryFilePath:(NSString*)tmpPath;

/**
 Reads the Annotations of a specified PDF page and returns the Annotations in an Array
 @param pPage The reference to a PDF page
 @returns An Array that holds the Annotations of the specified PDF page
 */
+(NSMutableArray*)getAnnotationsArrayForPage:(CGPDFPageRef)pPage;

/**
 Filters a path Array, so that only paths of PDF files remain
 @param paths The Array with several paths
 @returns An Array with only paths to PDF files
 */
+(NSArray*)getPdfPathsOfArray:(NSArray*)paths;

@end
