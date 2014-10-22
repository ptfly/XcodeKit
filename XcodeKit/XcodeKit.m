//
//  XcodeKit.m
//  XcodeKit
//
//  Created by Plamen Todorov on 20.11.13.
//  Copyright (c) 2013 г. Plamen Todorov. All rights reserved.
//

#import "XcodeKit.h"

static XcodeKit *sharedPlugin;

@interface XcodeKit()
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation XcodeKit
@synthesize codeEditor, currentRange, currentLineRange, currentSelection;

+(void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if([currentApplicationName isEqual:@"Xcode"]){
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

-(id)initWithBundle:(NSBundle *)plugin
{
    if(self = [super init])
    {
        self.bundle = plugin;
     
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        
        if(menuItem)
        {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Selection / Line" action:@selector(deleteSelection) keyEquivalent:@"cmd+E"];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
            
            NSMenuItem *actionMenuItem2 = [[NSMenuItem alloc] initWithTitle:@"Duplicate Selection / Line" action:@selector(duplicateSelection) keyEquivalent:@"cmd+d"];
            [actionMenuItem2 setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem2];
        }
    }
    return self;
}

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if([menuItem action] == @selector(deleteSelection))
    {
        NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
        return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
    }
    else if([menuItem action] == @selector(duplicateSelection))
    {
        NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
        return ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]);
    }
    
    return YES;
}

- ( void ) updateIvars
{
    self.codeEditor = nil;
    
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] &&
       [firstResponder isKindOfClass:[NSTextView class]])
    {
        self.codeEditor = (NSTextView *)firstResponder;
        
        NSArray *selectedRanges = [codeEditor selectedRanges];
        
        if(selectedRanges.count >= 1)
        {
            NSString *code = codeEditor.textStorage.string;
            
            self.currentRange     = [[selectedRanges objectAtIndex:0] rangeValue];
            self.currentLineRange = [code lineRangeForRange:currentRange];
            self.currentSelection = [code substringWithRange:currentRange];
            
            //NSRange rangeInLine = NSMakeRange(currentRange.location - currentLineRange.location, currentRange.length);
            //NSLog(@"%@", NSStringFromRange(currentRange));
        }
    }
}

-(void)deleteSelection
{
    [self updateIvars];
    
    if(codeEditor)
	{
		if(currentSelection && [currentSelection isNotEqualTo:@""]){
            [codeEditor insertText:@"" replacementRange:currentRange];
		}
        else {
            NSRange targetRange = currentLineRange;
            
            NSRange range = NSMakeRange(currentLineRange.location + currentLineRange.length, 0);
            range = [codeEditor.textStorage.string lineRangeForRange:range];
            range = NSMakeRange(range.location + range.length - 1, 0);
            [codeEditor setSelectedRange:range];
            
            @try {
                [codeEditor insertText:@"" replacementRange:NSMakeRange(targetRange.location-1, targetRange.length)];
            }
            @catch (NSException *exception) {
                [codeEditor insertText:@"" replacementRange:NSMakeRange(targetRange.location, targetRange.length)];
            }
        }
	}
}

-(void)duplicateSelection
{
    [self updateIvars];

    if(codeEditor)
	{
		if(currentSelection && [currentSelection isNotEqualTo:@""])
        {
            NSString *copy = currentSelection;
            
            [codeEditor setSelectedRange:NSMakeRange(currentRange.location + currentRange.length, 0)];
            [codeEditor insertText:copy];
		}
        else {
            NSString *lineContent = [codeEditor.textStorage.string substringWithRange:currentLineRange];
            
            [codeEditor setSelectedRange:NSMakeRange(currentLineRange.location + currentLineRange.length, 0)];
            [codeEditor insertText:lineContent];
            [codeEditor setSelectedRange:NSMakeRange(currentLineRange.location + currentLineRange.length - 1, 0)];
        }
	}
}

-(void)dealloc
{
}

@end
