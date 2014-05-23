//
//  SettingManager.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingManager : NSObject

-(void)startup;
-(void)shutdown;

-(id)objectForKey:(NSString*)key;
-(NSString*)stringForKey:(NSString*)key;

@end
