//  GenreConstants.m
//  Free Music Library
//
//  Created by Mark Zgaljic on 5/31/14.
//  Copyright (c) 2014 Mark Zgaljic. All rights reserved.
//

#import "GenreConstants.h"

@implementation GenreConstants : NSObject

+ (NSArray *)alphabeticallySortedUserPresentableArrayOfGenreStringsAvailable  //good for showing all posibilities
{
    NSMutableArray *genreStrings = [NSMutableArray arrayWithArray:[GenreConstants loadGenreStrings]];
    [genreStrings removeObject:[GenreConstants noGenreSelectedGenreString]];
    [GenreConstants sortListOfAllGenresAlphabetically:&genreStrings];
    return genreStrings;
}

+ (NSArray *)unsortedRawArrayOfGenreStringsAvailable  //good for searching
{
    NSMutableArray *genreStrings = [NSMutableArray arrayWithArray:[GenreConstants loadGenreStrings]];
    [genreStrings removeObject:[GenreConstants noGenreSelectedGenreString]];
    return genreStrings;
}

+ (NSString *)genreCodeToString:(int)aGenreCode
{
    //lazy load required data into memory
    NSArray *genreCodes = [GenreConstants loadGenreCodes];
    NSArray *genreStrings = [GenreConstants loadGenreStrings];
    
    short indexOfCode = -1;
    for(short i = 0; i < genreCodes.count; i++){
        if([genreCodes[i] integerValue] == aGenreCode){
            indexOfCode = i;
            break;
        }
    }
    if(indexOfCode == -1)
        return nil;
    else
        return genreStrings[indexOfCode];
}

+ (int)genreStringToCode:(NSString *)aGenreString
{
    //lazy load required data into memory
    NSArray *genreStrings = [GenreConstants loadGenreStrings];
    NSArray *genreCodes = [GenreConstants loadGenreCodes];
    
    short indexOfString = -1;
    for(short i = 0; i < genreStrings.count; i++){
        if([genreStrings[i] isEqualToString:aGenreString]){
            indexOfString = i;
            break;
        }
    }
    if(indexOfString == -1)
        return -1;
    else
        return (int)[genreCodes[indexOfString] integerValue];
}

