//
//  CommentsViewController.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <UIKit/UIKit.h>


@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel*		noCommentsLabel;
    IBOutlet UITableView*	commentsTable;
}

@property (nonatomic, retain) NSNumber*	shotID;

@end