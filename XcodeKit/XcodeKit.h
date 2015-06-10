//
//  XcodeKit.h
//  XcodeKit
//
//  Created by Plamen Todorov on 20.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import <AppKit/AppKit.h>


@class XcodeKit;

static XcodeKit *sharedPlugin;

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

+(instancetype)sharedPlugin;
-(id)initWithBundle:(NSBundle *)plugin;
-(void)deleteSelection;
-(void)duplicateSelection;
@end
