//
//  Util.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "Util.h"
#import "Engine.h"
#import "SettingManager.h"

@implementation Util

+(UIAlertView*)alertForKey:(NSString*)key {
    NSDictionary * alertData = [[Engine setting] objectForKey:key];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[alertData objectForKey:@"title"]
                              message:[alertData objectForKey:@"message"]
                              delegate:nil
                              cancelButtonTitle:[alertData objectForKey:@"cancelButton"]
                              otherButtonTitles:nil];
    for(NSString * other in [alertData objectForKey:@"otherButtons"]) {
        [alert addButtonWithTitle:other];
    }
    [alert show];
    
    return alert;
}

+(void)setX:(CGFloat)x view:(UIView*)view {
    CGRect rect = view.frame;
    rect.origin.x = x;
    view.frame = rect;
}
+(void)setY:(CGFloat)y view:(UIView*)view {
    CGRect rect = view.frame;
    rect.origin.y = y;
    view.frame = rect;
}
+(void)setWidth:(CGFloat)width view:(UIView*)view {
    CGRect rect = view.frame;
    rect.size.width = width;
    view.frame = rect;
}
+(void)setHeight:(CGFloat)height view:(UIView*)view {
    CGRect rect = view.frame;
    rect.size.height = height;
    view.frame = rect;
}

@end
