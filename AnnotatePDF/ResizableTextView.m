//
//  ResizableTextView.m
//  PDFViewer
//
//  Created by Felix Kopp on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResizableTextView.h"

@implementation ResizableTextView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
    }
    return self;
}

- (UIEdgeInsets) contentInset { 
    [self setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
    return UIEdgeInsetsMake(-5, 0, 0, 0); 
}

- (void)setContentInset:(UIEdgeInsets)contentInset{
    [super setContentInset:UIEdgeInsetsMake(-5, 0, 0, 0)];
}

@end
