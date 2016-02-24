//
//  RecognizeViewController.m
//  Scanner
//
//  Created by Jakey on 15/11/23.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "RecognizeViewController.h"
#import "ImagePickerController.h"
#import "JKAlert.h"
#import "InfoViewController.h"

#import "Scanner.h"
#import "DateManager.h"
@interface RecognizeViewController ()

@end

@implementation RecognizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)recognizeFinishingBlock:(RecognizeFinishingBlock)recognizeFinishingBlock{
    _recognizeFinishingBlock = [recognizeFinishingBlock copy];
}

- (IBAction)browseTouched:(id)sender {
    JKAlert *alert = [[JKAlert alloc]initWithTitle:@"选择照片来源" andMessage:nil  style:STYLE_ALERT];
    [alert addButton:ITEM_OTHER withTitle:@"相机" handler:^(JKAlertItem *item) {
        [self showPicker:UIImagePickerControllerSourceTypeCamera];
    }];
    [alert addButton:ITEM_OTHER withTitle:@"图片库" handler:^(JKAlertItem *item) {
        [self showPicker:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }];
    [alert addButton:ITEM_OTHER withTitle:@"保存的相片" handler:^(JKAlertItem *item) {
        [self showPicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }];
    [alert addButtonWithTitle:@"取消"];
    [alert show];

}
-(void)showPicker:(UIImagePickerControllerSourceType)type{
    //sourceType = UIImagePickerControllerSourceTypeCamera; //照相机
    //sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //图片库
    //sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; //保存的相片
    
    ImagePickerController *picker = [[ImagePickerController alloc] init];
    [picker setAllowsEditing:YES];
    [picker cameraSourceType:type onFinishingBlock:^(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage) {
        self.preImageView.image = editedImage?:originalImage;
        [self recognizeImage: editedImage?:originalImage];
    } onCancelingBlock:^() {
        
    }];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}
-(NSDictionary*)recognizeImage:(UIImage*)image{
    CIContext *content = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:content options:nil];
    CIImage *cimage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:cimage];
    
    CIQRCodeFeature *f = [features firstObject];
    NSLog(@"f.messageString:%@",f.messageString);
    
    if (_recognizeFinishingBlock && f.messageString) {
        _recognizeFinishingBlock(f.messageString);
    }else{
        [JKAlert showMessage:@"啥都没扫到,换个姿势吧!"];
    }
    return nil;
}
@end