//these 'codes' are the genre codes corresponding to each genre. Codes used from itunes lol
+ (NSArray *)loadGenreCodes
{
    return @[[NSNumber numberWithInt:2],[NSNumber numberWithInt:1007],[NSNumber numberWithInt:1009],[NSNumber numberWithInt:1010],[NSNumber numberWithInt:1011],[NSNumber numberWithInt:1012],[NSNumber numberWithInt:1013],[NSNumber numberWithInt:1210],[NSNumber numberWithInt:3],[NSNumber numberWithInt:1167],[NSNumber numberWithInt:1171],[NSNumber numberWithInt:4],[NSNumber numberWithInt:1014],[NSNumber numberWithInt:1015],[NSNumber numberWithInt:1016],[NSNumber numberWithInt:5],[NSNumber numberWithInt:1017],[NSNumber numberWithInt:1018],[NSNumber numberWithInt:1019],[NSNumber numberWithInt:1020],[NSNumber numberWithInt:1021],[NSNumber numberWithInt:1022],[NSNumber numberWithInt:1023],[NSNumber numberWithInt:1024],[NSNumber numberWithInt:1025],[NSNumber numberWithInt:1026],[NSNumber numberWithInt:1027],[NSNumber numberWithInt:1028],[NSNumber numberWithInt:1029],[NSNumber numberWithInt:1030],[NSNumber numberWithInt:1031],[NSNumber numberWithInt:1032],[NSNumber numberWithInt:1211],[NSNumber numberWithInt:6],[NSNumber numberWithInt:1033],[NSNumber numberWithInt:1034],[NSNumber numberWithInt:1035],[NSNumber numberWithInt:1036],[NSNumber numberWithInt:1037],[NSNumber numberWithInt:1038],[NSNumber numberWithInt:1039],[NSNumber numberWithInt:1040],[NSNumber numberWithInt:1041],[NSNumber numberWithInt:1042],[NSNumber numberWithInt:1043],[NSNumber numberWithInt:7],[NSNumber numberWithInt:1056],[NSNumber numberWithInt:1057],[NSNumber numberWithInt:1058],[NSNumber numberWithInt:1060],[NSNumber numberWithInt:1061],[NSNumber numberWithInt:8],[NSNumber numberWithInt:1079],[NSNumber numberWithInt:1080],[NSNumber numberWithInt:1081],[NSNumber numberWithInt:1082],[NSNumber numberWithInt:1083],[NSNumber numberWithInt:1084],[NSNumber numberWithInt:1085],[NSNumber numberWithInt:1086],[NSNumber numberWithInt:1087],[NSNumber numberWithInt:1088],[NSNumber numberWithInt:1089],[NSNumber numberWithInt:1090],[NSNumber numberWithInt:1091],[NSNumber numberWithInt:1092],[NSNumber numberWithInt:1093],[NSNumber numberWithInt:9],[NSNumber numberWithInt:10],[NSNumber numberWithInt:1062],[NSNumber numberWithInt:1063],[NSNumber numberWithInt:1064],[NSNumber numberWithInt:1065],[NSNumber numberWithInt:1066],[NSNumber numberWithInt:1067],[NSNumber numberWithInt:11],[NSNumber numberWithInt:1052],[NSNumber numberWithInt:1106],[NSNumber numberWithInt:1107],[NSNumber numberWithInt:1108],[NSNumber numberWithInt:1109],[NSNumber numberWithInt:1110],[NSNumber numberWithInt:1111],[NSNumber numberWithInt:1112],[NSNumber numberWithInt:1113],[NSNumber numberWithInt:1114],[NSNumber numberWithInt:1207],[NSNumber numberWithInt:1208],[NSNumber numberWithInt:1209],[NSNumber numberWithInt:12],[NSNumber numberWithInt:1115],[NSNumber numberWithInt:1116],[NSNumber numberWithInt:1117],[NSNumber numberWithInt:1118],[NSNumber numberWithInt:1119],[NSNumber numberWithInt:1120],[NSNumber numberWithInt:1121],[NSNumber numberWithInt:1123],[NSNumber numberWithInt:1124],[NSNumber numberWithInt:13],[NSNumber numberWithInt:1125],[NSNumber numberWithInt:1126],[NSNumber numberWithInt:1127],[NSNumber numberWithInt:1128],[NSNumber numberWithInt:1129],[NSNumber numberWithInt:1130],[NSNumber numberWithInt:14],[NSNumber numberWithInt:1131],[NSNumber numberWithInt:1132],[NSNumber numberWithInt:1133],[NSNumber numberWithInt:1134],[NSNumber numberWithInt:1135],[NSNumber numberWithInt:15],[NSNumber numberWithInt:1136],[NSNumber numberWithInt:1137],[NSNumber numberWithInt:1138],[NSNumber numberWithInt:1139],[NSNumber numberWithInt:1140],[NSNumber numberWithInt:1141],[NSNumber numberWithInt:1142],[NSNumber numberWithInt:1143],[NSNumber numberWithInt:16],[NSNumber numberWithInt:1165],[NSNumber numberWithInt:1166],[NSNumber numberWithInt:1168],[NSNumber numberWithInt:1169],[NSNumber numberWithInt:1172],[NSNumber numberWithInt:17],[NSNumber numberWithInt:1044],[NSNumber numberWithInt:1045],[NSNumber numberWithInt:1046],[NSNumber numberWithInt:1047],[NSNumber numberWithInt:1048],[NSNumber numberWithInt:1049],[NSNumber numberWithInt:1050],[NSNumber numberWithInt:1051],[NSNumber numberWithInt:18],[NSNumber numberWithInt:1068],[NSNumber numberWithInt:1069],[NSNumber numberWithInt:1070],[NSNumber numberWithInt:1071],[NSNumber numberWithInt:1072],[NSNumber numberWithInt:1073],[NSNumber numberWithInt:1074],[NSNumber numberWithInt:1075],[NSNumber numberWithInt:1076],[NSNumber numberWithInt:1077],[NSNumber numberWithInt:1078],[NSNumber numberWithInt:19],[NSNumber numberWithInt:1177],[NSNumber numberWithInt:1178],[NSNumber numberWithInt:1179],[NSNumber numberWithInt:1180],[NSNumber numberWithInt:1181],[NSNumber numberWithInt:1182],[NSNumber numberWithInt:1184],[NSNumber numberWithInt:1185],[NSNumber numberWithInt:1186],[NSNumber numberWithInt:1187],[NSNumber numberWithInt:1188],[NSNumber numberWithInt:1189],[NSNumber numberWithInt:1190],[NSNumber numberWithInt:1191],[NSNumber numberWithInt:1195],[NSNumber numberWithInt:1196],[NSNumber numberWithInt:1197],[NSNumber numberWithInt:1198],[NSNumber numberWithInt:1199],[NSNumber numberWithInt:1200],[NSNumber numberWithInt:1201],[NSNumber numberWithInt:1202],[NSNumber numberWithInt:1203],[NSNumber numberWithInt:1204],[NSNumber numberWithInt:1205],[NSNumber numberWithInt:1206],[NSNumber numberWithInt:20],[NSNumber numberWithInt:1001],[NSNumber numberWithInt:1002],[NSNumber numberWithInt:1003],[NSNumber numberWithInt:1004],[NSNumber numberWithInt:1005],[NSNumber numberWithInt:1006],[NSNumber numberWithInt:21],[NSNumber numberWithInt:1144],[NSNumber numberWithInt:1145],[NSNumber numberWithInt:1146],[NSNumber numberWithInt:1147],[NSNumber numberWithInt:1148],[NSNumber numberWithInt:1149],[NSNumber numberWithInt:1150],[NSNumber numberWithInt:1151],[NSNumber numberWithInt:1152],[NSNumber numberWithInt:1153],[NSNumber numberWithInt:1154],[NSNumber numberWithInt:1155],[NSNumber numberWithInt:1156],[NSNumber numberWithInt:1157],[NSNumber numberWithInt:1158],[NSNumber numberWithInt:1159],[NSNumber numberWithInt:1160],[NSNumber numberWithInt:1161],[NSNumber numberWithInt:1162],[NSNumber numberWithInt:1163],[NSNumber numberWithInt:22],[NSNumber numberWithInt:1094],[NSNumber numberWithInt:1095],[NSNumber numberWithInt:1096],[NSNumber numberWithInt:1097],[NSNumber numberWithInt:1098],[NSNumber numberWithInt:1099],[NSNumber numberWithInt:1100],[NSNumber numberWithInt:1101],[NSNumber numberWithInt:1103],[NSNumber numberWithInt:1104],[NSNumber numberWithInt:1105],[NSNumber numberWithInt:23],[NSNumber numberWithInt:1173],[NSNumber numberWithInt:1174],[NSNumber numberWithInt:1175],[NSNumber numberWithInt:1176],[NSNumber numberWithInt:24],[NSNumber numberWithInt:1183],[NSNumber numberWithInt:1192],[NSNumber numberWithInt:1193],[NSNumber numberWithInt:1194],[NSNumber numberWithInt:25],[NSNumber numberWithInt:1053],[NSNumber numberWithInt:1054],[NSNumber numberWithInt:1055],[NSNumber numberWithInt:27],[NSNumber numberWithInt:28],[NSNumber numberWithInt:29],[NSNumber numberWithInt:30],[NSNumber numberWithInt:50],[NSNumber numberWithInt:51],[NSNumber numberWithInt:52],[NSNumber numberWithInt:53],[NSNumber numberWithInt:1122],[NSNumber numberWithInt:1220],[NSNumber numberWithInt:1221],[NSNumber numberWithInt:1222],[NSNumber numberWithInt:1223],[NSNumber numberWithInt:1224],[NSNumber numberWithInt:1225],[NSNumber numberWithInt:1226],[NSNumber numberWithInt:1227],[NSNumber numberWithInt:1228],[NSNumber numberWithInt:1229],[NSNumber numberWithInt:50000061],[NSNumber numberWithInt:50000063],[NSNumber numberWithInt:50000064],[NSNumber numberWithInt:50000066],[NSNumber numberWithInt:50000068], [NSNumber numberWithInt:0]];
}  //code number 0 is for the ? genre.

