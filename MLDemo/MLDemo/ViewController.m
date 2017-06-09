//
//  ViewController.m
//  MLDemo
//
//  Created by CoderXu on 2017/6/9.
//  Copyright © 2017年 XanderXu. All rights reserved.
//

#import "ViewController.h"

#import "GoogLeNetPlaces.h"
#import "UIImage+Utils.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIImage *image = self.imageView.image;
    NSString *sceneLabel = [self predictImageScene:image];
    NSLog(@"Scene label is: %@", sceneLabel);
    self.label.text = [NSString stringWithFormat:@"识别结果是:%@",sceneLabel];
}


#pragma mark events
- (IBAction)click:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选取图片" message:@"从相册或相机获取图片" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //从相册中读取
        [self readImageFromAlbum];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //拍照
        [self readImageFromCamera];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

#pragma mark  myfunction
- (NSString *)predictImageScene:(UIImage *)image {
    GoogLeNetPlaces *model = [[GoogLeNetPlaces alloc] init];
    NSError *error;
    //mlmodel只识别224*224图片
    UIImage *scaledImage = [image scaleToSize:CGSizeMake(224, 224)];
    CVPixelBufferRef buffer = [image pixelBufferFromCGImage:scaledImage];
    GoogLeNetPlacesInput *input = [[GoogLeNetPlacesInput alloc] initWithSceneImage:buffer];
    GoogLeNetPlacesOutput *output = [model predictionFromFeatures:input error:&error];
    return output.sceneLabel;
}

//从相册中读取
- (void)readImageFromAlbum {
    //创建对象
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //（选择类型）表示仅仅从相册中选取照片
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //指定代理，因此我们要实现UIImagePickerControllerDelegate,UINavigationControllerDelegate协议
    imagePicker.delegate = self;
    //设置在相册选完照片后，是否跳到编辑模式进行图片剪裁。(允许用户编辑)
    imagePicker.allowsEditing = YES;
    //显示相册
    [self presentViewController:imagePicker animated:YES completion:nil];
}
//从相机获取图片
- (void)readImageFromCamera {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES; //允许用户编辑
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    } else {
        //弹出窗口响应点击事件
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"警告" message:@"未检测到摄像头" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
}

#pragma mark ImagePickerDelegate
//图片完成之后处理
- (void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary *)info
{
    //获得编辑过的图片
    UIImage* image = [info objectForKey: @"UIImagePickerControllerEditedImage"];
    self.imageView.image = image;
    //结束操作,自动识别
    [self dismissViewControllerAnimated:YES completion:nil];
}

//取消选取图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
