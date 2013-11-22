//
//  CNUViewController.m
//  kr.ac.sogang.cnu.dailyshadowcamera
//
//  Created by CNU on 11/22/13.
//  Copyright (c) 2013 CNU. All rights reserved.
//

#import "CNUViewController.h"



@interface CNUViewController ()

// Outlet
@property (strong, nonatomic) IBOutlet UIView *overlayView;
// ImagePicker
@property (nonatomic) UIImagePickerController *imagePickerController;
// Shadow
@property (nonatomic) UIImage *shadowImg;
// Real
@property (nonatomic) UIImage *realImg;
// Transition
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL now;
@property (nonatomic) UIImagePickerControllerSourceType source;
@property (nonatomic) UIImagePickerControllerSourceType nextSource;

@end



@implementation CNUViewController
@synthesize uiSlider;
@synthesize BringImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.source = UIImagePickerControllerSourceTypePhotoLibrary;
    self.now = NO;
    [self performSelector:@selector(runImagePicker) withObject:nil afterDelay:0.50];
}


- (void)runImagePicker
{
    self.now = YES;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    self.imagePickerController = imagePickerController;

    self.imagePickerController.sourceType = self.source;
    if([self source] == UIImagePickerControllerSourceTypeCamera){
        self.imagePickerController.showsCameraControls = YES;
        
        // xib overlay
        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        self.overlayView.frame = self.imagePickerController.view.frame;
        self.imagePickerController.cameraOverlayView = self.overlayView;
        
        BringImage.image = self.shadowImg;
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


-(void)viewWillAppear:(BOOL)animated {
    if([self now])
    if([self source] == UIImagePickerControllerSourceTypeCamera){
        [self presentViewController:self.imagePickerController animated:animated completion:nil];
        self.imagePickerController.cameraOverlayView = self.overlayView;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([self source] == UIImagePickerControllerSourceTypeCamera){
        self.realImg = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        self.shadowImg = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        NSURL *this = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSLog(@"Sel: %@\n", this);
        
        __block NSString *name = nil;
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group != nil){
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop2) {
                    if(result != nil){
                        NSURL *that = [result valueForProperty:ALAssetPropertyAssetURL];
                        //NSLog(@"new: %@\n", [result valueForProperty:ALAssetPropertyAssetURL]);
                        if([this isEqual:that]){
                            name = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
                            NSLog(@"From : %@ Group!!!!", name);
                            *stop2 = YES;
                            *stop = YES;
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"err:%@\n", [error description]);
        }];
        NSLog(@"What!\n");
        [self DelayedTransitionCueTo: UIImagePickerControllerSourceTypeCamera];
        [self dismissViewControllerAnimated:YES completion:NULL];
    };
}


- (void)DelayedTransitionCueTo: (UIImagePickerControllerSourceType)source
{
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:2.0];
    NSTimer *Timer = [[NSTimer alloc] initWithFireDate:fireDate interval:1.0 target:self selector:@selector(timedTransitionFire:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:Timer forMode:NSDefaultRunLoopMode];
    self.Timer = Timer;
    self.nextSource = source;
}


- (void)timedTransitionFire:(NSTimer *)timer
{
    self.source = self.nextSource;
    [self performSelector:@selector(runImagePicker) withObject:nil afterDelay:2];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)OpacitySliderChanged:(UISlider *)sender {
    BringImage.alpha = [sender value];

}



@end
