//
//  ViewController.h
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/14/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface ChatListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) UIRefreshControl *refreshControl;

@property (nonatomic, retain) NSMutableArray *chats;

@end

