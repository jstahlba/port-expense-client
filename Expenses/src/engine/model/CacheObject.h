//
//  CacheObject.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-22.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheObject : NSObject

-(id)initWithData:(id)data :(NSInteger)ttl;

-(id)peekData;
-(id)getData;
-(BOOL)isExpired;

@end
