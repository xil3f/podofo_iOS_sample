//
//  ResizableTextView.h
//  PDFViewer
//
//  Created by Felix Kopp on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 Subclass of UITextView to ensure that the conten inset is removed. This is needed
 to set the FreeText annotations to the right position
 */
@interface ResizableTextView : UITextView

@end
