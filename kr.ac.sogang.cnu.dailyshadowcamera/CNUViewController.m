//
//  CNUViewController.m
//  kr.ac.sogang.cnu.dailyshadowcamera
//
//  Created by CNU on 11/22/13.
//  Copyright (c) 2013 CNU. All rights reserved.
//

#import "CNUViewController.h"

@interface CNUViewController ()
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@end

@implementation CNUViewController
@synthesize uiSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.cameraViewTransform = CGAffineTransformIdentity;
    
    imagePickerController.showsCameraControls = NO;
    
    // xib overlay
    [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    self.overlayView.frame = imagePickerController.view.frame;
    imagePickerController.cameraOverlayView = self.overlayView;
    self.overlayView = nil;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    //    [self performSelector:@selector(functionA) withObject:nil afterDelay:0.50];
}

-(void)viewWillAppear:(BOOL)animated {
    [self presentViewController:self.imagePickerController animated:animated completion:nil];
    self.imagePickerController.cameraOverlayView = self.overlayView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uiSlideValueChanged:(id)sender {
    
}
@end
