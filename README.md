<img src="https://dl.dropbox.com/s/o3u1le1iczv741q/iOS_icon%4087.png" width="87">

#### Screenshots
<img src="https://dl.dropbox.com/s/3xp0k34tdi763ei/0x0ss-P3.jpg" width="215"> <img src="https://dl.dropboxusercontent.com/s/yf7k5cjkwbbh9um/0x0ss-P3-2.jpg" width="215"> <img src="https://dl.dropbox.com/s/58zlw8zrzweix61/0x0ss-P3-3.jpg" width="215"> <img src="https://dl.dropbox.com/s/x7lvz3swtji1kzl/0x0ss-P3-4.jpg" width="215">

**Key features**:
- Intelligent song meta-data tagging. (powered by Discogs API)
- Listen to songs while Sterrio is in the background.
- Easily organize music videos and create playlists.
- Sophisticated queue playback, repeat & shuffle modes.
- iCloud sync, AirPlay, library search and more...

#### App requirements & project history
Sterrio was last updated in late 2016 and tested on iOS 8, 9 and 10. Sterrio looks best on iPhone because autolayout was not a priority when learning iOS back in 2014. Sterrio was on the App Store for a few months before YouTube forced it off the App Store (ironically right before YouTube released YouTube Music). During it's time on the App Store, Sterrio received a 4.5 star rating with about 10k downloads.

Sterrio was a side project I started in May 2014 because I wanted to learn mobile development. I ended up growing very passionate about it and finally released it on the App Store in 2016. Many tough lessons were learned building this project, including but not limited to: releasing a mimimum viable product, getting feedback early, and iterating quickly. It is also an example for why unit testing and documentation is *crucial*  for a large project.

------------

This project doesn't have any unit tests - I was very junior when this was built. :) However, against the odds, Sterrio was actually petty stable during it's time on the iOS App Store. Based on device analytics, approximately 90% of installs were crash free.

#### Coming soon: 
Need to make it easy for anyone to specify their own YouTube and Discogs API keys. To do so now, the following should be updated:
<br/>**YouTube API key**
`YouTubeService.m - line 73`
<br/>**Discogs API key**
` DiscogsItem.m - line 41`

##### API Keys: 
The YouTube and Discogs API keys were at one point used in production. I disabled & revoked the keys when open sourcing this code.
