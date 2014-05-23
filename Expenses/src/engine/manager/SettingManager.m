//
//  SettingManager.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "SettingManager.h"
@interface SettingManager () {
    NSDictionary * settings;
}
@end

@implementation SettingManager
-(void)startup {
    settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"]];
    
}

-(void)shutdown {
    settings = nil;
}

-(id)objectForKey:(NSString*)key {
    return [settings objectForKey:key];
}

-(NSString*)stringForKey:(NSString*)key {
    return [settings objectForKey:key];
}
@end