+ (NSArray *)loadGenreStrings
{
    return @[@"Blues",@"Chicago Blues",@"Classic Blues",@"Contemporary Blues",@"Country Blues",@"Delta Blues",@"Electric Blues",@"Acoustic Blues",@"Comedy",@"Novelty",@"Standup Comedy",@"Children's Music",@"Lullabies",@"Sing-Along",@"Stories",@"Classical",@"Avant-Garde",@"Baroque",@"Chamber Music",@"Chant",@"Choral",@"Classical Crossover",@"Early Music",@"Impressionist",@"Medieval",@"Minimalism",@"Modern Composition",@"Opera",@"Orchestral",@"Renaissance",@"Romantic",@"Wedding Music",@"High Classical",@"Country",@"Alternative Country",@"Americana",@"Bluegrass",@"Contemporary Bluegrass",@"Contemporary Country",@"Country Gospel",@"Honky Tonk",@"Outlaw Country",@"Traditional Bluegrass",@"Traditional Country",@"Urban Cowboy",@"Electronic",@"Ambient",@"Downtempo",@"Electronica",@"IDM/Experimental",@"Industrial",@"Holiday",@"Chanukah",@"Christmas",@"Christmas: Children's",@"Christmas: Classic",@"Christmas: Classical",@"Christmas: Jazz",@"Christmas: Modern",@"Christmas: Pop",@"Christmas: R&B",@"Christmas: Religious",@"Christmas: Rock",@"Easter",@"Halloween",@"Holiday: Other",@"Thanksgiving",@"Opera",@"Singer/Songwriter",@"Alternative Folk",@"Contemporary Folk",@"Contemporary Singer/Songwriter",@"Folk-Rock",@"New Acoustic",@"Traditional Folk",@"Jazz",@"Big Band",@"Avant-Garde Jazz",@"Contemporary Jazz",@"Crossover Jazz",@"Dixieland",@"Fusion",@"Latin Jazz",@"Mainstream Jazz",@"Ragtime",@"Smooth Jazz",@"Hard Bop",@"Trad Jazz",@"Cool",@"Latino",@"Latin Jazz",@"Contemporary Latin",@"Pop Latino",@"Raíces",@"Reggaeton y Hip-Hop",@"Baladas y Boleros",@"Alternativo & Rock Latino",@"Regional Mexicano",@"Salsa y Tropical",@"New Age",@"Environmental",@"Healing",@"Meditation",@"Nature",@"Relaxation",@"Travel",@"Pop",@"Adult Contemporary",@"Britpop",@"Pop/Rock",@"Soft Rock",@"Teen Pop",@"R&B/Soul",@"Contemporary R&B",@"Disco",@"Doo Wop",@"Funk",@"Motown",@"Neo-Soul",@"Quiet Storm",@"Soul",@"Soundtrack",@"Foreign Cinema",@"Musicals",@"Original Score",@"Soundtrack",@"TV Soundtrack",@"Dance",@"Breakbeat",@"Exercise",@"Garage",@"Hardcore",@"House",@"Jungle/Drum'n'bass",@"Techno",@"Trance",@"Hip-Hop/Rap",@"Alternative Rap",@"Dirty South",@"East Coast Rap",@"Gangsta Rap",@"Hardcore Rap",@"Hip-Hop",@"Latin Rap",@"Old School Rap",@"Rap",@"Underground Rap",@"West Coast Rap",@"World",@"Afro-Beat",@"Afro-Pop",@"Cajun",@"Celtic",@"Celtic Folk",@"Contemporary Celtic",@"Drinking Songs",@"Indian Pop",@"Japanese Pop",@"Klezmer",@"Polka",@"Traditional Celtic",@"Worldbeat",@"Zydeco",@"Caribbean",@"South America",@"Middle East",@"North America",@"Hawaii",@"Australia",@"Japan",@"France",@"Africa",@"Asia",@"Europe",@"South Africa",@"Alternative",@"College Rock",@"Goth Rock",@"Grunge",@"Indie Rock",@"New Wave",@"Punk",@"Rock",@"Adult Alternative",@"American Trad Rock",@"Arena Rock",@"Blues-Rock",@"British Invasion",@"Death Metal/Black Metal",@"Glam Rock",@"Hair Metal",@"Hard Rock",@"Metal",@"Jam Bands",@"Prog-Rock/Art Rock",@"Psychedelic",@"Rock & Roll",@"Rockabilly",@"Roots Rock",@"Singer/Songwriter",@"Southern Rock",@"Surf",@"Tex-Mex",@"Christian & Gospel",@"CCM",@"Christian Metal",@"Christian Pop",@"Christian Rap",@"Christian Rock",@"Classic Christian",@"Contemporary Gospel",@"Gospel",@"Praise & Worship",@"Southern Gospel",@"Traditional Gospel",@"Vocal ",@"Standards",@"Traditional Pop",@"Vocal Jazz",@"Vocal Pop",@"Reggae",@"Dancehall",@"Roots Reggae",@"Dub",@"Ska",@"Easy Listening",@"Bop",@"Lounge",@"Swing",@"J-Pop",@"Enka",@"Anime",@"Kayokyoku",@"Fitness & Workout",@"K-Pop",@"Karaoke",@"Instrumental",@"Brazilian",@"Axé",@"Bossa Nova",@"Choro",@"Forró",@"Frevo",@"MPB",@"Pagode",@"Samba",@"Sertanejo",@"Baile Funk",@"Spoken Word",@"Disney",@"French Pop",@"German Pop",@"German Folk", @"?"];  // ? genre is the equivalent to 'none selected'
}

+ (NSString *)noGenreSelectedGenreString
{
    return @"?";
}

+ (int)noGenreSelectedGenreCode
{
    return 0;
}

+ (BOOL)isValidGenreCode:(int)aGenreCode
{
    return ([GenreConstants genreCodeToString:aGenreCode] != nil) ? YES : NO;
}

#pragma mark - sorting array
+ (void)sortListOfAllGenresAlphabetically:(NSMutableArray **)mutableArray
{
    [*mutableArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end
