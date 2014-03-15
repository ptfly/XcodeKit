//
//  XcodeKit.h
//  XcodeKit
//
//  Created by Plamen Todorov on 20.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface XcodeKit : NSObject
{
    NSRange currentRange;
    NSRange currentLineRange;
    NSString *currentSelection;
    
    NSTextView *codeEditor;
}

@property (assign) NSRange currentRange;
@property (assign) NSRange currentLineRange;
@property (nonatomic, retain) NSString *currentSelection;
@property (nonatomic, retain) NSTextView *codeEditor;

-(id)initWithBundle:(NSBundle *)plugin;
@end
