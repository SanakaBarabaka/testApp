//
//  SettingViewController.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController
{
    IBOutlet UIButton*	logoutButton;
    IBOutlet UILabel*	userNameLabel;
}

- (IBAction)onLogOutButton:(id)sender;

@end