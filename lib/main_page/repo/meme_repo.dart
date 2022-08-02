import 'package:dio/dio.dart';
import 'package:memo/main_page/main_page_screen.dart';

class MemeRepo {
  static final Dio _dio = Dio();
  static Future<String> getMemeLink(Memes meme) async {
    String currmeme = 'memes';
    switch (meme) {
      case Memes.meirl:
        currmeme = 'me_irl';
        break;
      case Memes.memes:
        currmeme = 'memes';
        break;
      case Memes.dankmemes:
        currmeme = 'dankmemes';
        break;
    }
    final res = await _dio.get('https://meme-api.herokuapp.com/gimme/$currmeme');
    return res.data['url'];
  }
}
