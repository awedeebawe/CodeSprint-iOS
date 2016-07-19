//
//  CreateTeamViewController.m
//  CodeSprint
//
//  Created by Vincent Chau on 7/12/16.
//  Copyright © 2016 Vincent Chau. All rights reserved.
//

#import "CreateTeamViewController.h"
#import <RWBlurPopover/RWBlurPopover.h>
#import "ImageStyleButton.h"
#import "FirebaseManager.h"
#import "Team.h"

#define MAX_INPUT_LENGTH 12

BOOL didCreate = false;
@interface CreateTeamViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *teamTextField;
@property (nonatomic, strong) UITapGestureRecognizer *contentTapGesture;
@property (assign) BOOL gitHubSignIn;
@end

@implementation CreateTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _teamTextField.delegate = self;
    [self setupButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Setup
-(CGSize)preferredContentSize{
    return CGSizeMake(280.0f, 320.0f);
}
-(void)setupButtons{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.contentTapGesture = tap;
    self.contentTapGesture.enabled = NO;
    [self.view addGestureRecognizer:tap];

    UIImage* closeImage = [UIImage imageNamed:@"Close-Button"];
    CGRect frameimg = CGRectMake(0, 0, closeImage.size.width, closeImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frameimg];
    [button setBackgroundImage:closeImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismiss)
         forControlEvents:UIControlEventTouchUpInside];
    [button setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *closeButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = closeButton;
    self.navigationItem.title = @"Create";
}

#pragma mark - IBActions
- (IBAction)createButtonPressed:(id)sender {
    didCreate = false;
    NSString *inputText = self.teamTextField.text;
    
    if ([inputText isEqualToString:@""]) {
        [self showAlertWithTitle:@"Error: No Input" andMessage:@"Please enter a teamname to create."
                 andDismissNamed:@"Dismiss"];
        return;
    }
    NSCharacterSet *charSet = [NSCharacterSet
                               characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    charSet = [charSet invertedSet];
    NSRange range = [self.teamTextField.text rangeOfCharacterFromSet:charSet];
        
    if (range.location != NSNotFound) {
        [self showAlertWithTitle:@"Invalid Characters" andMessage:@"Please enter a name containing only: [A-Z], [a-z], [0-9], -, _"
                 andDismissNamed:@"Dismiss"];
        return;
    }
    [FirebaseManager isNewTeam:inputText withCompletion:^(BOOL result) {
        if (result) {
            [self.delegate createdNewTeam:inputText];
            didCreate = true;
            [self dismiss];
        }else if (!result && !didCreate){
            [self showAlertWithTitle:@"Error" andMessage:@"This team name is already taken, Please enter another team identifier."
                     andDismissNamed:@"Ok"];
            didCreate = false;
            return;
        }
    }];
}
- (IBAction)cancelButtonPressed:(id)sender {
    self.teamTextField.text = @"";
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(range.length + range.location > textField.text.length){
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= MAX_INPUT_LENGTH;
}

#pragma mark - Helper methods
-(void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message andDismissNamed:(NSString*)dismiss{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:dismiss style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
