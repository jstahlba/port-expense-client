//
//  ExpenseTableViewCell.h
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Expense.h"

@interface SearchTableViewCell : UITableViewCell

-(void)setCategoryName:(NSString*)category;
-(void)setIndexPath:(NSIndexPath*)path :(NSUInteger)numberOfCells;
@end
