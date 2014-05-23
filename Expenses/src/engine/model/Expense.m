//
//  Expense.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "Expense.h"

@interface Expense() {
    NSInteger _id;
    double amount;
	NSString * category;
	NSString * subcategory;
	NSString * desc;
	NSDate * date;
    
    BOOL isNew;
}

@end

@implementation Expense

-(id)initWithDictionary:(NSDictionary*)data {
    self = [super init];
    if(self != nil) {
        _id = [[data objectForKey:@"id"] integerValue];
        amount = [[data objectForKey:@"amount"] doubleValue];
        category = [data objectForKey:@"category"];
        subcategory = [data objectForKey:@"subcategory"];
        desc = [data objectForKey:@"desc"];
        
        NSInteger unixtime = [[data objectForKey:@"date"] integerValue];
        date = [NSDate dateWithTimeIntervalSince1970:unixtime];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encode {
    [encode encodeInteger:_id forKey:@"id"];
    [encode encodeDouble:amount forKey:@"amount"];
    [encode encodeObject:category forKey:@"category"];
    [encode encodeObject:subcategory forKey:@"subcategory"];
    [encode encodeObject:desc forKey:@"desc"];
    [encode encodeObject:date forKey:@"date"];
}
- (id)initWithCoder:(NSCoder *)decode {
    self = [super init];
    if(self != nil) {
        _id = [decode decodeIntegerForKey:@"id"];
        amount = [decode decodeDoubleForKey:@"amount"];
        category = [decode decodeObjectForKey:@"category"];
        subcategory = [decode decodeObjectForKey:@"subcategory"];
        desc = [decode decodeObjectForKey:@"desc"];
        date = [decode decodeObjectForKey:@"date"];
    }
    return self;
}




-(NSString*)getDesc {
    return desc;
}
-(NSString*)getCategory {
    return category;
}
-(NSString*)getSubCategory {
    return subcategory;
}
-(double)getAmount {
    return amount;
}
-(NSString*)getFormattedAmount {
    return [NSString stringWithFormat:@"%.2lf", amount];
}
-(NSDate*)getDate {
    return date;
}
-(NSString*)getFormattedDate {
    return [[Expense getDateFormat] stringFromDate:date];
}


static NSDateFormatter *cacheFormatter = NULL;
+ (NSDateFormatter *)getDateFormat {
    @synchronized(self) {
        if (cacheFormatter == NULL) {
            NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MM/dd/yyyy" options:0
                                                                      locale:[NSLocale currentLocale]];
            cacheFormatter = [[NSDateFormatter alloc] init];
            [cacheFormatter setDateFormat:formatString];
        }
    }
    return cacheFormatter ;
}


-(void)setNew {
    isNew = YES;
}
-(void)setOld {
    isNew = NO;
}
-(BOOL)isNew {
    return isNew;
}


@end
