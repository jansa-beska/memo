import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memo/main_page/main_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          children: const [
            OnboardingElement(
              asset: 'assets/1.png',
              title: 'To meme or not to meme? That is the question',
            ),
            OnboardingElement(
              asset: 'assets/2.png',
              title: 'Here’s to all the memes that make us smile',
            ),
            OnboardingElement(
              asset: 'assets/3.png',
              title: 'What know memes and how to use them',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 295,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xFF4475ED),
            elevation: 0,
          ),
          onPressed: () async {
            if (pageController.page! >= 2) {
              if (Platform.isIOS) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MainPage(isPro: true),
                  ),
                );
              } else {
                final shared = await SharedPreferences.getInstance();
                final res = shared.getString(date);
                if (res != null) {
                  final a = DateTime.now().compareTo(DateTime.parse(res));
                  if (a < 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MainPage(isPro: true),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MainPage(isPro: false),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MainPage(isPro: false),
                    ),
                  );
                }
              }
            } else {
              pageController.nextPage(
                duration: const Duration(
                  milliseconds: 200,
                ),
                curve: Curves.easeIn,
              );
            }
          },
          child: const Text(
            'NEXT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingElement extends StatelessWidget {
  final String asset;
  final String title;
  const OnboardingElement({
    Key? key,
    required this.asset,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(asset),
        const SizedBox(
          height: 20,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
