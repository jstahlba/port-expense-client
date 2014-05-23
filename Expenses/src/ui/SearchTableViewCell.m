//
//  ExpenseTableViewCell.m
//  Expenses
//
//  Created by Jacob Stahlbaum on 2014-05-21.
//  Copyright (c) 2014 com.example.jstahlbaum. All rights reserved.
//

#import "SearchTableViewCell.h"

@interface SearchTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@end

@implementation SearchTableViewCell



-(void)setCategoryName:(NSString*)cat {
    self.category.text = cat;
}

-(void)setIndexPath:(NSIndexPath*)path :(NSUInteger)numberOfCells {
    self.seperator.hidden = path.row == numberOfCells - 1;
}

@end
