//
//  NetDisplayView.m
//  2048NN
//
//  Created by Michael Nolan on 3/4/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "NetDisplayView.h"
#include <math.h>
@implementation NetDisplayView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
	
	if(_netToDisplay != nil){
		int x = dirtyRect.origin.x;
		int y = dirtyRect.size.height- _netToDisplay.layersize*2 -10;
		for(CENetworkLayer *layer in _netToDisplay.layerList){
			size_t size = layer.width*layer.height*sizeof(float);
			
			const float* mat = layer.matrix;
			float* newMat = malloc(size);
			for(int i=0;i<size/4;i++){
				newMat[i]= fabsf((mat[i]/2.0f)+0.5f);
			}
			
			CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
			CGDataProviderRef dat = CGDataProviderCreateWithData(NULL, newMat, size, NULL);
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
			CGImageRef image = CGImageCreate(layer.width, layer.height, 32, 32, layer.width*sizeof(float), colorSpace, kCGBitmapFloatComponents|kCGBitmapByteOrderDefault, dat, nil, NO, kCGRenderingIntentDefault);
			CGContextDrawImage(context, CGRectMake(x, y, layer.width*2, layer.height*2), image);
			x+=layer.width*2+ 10;
			if(x+layer.width*2 > dirtyRect.origin.x + dirtyRect.size.width){
				x = dirtyRect.origin.x;
				y -= layer.height*2+10;
			}
			CGImageRelease(image);
			CGColorSpaceRelease(colorSpace);
			CGDataProviderRelease(dat);
			free(newMat);
		}
		
	}    // Drawing code here.
}

@end
