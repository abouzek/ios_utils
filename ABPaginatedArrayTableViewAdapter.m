//
//  ABPaginatedArrayTableViewAdapter.m
//
//  Created by Alan Bouzek on 3/25/15.
//  Copyright (c) 2015. All rights reserved.
//

#import "ABPaginatedArrayTableViewAdapter.h"

NSUInteger const DEFAULT_PAGE_SIZE = 15;

@interface ABPaginatedArrayTableViewAdapter ()

@property (weak, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *dataCellIdentifier, *noneCellIdentifier, *loadingCellIdentifier, *endCellIdentifier;
@property (nonatomic) CGFloat dataCellHeight, noneCellHeight;
@property (strong, nonatomic) ABSelectItemBlock selectItemBlock;
@property (strong, nonatomic) ABCellConfigureBlock cellConfigureBlock;
@property (strong, nonatomic) ABPaginatedLoadingBlock loadingBlock;
@property (strong, nonatomic) ABSelectNoneBlock selectNoneBlock;

@end


@implementation ABPaginatedArrayTableViewAdapter

@synthesize hasMoreData = _hasMoreData;
@synthesize isLoading = _isLoading;

-(instancetype)initWithItems:(NSMutableArray *)items
          dataCellIdentifier:(NSString *)dataCellIdentifier
          noneCellIdentifier:(NSString *)noneCellIdentifier
       loadingCellIdentifier:(NSString *)loadingCellIdentifier
           endCellIdentifier:(NSString *)endCellIdentifier
              dataCellHeight:(CGFloat)dataCellHeight
              noneCellHeight:(CGFloat)noneCellHeight
          cellConfigureBlock:(ABCellConfigureBlock)cellConfigureBlock
             selectItemBlock:(ABSelectItemBlock)selectItemBlock
             selectNoneBlock:(ABSelectNoneBlock)selectNoneBlock
                loadingBlock:(ABPaginatedLoadingBlock)loadingBlock {
    if (self = [super init]) {
        self.items = items;
        self.dataCellIdentifier = dataCellIdentifier;
        self.dataCellHeight = dataCellHeight;
        self.noneCellIdentifier = noneCellIdentifier;
        self.loadingCellIdentifier = loadingCellIdentifier;
        self.endCellIdentifier = endCellIdentifier;
        self.noneCellHeight = noneCellHeight;
        self.cellConfigureBlock = cellConfigureBlock;
        self.selectItemBlock = selectItemBlock;
        self.loadingBlock = loadingBlock;
        self.hasMoreData = YES;
    }
    return self;
}


#pragma mark - PaginatedDataSource

-(id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.row];
}

-(void)loadDataWithStartIndex:(NSInteger)index {
    if (index < self.items.count) {
        return;
    }
    
    self.isLoading = YES;
    
    self.loadingBlock(index, DEFAULT_PAGE_SIZE, ^(NSArray *loadedItems) {
        if (loadedItems.count != DEFAULT_PAGE_SIZE) {
            self.hasMoreData = NO;
        }
        
        self.isLoading = NO;
        [self.items addObjectsFromArray:loadedItems];
    });
}


#pragma mark - utility methods

-(id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.row];
}


#pragma mark - UITableViewDataSource methods

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    id item;
    if (indexPath.row < self.items.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.dataCellIdentifier
                                               forIndexPath:indexPath];
        item = [self itemAtIndexPath:indexPath];
    }
    else if (self.hasMoreData) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.loadingCellIdentifier
                                               forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (!self.hasMoreData && self.items.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.endCellIdentifier
                                               forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:self.noneCellIdentifier
                                               forIndexPath:indexPath];
    }
    
    !self.cellConfigureBlock ?: self.cellConfigureBlock(cell, item);
    
    if (indexPath.row == self.items.count) {
        CGFloat inset = CGRectGetWidth(tableView.bounds) / 2.0;
        cell.separatorInset = UIEdgeInsetsMake(0, inset, 0, inset);
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat yOffset = tableView.contentOffset.y;
    CGFloat height = tableView.contentSize.height - tableView.frame.size.height;
    CGFloat scrolledPercentage = yOffset / height;
    
    if (scrolledPercentage > .6 && !self.isLoading && self.hasMoreData) {
        [self loadDataWithStartIndex:indexPath.row];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        id item = [self itemAtIndexPath:indexPath];
        !self.selectItemBlock ?: self.selectItemBlock(item);
    }
    else if (!self.hasMoreData && !self.items.count) {
        !self.selectNoneBlock ?: self.selectNoneBlock();
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.hasMoreData && !self.items.count) {
        return self.noneCellHeight;
    }
    else {
        return self.dataCellHeight;
    }
}

@end
