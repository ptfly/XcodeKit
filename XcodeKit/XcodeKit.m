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
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation XcodeKit
@synthesize codeEditor, currentRange, currentLineRange, currentSelection;

+(instancetype)sharedPlugin
{
    return sharedPlugin;
}

+(void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[XcodeKit alloc] initWithBundle:plugin];
        });
    }
}

-(id)initWithBundle:(NSBundle *)plugin
{
    if(self = [super init])
    {
        self.bundle = plugin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
    }
    
    return self;
}

-(void)didApplicationFinishLaunchingNotification:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
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
        
        // tap into notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:NSTextViewDidChangeSelectionNotification object:nil];
        
        if(!self.codeEditor){
            NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
            if([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [firstResponder isKindOfClass:[NSTextView class]]){
                self.codeEditor = (NSTextView *)firstResponder;
            }
        }
        
        if(self.codeEditor){
            NSNotification *notification = [NSNotification notificationWithName:NSTextViewDidChangeSelectionNotification object:self.codeEditor];
            [self selectionDidChange:notification];
        }
    }
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

-(void)selectionDidChange:(NSNotification *)notification
{
    if([[notification object] isKindOfClass:NSClassFromString(@"DVTSourceTextView")] && [[notification object] isKindOfClass:[NSTextView class]])
    {
        self.codeEditor = (NSTextView *)[notification object];
        
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
    if(codeEditor)
    {
        if(currentSelection && [currentSelection isNotEqualTo:@""]){
            [codeEditor insertText:@"" replacementRange:currentRange];
        }
        else {
            NSRange targetRange = currentLineRange;
            
            //NSRange range = NSMakeRange(currentLineRange.location + currentLineRange.length, 0);
            //[codeEditor setSelectedRange:range];
            
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
            [codeEditor setSelectedRange:NSMakeRange(currentLineRange.location - 1, 0)];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
