//
//  LogInViewController.m
//  TestApp
//
//  Created by Александр Кириченко on 05.08.13.
//
//

#import "LogInViewController.h"
#import "DatabaseManager.h"
#import "MainViewController.h"


#define PORTRAIT_KEYBOARD_HEIGHT	216.0f
#define KEYBOARD_PADDING			0.0f
#define SLIDE_INTERVAL				0.3f


@interface LogInViewController ()
{
    // допустимые пользователи  (ключи - это пользовательские имена)
    NSDictionary*	validUsers;
    NSCharacterSet*	validCharacters;
    
    //--graphics--
    float			bottomPositionY;
    
    bool			isiPad;
}

@end


@implementation LogInViewController


#pragma mark ----- Initialization -----


- (void)dealloc
{
    [validUsers release];
    [validCharacters release];
    [loginTextField release];
    [passwordTextField release];
    [loginButton release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // отображение загрузилось, доинициализируемся
    // запомним допустимые логины и пароли для пользователя
    validUsers = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"testPassword", @"testUser",
                       @"testPassword2", @"testUser2",
                       @"adminPass", @"admin",
                       nil];
    NSMutableCharacterSet* temp = [[NSMutableCharacterSet characterSetWithCharactersInString:@""] retain];
    [temp formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
    [temp formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    validCharacters = [[temp invertedSet] retain];
    [temp release];
    
    bottomPositionY = self.view.frame.origin.y;
    loginButton.enabled = false;
    
    isiPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


#pragma mark ----- Actions -----


- (void)onLogInButton:(id)sender
{
    // проверка
    if (loginTextField.text != nil && passwordTextField.text != nil)
    {
        // имя пользователя и пароль должны быть из списка допустимых
        NSString* acceptablePassword = [validUsers objectForKey:loginTextField.text];
        if ([passwordTextField.text isEqualToString:acceptablePassword])
        {
            // попробуем залогиниться с такими данными
            bool logged = [[DatabaseManager sharedDatabaseManager] loginWithUserName:loginTextField.text
                                                                            password:passwordTextField.text];
            // неуспешно?
            if (!logged)
            {
                // значит такого пользователя в базе еще нет
                // добавим его
                [[DatabaseManager sharedDatabaseManager] addNewUser:loginTextField.text
                                                           password:passwordTextField.text];
                // залогинимся в него
                [[DatabaseManager sharedDatabaseManager] loginWithUserName:loginTextField.text
                                                                  password:passwordTextField.text];
            }
            // покажем главное окно (уберем себя)
            [self dismissViewControllerAnimated:true
                                     completion:nil];
        }
    }
}


- (void)onTextFieldValueChanged:(id)sender
{
    // проверим введенный текст на правильность
    bool valid = true;
    valid &= loginTextField.text.length <= 16;
    valid &= loginTextField.text.length >= 6;
    
    NSRange temp = [loginTextField.text rangeOfCharacterFromSet:validCharacters];
    valid &= temp.length == 0;
    // в обоих полях
    valid &= passwordTextField.text.length <= 16;
    valid &= passwordTextField.text.length >= 6;
    
    temp = [passwordTextField.text rangeOfCharacterFromSet:validCharacters];
    valid &= temp.length == 0;
    
    loginButton.enabled = valid;
}


#pragma mark ----- UITextFieldDelegate -----


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (isiPad)
        // тут хватает места - никуда не двигаем
        return;
    [UIView animateWithDuration:SLIDE_INTERVAL
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         CGRect temp = self.view.frame;
                         temp.origin.y = PORTRAIT_KEYBOARD_HEIGHT + KEYBOARD_PADDING - loginButton.frame.origin.y - loginButton.frame.size.height;
                         self.view.frame = temp;
                     }
                     completion:nil];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (isiPad)
        // и не возвращаемся обратно
        return;
    [UIView animateWithDuration:SLIDE_INTERVAL
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         CGRect temp = self.view.frame;
                         temp.origin.y = bottomPositionY;
                         self.view.frame = temp;
                     }
                     completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // уберем клавиатуру
    [textField resignFirstResponder];
    // попробуем залогиниться
    [self onLogInButton:nil];
    return true;
}


@end