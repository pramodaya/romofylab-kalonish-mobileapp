import 'dart:typed_data';
import 'dart:ui';
import 'package:best_flutter_ui_templates/hotel_booking/calendar_popup_view.dart';
import 'package:best_flutter_ui_templates/hotel_booking/model/hotel_list_data.dart';
import 'package:best_flutter_ui_templates/hotel_booking/item_detail.dart';
import 'package:best_flutter_ui_templates/model/product.dart';
import 'package:best_flutter_ui_templates/model/salon.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../app_theme.dart';
import 'hotel_app_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HotelHomeScreen extends StatefulWidget {
  static const String id = 'salon_home_screen_hotel';
  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  //set image
  String imgUrl;
  final _firestorage = FirebaseStorage.instance;
  final FirebaseStorage storage = FirebaseStorage(
      app: Firestore.instance.app,
      storageBucket: 'gs://kalonish-21fb1.appspot.com');
  Uint8List imageBytes;
  String errorMsg;

  var _salonPariList = <Salon>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _itemFetcher = _ItemFetcher();
  var salonCount = 0;
  var _searchValue = "";

  bool _isLoading = true;
  bool _hasMore = true;

  AnimationController animationController;
  List<HotelListData> hotelList = HotelListData.hotelList;
  final ScrollController _scrollController = ScrollController();
  bool isSearching = false;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 5));

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _isLoading = true;
    _hasMore = true;
    _loadMore();
    getFilterBarUI(salonCount);
    super.initState();
  }

  void _loadMore() {
    _isLoading = true;
    _itemFetcher.fetch().then((List<Salon> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
          _salonPariList = fetchedList;
          salonCount = fetchedList.length;
          getFilterBarUI(fetchedList.length);
        });
      } else {
        setState(() {
          _isLoading = false;
          _salonPariList = fetchedList;
          salonCount = fetchedList.length;
          getFilterBarUI(fetchedList.length);
        });
      }
    });
  }

  void _loadMoreBySearch() {
    _isLoading = true;
    _itemFetcher
        .fetch(searchValue: _searchValue)
        .then((List<Salon> fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
          salonCount = fetchedList.length;
        });
      } else {
        setState(() {
          _isLoading = false;
          _salonPariList = fetchedList;
          salonCount = fetchedList.length;
        });
      }
    });
  }

  // void getImage() async {
  //   //calculate img url
  //   var x = await _firestorage
  //       .ref()
  //       .child('gs://kalonish-21fb1.appspot.com/lara_salon/images1.jpg');

  //   StorageReference ref =
  //       FirebaseStorage.instance.ref().child("lara_salon/images1.jpg");
  //   String url = (await ref.getDownloadURL()).toString();
  //   print(url);

  //   var returnData =
  //       storage.ref().child('lara_salon/images1.jpg').getData(10000);
  // }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HotelAppTheme.buildLightTheme(),
      child: Container(
        color: Colors.white,
        // decoration: new BoxDecoration(
        //   color: Colors.black,
        //   gradient: new LinearGradient(
        //     colors: [
        //       AppTheme.gradientColor1,
        //       AppTheme.gradientColor2,
        //       // AppTheme.gradientColor3,
        //     ],
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //   ),
        // ),
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: <Widget>[
                    AppBar(
                      backgroundColor: AppTheme.appBar,
                      centerTitle: true,
                      title: !isSearching
                          ? Text(
                              'KALONISH',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18.0),
                            )
                          : Container(
                              alignment: Alignment(0.0, 0.0),
                              width: 100.0,
                              child: TextField(
                                autocorrect: true,
                                autofocus: true,
                                cursorColor: Colors.white,
                                onChanged: (value) {
                                  // _filterCountries(value);
                                  setState(() {
                                    _searchValue = value.toUpperCase().trim();
                                  });
                                  _loadMoreBySearch();
                                },
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Search Here",
                                  hintStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),

                      automaticallyImplyLeading: false,
                      // leading: GestureDetector(
                      //   onTap: () {/* Write listener code here */},
                      //   child: Icon(
                      //     Icons.menu, // add custom icons also
                      //   ),
                      // ),
                      actions: <Widget>[
                        isSearching
                            ? IconButton(
                                icon: Icon(Icons.cancel),
                                color: Colors.black,
                                padding: const EdgeInsets.only(top: 10.0),
                                onPressed: () {
                                  setState(() {
                                    this.isSearching = false;
                                    // filteredCountries = countries;
                                    _loadMore();
                                  });
                                },
                                iconSize: 30,
                              )
                            : IconButton(
                                padding: const EdgeInsets.only(top: 10.0),
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    this.isSearching = true;
                                  });
                                },
                                color: Colors.black,
                                iconSize: 30,
                              ),
                      ],
                    ),
                    Expanded(
                      child: NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                return Column(
                                  children: <Widget>[
                                    // Container(
                                    //   height: 10.0,
                                    //   width: MediaQuery.of(context).size.width,
                                    //   color: AppTheme.carouselDotBarColor,
                                    // ),
                                    // getSearchBarUI(),

                                    // getTimeDateUI(),
                                    SizedBox(
                                      height: 130.0,
                                      width: MediaQuery.of(context).size.width,
                                      child: Carousel(
                                        images: [
                                          // NetworkImage(
                                          //     'https://i.pinimg.com/originals/2d/09/d7/2d09d7a9c7a952fde88f107cedf1204a.jpg'),
                                          ExactAssetImage(
                                              "assets/images/11.jpg"),
                                          ExactAssetImage(
                                              "assets/images/12.jpg"),
                                          ExactAssetImage(
                                              "assets/images/12.jpg"),
                                          ExactAssetImage(
                                              "assets/images/14.jpg"),
                                        ],
                                        dotSize: 5.0,
                                        dotSpacing: 18.0,
                                        dotColor: AppTheme.carouselDotColor,
                                        indicatorBgPadding: 5.0,
                                        dotBgColor:
                                            AppTheme.carouselDotBarColor,
                                        // Colors.pink.withOpacity(0.5),
                                        borderRadius: false,

                                        autoplay: true,
                                        defaultImage: ExactAssetImage(
                                            "assets/images/img1.jpg"),
                                      ),
                                    ),
                                    getFilterBarUI(salonCount),
                                  ],
                                );
                              }, childCount: 1),
                            ),
                            // SliverPersistentHeader(
                            //   pinned: true,
                            //   floating: true,
                            //   delegate: ContestTabHeader(
                            //       // getFilterBarUI(salonCount),
                            //       ),
                            // ),
                          ];
                        },
                        body: Container(
                          color: Colors.white,
                          // decoration: new BoxDecoration(
                          //   color: Colors.black,
                          //   gradient: new LinearGradient(
                          //     colors: [
                          //       AppTheme.gradientColor1,
                          //       AppTheme.gradientColor2,
                          //       // AppTheme.gradientColor3,
                          //     ],
                          //     begin: Alignment.topRight,
                          //     end: Alignment.bottomLeft,
                          //   ),
                          // ),
                          // color:
                          //     HotelAppTheme.buildLightTheme().backgroundColor,
                          child: salonCount == 0
                              ? Center(child: Text('No salon found '))
                              : ListView.builder(
                                  // Need to display a loading tile if more items are coming
                                  itemCount: _salonPariList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    // Uncomment the following line to see in real time how ListView.builder works
                                    // print('ListView.builder is building index $index');
                                    // if (index >= _salonPariList.length) {
                                    //   if (!_isLoading) {
                                    //     // _loadMore();
                                    //   }
                                    // return Center(
                                    //   child: SizedBox(
                                    //     child: CircularProgressIndicator(),
                                    //     height: 24,
                                    //     width: 24,
                                    //   ),
                                    // );
                                    // }

                                    if (_salonPariList.length > 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 24,
                                            right: 24,
                                            top: 8,
                                            bottom: 16),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            print('direct to item detail page');
                                            // Navigator.pushNamed(
                                            //     context, ItemDetailPage.id,
                                            //     arguments: {
                                            //       'sdfsdf',
                                            //     });
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ItemDetailPage(
                                                            "WonderWorld",
                                                            _salonPariList[
                                                                index])));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16.0)),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.6),
                                                  offset: const Offset(4, 4),
                                                  blurRadius: 16,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16.0)),
                                              child: Stack(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      AspectRatio(
                                                        aspectRatio: 3,
                                                        child: Image.network(
                                                          _salonPariList[index]
                                                              .salonImg1,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {},
                                                        child: Container(
                                                          color: HotelAppTheme
                                                                  .buildLightTheme()
                                                              .backgroundColor,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16,
                                                                        top: 8,
                                                                        bottom:
                                                                            8),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          _salonPariList[index]
                                                                              .salonName,
                                                                          // overflow:
                                                                          //     TextOverflow.ellipsis,
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize:
                                                                                18,
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Icon(
                                                                              FontAwesomeIcons.mapMarkerAlt,
                                                                              size: 12,
                                                                              color: HotelAppTheme.buildLightTheme().primaryColor,
                                                                            ),
                                                                            // Text(
                                                                            //   _salonPariList[index].streetAddress1,
                                                                            //   style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                                                            // ),

                                                                            Expanded(
                                                                              child: Text(
                                                                                _salonPariList[index].streetAddress1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                                                              ),
                                                                            ),

                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            // Icon(
                                                                            //   FontAwesomeIcons
                                                                            //       .mapMarkerAlt,
                                                                            //   size: 12,
                                                                            //   color: HotelAppTheme
                                                                            //           .buildLightTheme()
                                                                            //       .primaryColor,
                                                                            // ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                _salonPariList[index].streetAddress2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(top: 4),
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              SmoothStarRating(
                                                                                allowHalfRating: true,
                                                                                starCount: 5,
                                                                                rating: 5,
                                                                                size: 20,
                                                                                color: Colors.yellow[700],
                                                                                borderColor: Colors.grey,
                                                                              ),
                                                                              Text(
                                                                                '434 Reviews',
                                                                                style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            16,
                                                                        top: 8),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: <
                                                                      Widget>[
                                                                    // Text(
                                                                    //   '\$200',
                                                                    //   textAlign:
                                                                    //       TextAlign
                                                                    //           .left,
                                                                    //   style: TextStyle(
                                                                    //     fontWeight:
                                                                    //         FontWeight
                                                                    //             .w600,
                                                                    //     fontSize: 22,
                                                                    //   ),
                                                                    // ),
                                                                    Text(
                                                                      'More >>',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.8)),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          Radius.circular(32.0),
                                                        ),
                                                        onTap: () {},
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: HotelAppTheme
                                                                    .buildLightTheme()
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTimeDateUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      // setState(() {
                      //   isDatePopupOpen = true;
                      // });
                      showDemoDialog(context: context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Choose date',
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16,
                                color: Colors.grey.withOpacity(0.8)),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getFilterBarUI(int salonCounts) {
    print('total salon count $salonCounts');
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: HotelAppTheme.buildLightTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 8.0),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$salonCounts salons found',
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      // FocusScope.of(context).requestFocus(FocusNode());
                      // Navigator.push<dynamic>(
                      //   context,
                      //   MaterialPageRoute<dynamic>(
                      //       builder: (BuildContext context) => FiltersScreen(),
                      //       fullscreenDialog: true),
                      // );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.sort, color: Colors.grey),
                            // color: HotelAppTheme.buildLightTheme()
                            //     .primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  void showDemoDialog({BuildContext context}) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            if (startData != null && endData != null) {
              startDate = startData;
              endDate = endData;
            }
          });
        },
        onCancelClick: () {},
      ),
    );
  }
}

