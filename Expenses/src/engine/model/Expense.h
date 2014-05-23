//
//  Expense.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Expense : NSObject<NSCoding>
-(id)initWithDictionary:(NSDictionary*)data ;

-(NSString*)getDesc;
-(NSString*)getCategory;
-(NSString*)getSubCategory;
-(double)getAmount;
-(NSString*)getFormattedAmount;
-(NSDate*)getDate;
-(NSString*)getFormattedDate;

-(void)setNew;
-(void)setOld;
-(BOOL)isNew;

+ (NSDateFormatter *)getDateFormat;
@end
