//
//  LogInViewController.h
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import <UIKit/UIKit.h>


@interface LogInViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField*	loginTextField;
    IBOutlet UITextField*	passwordTextField;
    IBOutlet UIButton*		loginButton;
}

- (IBAction)onLogInButton:(id)sender;
- (IBAction)onTextFieldValueChanged:(id)sender;

@end