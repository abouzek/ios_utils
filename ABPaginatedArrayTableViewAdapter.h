//
//  BFPaginatedArrayTableViewAdapter.h
//
//  Created by Alan Bouzek on 3/25/15.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ABPaginatedDataSource <UITableViewDataSource>

@property (nonatomic) BOOL hasMoreData, isLoading;

-(void)loadDataWithStartIndex:(NSInteger)index;
-(id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end


extern NSUInteger const DEFAULT_PAGE_SIZE;

typedef void(^ABCellConfigureBlock)(id cell, id item);
typedef void(^ABSelectItemBlock)(id item);
typedef void(^ABSelectNoneBlock)();
typedef void(^ABPaginatedLoadingCompletionBlock)(NSArray *loadedItems);
typedef void(^ABPaginatedLoadingBlock)(NSUInteger startIndex,
                                       NSUInteger numberOfItems,
                                       ABPaginatedLoadingCompletionBlock completionBlock);

@interface ABPaginatedArrayTableViewAdapter : NSObject <ABPaginatedDataSource, UITableViewDelegate>

-(instancetype)initWithItems:(NSMutableArray *)items
          dataCellIdentifier:(NSString *)dataCellIdentifier
          noneCellIdentifier:(NSString *)noneCellIdentifier
       loadingCellIdentifier:(NSString *)loadingCellIdentifier
           endCellIdentifier:(NSString *)endCellIdentifier
              dataCellHeight:(CGFloat)cellHeight
              noneCellHeight:(CGFloat)cellHeight
          cellConfigureBlock:(ABCellConfigureBlock)cellConfigureBlock
             selectItemBlock:(ABSelectItemBlock)selectItemBlock
             selectNoneBlock:(ABSelectNoneBlock)selectNoneBlock
                loadingBlock:(ABPaginatedLoadingBlock)loadingBlock;

@end
