//
//  PreloadedCoreDataModelUtility.m
//  Muzic
//
//  Created by Mark Zgaljic on 12/24/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "PreloadedCoreDataModelUtility.h"
#import "Song+Utilities.h"
#import "Artist+Utilities.h"
#import "Album+Utilities.h"
#import "SongAlbumArt+Utilities.h"

@implementation PreloadedCoreDataModelUtility
static NSString * const SONG1_NAME = @"Bleeding Love";
static NSString * const SONG1_YTID = @"Vzo-EL_62fQ";
static NSString * const ARTIST1_NAME = @"Leona Lewis";
static NSString * const ALBUM1_NAME = @"Spirit (Deluxe)";
static NSInteger const SONG1_DURATION = 278;

static NSString * const SONG2_NAME = @"Summer of 69";
static NSString * const SONG2_YTID = @"9f06QZCVUHg";
static NSString * const ARTIST2_NAME = @"Bryan Adams";
static NSString * const ALBUM2_NAME = @"Reckless";
static NSInteger const SONG2_DURATION = 221;

static NSString * const SONG3_NAME = @"How to Save a Life";
static NSString * const SONG3_YTID = @"rkBvhnri5s0";
static NSString * const ARTIST3_NAME = @"The Fray";
static NSInteger const SONG3_DURATION = 263;

static NSString * const SONG5_NAME = @"Geronimo";
static NSString * const ARTIST5_NAME = @"Sheppard";
static NSString * const SONG5_YTID = @"UL_EXAyGCkw";
static NSInteger const SONG5_DURATION = 219;

static NSString * const SONG6_NAME = @"The Days";
static NSString * const ARTIST6_NAME = @"Avicii";
static NSString * const SONG6_YTID = @"JDglMK9sgIQ";
static NSInteger const SONG6_DURATION = 247;

static NSString * const SONG7_NAME = @"Hound Dog";
static NSString * const ARTIST7_NAME = @"Elvis Presley";
static NSString * const SONG7_YTID = @"lzQ8GDBA8Is";
static NSInteger const SONG7_DURATION = 137;

+ (void)createCoreDataSampleMusicData
{
    BOOL importHugeDataSetForTesting = NO;
    BOOL importSmallSampleDataSetOnInitialLaunch = NO;
    
    NSManagedObjectContext *context = [CoreDataManager context];
    if(importHugeDataSetForTesting){
        int songCreationCount = 2000;
        
        NSString *leonaLewisSpiritAlbumArtUrl = @"http://goo.gl/KpS0cJ";
        NSURL *url = [NSURL URLWithString:leonaLewisSpiritAlbumArtUrl];
        UIImage *art = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
        Song *someSong;
        int stopToPrint = 0;
        for(int i = 0; i < songCreationCount; i++){
            
            if (i % 2 == 0) {
                // even
                someSong = [PreloadedCoreDataModelUtility createSongWithName:SONG2_NAME
                                                                byArtistName:ARTIST2_NAME
                                                            partOfAlbumNamed:ALBUM2_NAME
                                                                   youtubeID:SONG2_YTID
                                                               videoDuration:SONG2_DURATION];
                someSong.albumArt = [SongAlbumArt createNewAlbumArtWithUIImage:art withContext:context];
                someSong.nonDefaultArtSpecified = @YES;

            } else {
                // odd
                [PreloadedCoreDataModelUtility createSongWithName:SONG5_NAME
                                                     byArtistName:ARTIST5_NAME
                                                 partOfAlbumNamed:nil
                                                        youtubeID:SONG5_YTID
                                                    videoDuration:SONG5_DURATION];
            }
            
            if(i == stopToPrint && i != songCreationCount){
                NSLog(@"songsCreated: %i", i);
                stopToPrint += 500;
                [[CoreDataManager sharedInstance] saveContext];
            }
        }
        [[CoreDataManager sharedInstance] saveContext];
    }
    else{
        if(! importSmallSampleDataSetOnInitialLaunch)
            return;
        
        [PreloadedCoreDataModelUtility createSongWithName:SONG1_NAME
                                             byArtistName:ARTIST1_NAME
                                         partOfAlbumNamed:ALBUM1_NAME
                                                youtubeID:SONG1_YTID
                                            videoDuration:SONG1_DURATION];
        
        [PreloadedCoreDataModelUtility createSongWithName:SONG2_NAME
                                             byArtistName:ARTIST2_NAME
                                         partOfAlbumNamed:ALBUM2_NAME
                                                youtubeID:SONG2_YTID
                                            videoDuration:SONG2_DURATION];
        
        [PreloadedCoreDataModelUtility createSongWithName:SONG3_NAME
                                             byArtistName:ARTIST3_NAME
                                         partOfAlbumNamed:nil
                                                youtubeID:SONG3_YTID
                                            videoDuration:SONG3_DURATION];
        
        [PreloadedCoreDataModelUtility createSongWithName:SONG5_NAME
                                             byArtistName:ARTIST5_NAME
                                         partOfAlbumNamed:nil
                                                youtubeID:SONG5_YTID
                                            videoDuration:SONG5_DURATION];
        [PreloadedCoreDataModelUtility createSongWithName:SONG6_NAME
                                             byArtistName:ARTIST6_NAME
                                         partOfAlbumNamed:nil
                                                youtubeID:SONG6_YTID
                                            videoDuration:SONG6_DURATION];
        [PreloadedCoreDataModelUtility createSongWithName:SONG7_NAME
                                             byArtistName:ARTIST7_NAME
                                         partOfAlbumNamed:nil
                                                youtubeID:SONG7_YTID
                                            videoDuration:SONG7_DURATION];
        [[CoreDataManager sharedInstance] saveContext];
    }
}

+ (Song *)createSongWithName:(NSString *)songName
              byArtistName:(NSString *)artistName
          partOfAlbumNamed:(NSString *)albumName
                 youtubeID:(NSString *)ytID
               videoDuration:(NSUInteger)durationInSecs
{
    Song *myNewSong;
    myNewSong = [Song createNewSongWithName:songName
                       inNewOrExistingAlbum:albumName
                      byNewOrExistingArtist:artistName
                           inManagedContext:[CoreDataManager context]
                               withDuration:durationInSecs];
    myNewSong.youtube_id = ytID;
    return myNewSong;
}

@end
