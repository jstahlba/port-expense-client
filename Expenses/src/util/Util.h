//
//  Util.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+(UIAlertView*)alertForKey:(NSString*)key;

+(void)setX:(CGFloat)width view:(UIView*)view;
+(void)setY:(CGFloat)height view:(UIView*)view;
+(void)setWidth:(CGFloat)width view:(UIView*)view;
+(void)setHeight:(CGFloat)height view:(UIView*)view;


@end
