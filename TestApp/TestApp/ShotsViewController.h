//
//  ShotsViewController.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <UIKit/UIKit.h>


@class ShotsCell;


@interface ShotsViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDataSource>
{
    IBOutlet UILabel*		noShotsLabel;
    IBOutlet UITableView*	shotsTable;
    IBOutlet UISearchBar*	searchBar;
}

@property (nonatomic, assign) bool					favoritesOnlyMode;
@property (nonatomic, retain) IBOutlet ShotsCell*	cellEtalon;

@end