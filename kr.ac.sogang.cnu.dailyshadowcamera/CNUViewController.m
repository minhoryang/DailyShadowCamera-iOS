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
    @property (nonatomic) NSString *groupName;
    // Real
    @property (nonatomic) UIImage *realImg;
    // Transition
    @property (nonatomic) BOOL isCameraReady;
    @property (nonatomic) UIImagePickerControllerSourceType source;
    @property (nonatomic) UIImagePickerControllerSourceType nextSource;
- (IBAction)takepicture:(UIButton *)sender;

- (IBAction)done:(UIButton *)sender;

- (IBAction)switchCamera:(id)sender;

@end

#define DELAY 0.50

@implementation CNUViewController
    @synthesize uiSlider;
    @synthesize BringImage;

///////////////////////////////////////////////////////////////  default functions.
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.source = UIImagePickerControllerSourceTypePhotoLibrary;
    [self performSelector:@selector(runImagePicker) withObject:nil afterDelay:DELAY];
}
-(void)viewWillAppear:(BOOL)animated {
    if([self source] == UIImagePickerControllerSourceTypeCamera){
        if([self isCameraReady]){
            [self presentViewController:self.imagePickerController animated:animated completion:nil];
            self.imagePickerController.cameraOverlayView = self.overlayView;
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///////////////////////////////////////////////////////////////


- (void)runImagePicker
{
    @autoreleasepool {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        self.imagePickerController = imagePickerController;

        self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;

        self.imagePickerController.sourceType = self.source;

        self.isCameraReady = NO;
        if([self source] == UIImagePickerControllerSourceTypeCamera){
            self.isCameraReady = YES;
            self.imagePickerController.showsCameraControls = NO;
            self.imagePickerController.cameraViewTransform = CGAffineTransformIdentity;
        
            // xib overlay
            if(self.overlayView == nil)
                [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
            self.overlayView.frame = self.imagePickerController.view.frame;
            self.imagePickerController.cameraOverlayView = self.overlayView;
        
            BringImage.image = self.shadowImg;
        }
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([self source] == UIImagePickerControllerSourceTypeCamera){
        self.realImg = [info valueForKey:UIImagePickerControllerOriginalImage];
    }else{
        self.shadowImg = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self FindingGroupName:info];
        
        [self DelayedTransitionCueTo: UIImagePickerControllerSourceTypeCamera];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Cancel\n");
}


- (void)FindingGroupName:(NSDictionary *)info
{
    @autoreleasepool {
        NSURL *this = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stopSearchLibrary) {
            if(group != nil){
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopSearchGroup) {
                    if(result != nil){
                        if([this isEqual:[result valueForProperty:ALAssetPropertyAssetURL]]){
                            self.groupName = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
                            *stopSearchLibrary = (*stopSearchGroup = YES);
                        }
                    }
                }];
                
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"err:%@\n", [error description]);
        }];
    }
}


///////////////////////////////////////////////////////////////  Transition Timer!
- (void)DelayedTransitionCueTo: (UIImagePickerControllerSourceType)source
{
    @autoreleasepool {
        NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:DELAY];
        NSTimer *Timer = [[NSTimer alloc] initWithFireDate:fireDate interval:0.1 target:self selector:@selector(timedTransitionFire:) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:Timer forMode:NSDefaultRunLoopMode];
    }
    
    self.nextSource = source;
    if(self.nextSource != UIImagePickerControllerSourceTypeCamera)
        self.isCameraReady = NO;
}
- (void)timedTransitionFire:(NSTimer *)timer
{
    self.source = self.nextSource;
    [self performSelector:@selector(runImagePicker) withObject:nil afterDelay:DELAY];
}
///////////////////////////////////////////////////////////////


- (IBAction)OpacitySliderChanged:(UISlider *)sender {
    BringImage.alpha = [sender value];
}


- (IBAction)takepicture:(UIBarButtonItem *)sender {
    [self.imagePickerController takePicture];
}


- (IBAction)done:(UIBarButtonItem *)sender {
    [self DelayedTransitionCueTo: UIImagePickerControllerSourceTypePhotoLibrary];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)switchCamera:(id)sender {
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    } else{
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    
}

@end