class _ItemFetcher {
  final _firestore = Firestore.instance;
  // This async function simulates fetching results from Internet, etc.
  Future<List<Salon>> fetch({String searchValue = ""}) async {
    var salonList = <Salon>[];

    var salonListResponse;
    //store local storage

    if (searchValue == "") {
      salonListResponse = await _firestore.collection('salon').getDocuments();
    } else {
      salonListResponse = await _firestore
          .collection('salon')
          .where('cityCapital', isEqualTo: searchValue)
          .getDocuments();
    }

    if (salonListResponse.documents.length > 0) {
      for (var i = 0; i < salonListResponse.documents.length; i++) {
        Salon salon = Salon();
        List<Product> productList = [];
        var docId = salonListResponse.documents[i].documentID;
        salon.salonDocId = docId;
        salon.description = salonListResponse.documents[i].data['description'];
        salon.hotline = salonListResponse.documents[i].data['hotline'];
        salon.salonName = salonListResponse.documents[i].data['salonName'];
        salon.streetAddress1 =
            salonListResponse.documents[i].data['streetAddress1'];
        salon.streetAddress2 =
            salonListResponse.documents[i].data['streetAddress2'];
        // salon.rating = salonListResponse.documents[i].data['rating'];

        // salon.salonImagesList =
        //     salonListResponse.documents[i].data['salonImages'][0];
        var salonImagesLength =
            salonListResponse.documents[i].data['salonImages'];

        if (salonImagesLength.length > 0) {
          salon.salonImg1 = salonListResponse.documents[i].data['salonImages']
                      [0] !=
                  null
              ? salonListResponse.documents[i].data['salonImages'][0]
              : 'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg2 = salonListResponse.documents[i].data['salonImages']
                      [1] !=
                  null
              ? salonListResponse.documents[i].data['salonImages'][1]
              : 'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg3 = salonListResponse.documents[i].data['salonImages']
                      [2] !=
                  null
              ? salonListResponse.documents[i].data['salonImages'][2]
              : 'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg4 = salonListResponse.documents[i].data['salonImages']
                      [3] !=
                  null
              ? salonListResponse.documents[i].data['salonImages'][3]
              : 'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg5 = salonListResponse.documents[i].data['salonImages']
                      [4] !=
                  null
              ? salonListResponse.documents[i].data['salonImages'][4]
              : 'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
        } else {
          salon.salonImg1 =
              'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg2 =
              'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg3 =
              'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg4 =
              'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
          salon.salonImg5 =
              'https://images.assetsdelivery.com/compings_v2/pavelstasevich/pavelstasevich1902/pavelstasevich190200120.jpg';
        }
        //get salon's first image url
        // var productCount = int.parse(
        //     salonListResponse.documents[i].data['categoryImageCount']);
        try {
          for (int j = 0; j < 5; j++) {
            var intNum = j + 1;
            var imgKey = 'productImage$intNum';

            var productLength =
                salonListResponse.documents[i].data[imgKey].length;
            if (productLength > 0) {
              Product p = Product(
                category: salonListResponse.documents[i].data[imgKey][0],
                name: salonListResponse.documents[i].data[imgKey][1],
                price: salonListResponse.documents[i].data[imgKey][2],
                img: salonListResponse.documents[i].data[imgKey][3],
              );

              productList.add(p);
            }
          }

          salon.productList = productList;
        } catch (ex) {
          print('error');
        }
        salonList.add(salon);
      }
    }
    var k = salonList;
    print(salonList.length);
    return salonList;
  }
}
