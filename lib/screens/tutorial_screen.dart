import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/screens/home_screen.dart';
import 'package:hqapp/localization/app_localizations.dart';

class Tutorialpage extends StatefulWidget {
  const Tutorialpage({super.key, required this.user});
  final UserProfile user;

  @override
  State<Tutorialpage> createState() => _TutorialpageState();
}

class _TutorialpageState extends State<Tutorialpage> {
  late UserProfile _user;
  late AppLocalizations _appLoc;
  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  List<String> images = [
    'lib/dependencies/tutorial_images/welcomePage.png',
    'lib/dependencies/tutorial_images/homePage_intro.png',
    'lib/dependencies/tutorial_images/homePage_stats.png',
    'lib/dependencies/tutorial_images/homePage_quiz.png',
    'lib/dependencies/tutorial_images/homePage_notification.png',
    'lib/dependencies/tutorial_images/homePage_leaderboard.png',
    'lib/dependencies/tutorial_images/homePage_achievements.png',
    'lib/dependencies/tutorial_images/homePage_map.png',
    'lib/dependencies/tutorial_images/scanPage.png',
    'lib/dependencies/tutorial_images/profilePage.png',
  ];

  List<String> imagesAr = [
    'lib/dependencies/tutorial_images/welcomePageAr.png',
    'lib/dependencies/tutorial_images/homePage_introAr.png',
    'lib/dependencies/tutorial_images/homePage_statsAr.png',
    'lib/dependencies/tutorial_images/homePage_quizAr.png',
    'lib/dependencies/tutorial_images/homePage_notificationAr.png',
    'lib/dependencies/tutorial_images/homePage_leaderboardAr.png',
    'lib/dependencies/tutorial_images/homePage_achievementsAr.png',
    'lib/dependencies/tutorial_images/homePage_mapAr.png',
    'lib/dependencies/tutorial_images/scanPageAr.png',
    'lib/dependencies/tutorial_images/profilePageAr.png',
  ];

  var lang = 'ar';
  int currentIndex = 0;
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(appBar: AppBar(
      title: Text(
        l.t('tutorial'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: const Color(0xFF6B4423),
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
      body: Column(
        children: [

          SizedBox(height: 6,),

          Align(
            alignment: Alignment(0.8, 0),
            child: OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
                )),
                side: MaterialStateProperty.all(BorderSide(
                  color: Color(0xFF6B4423),width: 2
                ))
              ),
                onPressed: (){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(user: _user)),
                        (route) => false,
                  );
                },
                child: Text(
                  l.t('skip'),
                  style: TextStyle(
                    color: Color(0xFF6B4423),
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                )
            )
          ),

          //SizedBox(height: 6,),

          CarouselSlider(
              carouselController: carouselController,
              items: AppLocalizations.currentLanguageCode == 'en' ?

              images.map((item)=> Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(image: AssetImage(item),)
                ),
              )).toList()
              :
              imagesAr.map((item)=> Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: AssetImage(item),)
                ),
              )).toList(),

              options: CarouselOptions(
                height: 480,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index,reason){
                  setState(() {
                    currentIndex = index;
                  });
                }
              ),

          ),

          SizedBox(height: 6,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((item) => Container(
              height: 12,
              width: 12,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == item.key ? Color(0xFF6B4423) : Colors.grey
              ),
            )).toList(),
          ),

          SizedBox(height: 6,),

          currentIndex == 9 ?
          ElevatedButton(
              style: ElevatedButton.styleFrom(
               backgroundColor: Color(0xFF82522a),
               shadowColor: Colors.transparent,
               fixedSize: const Size(150, 50),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(15),
               ),
             ),
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(user: _user)),
                );
              },
              child: Text(l.t('finish'),style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20
              ),),


          )
          :
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF82522a),
                shadowColor: Colors.transparent,
                fixedSize: const Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: ()=> carouselController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.linear
              ),
              child: Text(l.t('next'),style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20
              ),)
          )

        ],
      )
    );
  }
}


