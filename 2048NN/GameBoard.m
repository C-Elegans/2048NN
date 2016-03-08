//
//  GameBoard.m
//  2048NN
//
//  Created by Michael Nolan on 3/8/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "GameBoard.h"

@implementation GameBoard
int tiles[4][4];
-(id)init{
	self = [super init];
	memset(tiles, 0, sizeof(tiles));
	[self addRandomTiles];
	
	return self;
}
-(int*)tiles{
	return (int*)tiles;
}


-(void)moveTilesDown{
	for(int k=0;k<3;k++){
		for(int i=0;i<4;i++){
			for(int j=2;j>=0;j--){
				int val = tiles[j][i];
				if (tiles[j+1][i] == 0 && val >0){
					tiles[j][i] = 0;
					tiles[j+1][i] = val;
				}
				else if(tiles[j+1][i] == val && val >0){
					tiles[j][i] = 0;
					tiles[j+1][i] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesUp{
	for(int k=0;k<3;k++){
		for(int i=0;i<4;i++){
			for(int j=1;j<4;j++){
				int val = tiles[j][i];
				if (tiles[j-1][i] == 0 && val >0){
					tiles[j][i] = 0;
					tiles[j-1][i] = val;
				}else if(tiles[j-1][i] == val && val >0){
					tiles[j][i] = 0;
					tiles[j-1][i] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesRight{
	for(int k=0;k<3;k++){
		for(int j=0;j<4;j++){
			for(int i=2;i>=0;i--){
				int val=tiles[j][i];
				if(tiles[j][i+1]==0 &&val>0){
					tiles[j][i] = 0;
					tiles[j][i+1] = val;
				}
				else if(tiles[j][i+1] == val && val >0){
					tiles[j][i] = 0;
					tiles[j][i+1] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(void)moveTilesLeft{
	for(int k=0;k<3;k++){
		for(int j=0;j<4;j++){
			for(int i=1;i<4;i++){
				int val=tiles[j][i];
				if(tiles[j][i-1]==0 &&val>0){
					tiles[j][i] = 0;
					tiles[j][i-1] = val;
				}
				else if(tiles[j][i-1] == val && val >0){
					tiles[j][i] = 0;
					tiles[j][i-1] = 2*val;
					_score += 2*val;
				}
			}
		}
	}
}
-(int)countEmpty{
	int sum=0;
	for(int i=0;i<4;i++){
		for(int j=0;j<4;j++){
			if(tiles[i][j] == 0)sum++;
		}
	}
	return sum;
}
-(void) addRandomTiles{
	if([self countEmpty]==0){
		_didMove = NO;
		return;
	}
	int tileToAdd = arc4random_uniform([self countEmpty]);
	int val = rand()&8;
	for(int i=0;i<4;i++){
		for(int j=0;j<4;j++){
			if(tiles[j][i] == 0){
				if(tileToAdd == 0){
					tiles[j][i] = val!=0?2:4;
					tileToAdd--;
					
					
				}
				tileToAdd--;
			}
		}
	}
}

-(void)moveTiles:(short)key{
	switch (key)
	{
		case LEFT:
		[self moveTilesLeft];
		break;
		case RIGHT:
		[self moveTilesRight];
		break;
		case DOWN:
		[self moveTilesDown];
		break;
		case UP:
		[self moveTilesUp];
		break;
		
	}
}
-(void)testMove:(int*)tempArray{
	if(memcmp(tempArray, tiles, sizeof(int)*4*4)){
		[self addRandomTiles];
		_didMove = YES;
		//if(arc4random_uniform(7)==0)[self addRandomTiles];
	}else{
		_didMove = NO;
	}
}
-(void)pressKey:(short)key display:(BOOL)display{
	
	int tempArray[4][4];
	memcpy(tempArray, tiles, sizeof(tempArray));
	[self moveTiles:key];
	[self testMove:(int*)tempArray];
	if(_didMove)return;
	int i=0;
	int x=(key-LEFT)+1;
	while(i<1){
		memcpy(tempArray, tiles, sizeof(tempArray));
		[self moveTiles:LEFT +(x&3)];
		[self testMove:(int*)tempArray];
		if(_didMove)break;
		i++;
		x++;
		
	}
	
	
}

-(void)getFloats:(float*)results{
	int* t = &tiles[0][0];
	int highestTile = 0;
	for(int i=0;i<16;i++){
		if(t[i]>highestTile)highestTile = t[i];
	}
	for(int i=0;i<16;i++){
		results[i] =t[i] >0? log2f(t[i])/(float)highestTile:0;
		//results[i] = t[i];
	}
	results[16] = _didMove ? 1.0:0.0;
}
-(void)activate:(float*) values display:(BOOL)display{
	if(values[0]>0){
		if(values[1]>0){
			[self pressKey:UP display:display];
		}else{
			[self pressKey:LEFT display:display];
		}
	}else{
		if(values[1]>0){
			[self pressKey:DOWN display:display];
		}else{
			[self pressKey:RIGHT display:display];
		}
	}
}
@end
