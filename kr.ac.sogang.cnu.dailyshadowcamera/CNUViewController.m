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
    @property (nonatomic) NSString *albumName;
    // Real
    @property (nonatomic) UIImage *realImg;
    // Transition
    @property (nonatomic) BOOL isCameraReady;
    @property (nonatomic) UIImagePickerControllerSourceType source;
    @property (nonatomic) UIImagePickerControllerSourceType nextSource;
    // Alert
    @property (nonatomic) UIAlertView *AlbumNameNotFound;
    @property (nonatomic) UIAlertView *CloseApp;
    // IBAction
    - (IBAction)takepicture:(UIBarButtonItem *)sender;
    - (IBAction)done:(UIBarButtonItem *)sender;
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
        if([self albumName] == nil)
        {
            self.AlbumNameNotFound = [[UIAlertView alloc] initWithTitle:@"처음보는 실루엣이 등록되었습니다!"
                                                                message:@"새로운 보관함을 만들 이름이 필요합니다."
                                                               delegate:self
                                                      cancelButtonTitle:@"싫어요"
                                                      otherButtonTitles:@"좋아요", nil];
            self.AlbumNameNotFound.alertViewStyle = UIAlertViewStylePlainTextInput;
            [self.AlbumNameNotFound show];
        }else{
            [self SavePhoto:[self realImg] To:[self albumName]];
        }
    }else{
        self.shadowImg = [info valueForKey:UIImagePickerControllerOriginalImage];
        [self FindingAlbumName:info];
        
        [self DelayedTransitionCueTo: UIImagePickerControllerSourceTypeCamera];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    @autoreleasepool {
        self.CloseApp = [[UIAlertView alloc] initWithTitle:@"따라찍을 사진을 고르지 않으셨습니다"
                                                        message:@"종료하시겠습니까? ㅠㅠ"
                                                       delegate:self
                                              cancelButtonTitle:@"아뇨!"
                                              otherButtonTitles:@"네!", nil];
        self.CloseApp.alertViewStyle = UIAlertViewStyleDefault;
        [self.CloseApp show];
    }
}

- (void)FindingAlbumName:(NSDictionary *)info
{
    @autoreleasepool {
        NSURL *this = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stopSearchLibrary) {
            if(group != nil){
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopSearchGroup) {
                    if(result != nil){
                        if([this isEqual:[result valueForProperty:ALAssetPropertyAssetURL]]){
                            self.albumName = [[group valueForProperty:ALAssetsGroupPropertyName] copy];
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

- (void)SavePhoto: (UIImage *)photo To:(NSString *)album
{
    @autoreleasepool {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImage:photo toAlbum:album completion:^(NSURL *assetURL, NSError *error) {
            if(error)
                NSLog(@"err:%@\n", [error description]);
        } failure:^(NSError *error) {
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


///////////////////////////////////////////////////////////////  UIAlertViewDelegate!
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        // YES
        if([alertView isEqual:[self AlbumNameNotFound]]){
            NSLog(@"%@\n", [[alertView textFieldAtIndex:0] text]);
            self.albumName = [[[alertView textFieldAtIndex:0] text] copy];
            [self SavePhoto:[self shadowImg] To:[self albumName]];
            [self SavePhoto:[self realImg] To:[self albumName]];
        }else if([alertView isEqual:[self CloseApp]]){
            NSLog(@"Close App\n");
            exit(0);
        }
    }else{
        // NO
        if([alertView isEqual:[self AlbumNameNotFound]]){
            NSLog(@"AlertViewCanceled\n");
        }else if([alertView isEqual:[self CloseApp]]){
            ;
        }
    }
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
