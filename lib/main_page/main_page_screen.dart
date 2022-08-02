import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:memo/main_page/repo/meme_repo.dart';
import 'package:memo/main_page/widgets/meme_checkbox.dart';
import 'package:memo/pro_page/pro_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const date = 'DATE';

enum Memes {
  meirl,
  memes,
  dankmemes,
}

const _productIds = {'weekly1'};

class MainPage extends StatefulWidget {
  final bool isPro;
  const MainPage({
    Key? key,
    required this.isPro,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Memes currMeme = Memes.memes;
  late bool isPremium = widget.isPro;
  String currUrl = 'https://i.redd.it/tbzljvy938591.jpg';
  late StreamSubscription<dynamic> _subscription;
  List<ProductDetails> _products = [];
  InAppPurchase inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    final Stream purchaseUpdated = inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {});
    super.initState();
    initStoreInfo();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: const Text('Error purchasing subscription'),
              action: SnackBarAction(
                label: 'Close',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            isPremium = true;
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            date,
            (DateTime.now().add(
              const Duration(days: 7),
            )).toIso8601String(),
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  initStoreInfo() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {}
    ProductDetailsResponse productDetailResponse = await inAppPurchase.queryProductDetails(
      _productIds,
    );
    if (productDetailResponse.error == null) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: SvgPicture.asset(
                  'assets/memo.svg',
                ),
              ),
              if (isPremium)
                CupertinoButton(
                  onPressed: () async {
                    await Share.shareWithResult(currUrl, subject: 'Hey checkout this funny meme: ');
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 22),
                    child: Icon(
                      Icons.share,
                      color: Colors.pink,
                    ),
                  ),
                )
              else
                CupertinoButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProPage(
                          productDetails: _products[0],
                          onPurchase: () async {
                            final res = await inAppPurchase.buyNonConsumable(
                              purchaseParam: PurchaseParam(
                                productDetails: _products[0],
                              ),
                            );
                            if (res) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 22),
                    child: SvgPicture.asset(
                      'assets/pro.svg',
                      color: Colors.pink,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
            future: MemeRepo.getMemeLink(currMeme),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                currUrl = snapshot.data!;
                return Image.network(snapshot.data!);
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4475ED),
        child: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {});
        },
      ),
      persistentFooterButtons: isPremium
          ? [
              MemeCheckBox(
                title: const Text('MeIRL'),
                curr: currMeme,
                value: Memes.meirl,
                onChanged: (v) {
                  setState(() {
                    if (v!) {
                      currMeme = Memes.meirl;
                    }
                  });
                },
              ),
              MemeCheckBox(
                title: const Text('Memes'),
                curr: currMeme,
                value: Memes.memes,
                onChanged: (v) {
                  setState(() {
                    if (v!) {
                      currMeme = Memes.memes;
                    }
                  });
                },
              ),
              MemeCheckBox(
                title: const Text('Dankmemes'),
                curr: currMeme,
                value: Memes.dankmemes,
                onChanged: (v) {
                  setState(() {
                    if (v!) {
                      currMeme = Memes.dankmemes;
                    }
                  });
                },
              ),
            ]
          : null,
    );
  }
}
