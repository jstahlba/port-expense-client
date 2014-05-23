//
//  CacheManager.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

-(void)startup;
-(void)shutdown;

-(void)putObject:(id)data key:(NSString *)key ttl:(NSInteger)ttl;
-(id)getObject:(NSString*)key peek:(BOOL)peek;
-(BOOL)isValid:(NSString*)key;

@end
