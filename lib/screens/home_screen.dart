import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/material.dart';

import '../models/imgur_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var mPageCount = 0; // initial page count will be 0
  bool isLoading = false;
  int itemType = ImgurImage.TYPE_PROGRESS;
  List<ImgurImage> imageList = [];
  ScrollController? _controller;

  _scrollListener() {
    if (_controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange) {
      _fetchImages();
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller!.addListener(_scrollListener);
    super.initState();
    _fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imgur Images'),
        actions: const [
          SignOutButton(),
        ],
      ),
      body: _loadView(),
    );
  }

  Widget _loadView() {
    if (imageList.isEmpty ||
        (imageList.length == 1 &&
            imageList[0].itemType == ImgurImage.TYPE_PROGRESS)) {
      return const Center(child: CircularProgressIndicator());
    } else if (imageList.length == 1 &&
        imageList[0].itemType == ImgurImage.TYPE_ERROR) {
      return Center(
        child: RaisedButton(
          onPressed: () {
            _fetchImages();
          },
          child: Text('Try Again'),
        ),
      );
    } else {
      itemType = imageList[imageList.length - 1].itemType;
      return Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              controller: _controller,
              children: List.generate(
                imageList.length,
                (index) {
                  var image = imageList[index];
                  if (image.itemType == ImgurImage.TYPE_ITEM) {
                    return Center(
                        child: FadeInImage.assetNetwork(
                            placeholder: 'assets/imgur_placeholder.jpg',
                            image: image.link));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          _showIndicator(),
        ],
      );
    }
  }

  Widget _showIndicator() {
    if (itemType == ImgurImage.TYPE_PROGRESS) {
      return Container(
        margin: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Container();
    }
  }

  void _fetchImages() async {
    if (!isLoading) {
      mPageCount++;
      isLoading = true;

      if (imageList.length == 1) imageList.removeLast();
      imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_PROGRESS));
      setState(() {});

      await fetchImages().then((imgurImages) {
        imageList.removeLast();
        for (var value in imgurImages.images!) {
          imageList.add(value);
        }
      }).catchError((error) {
        imageList.removeLast();
        if (imageList.isEmpty) {
          imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_ERROR));
        }
        if (mPageCount > 0) {
          mPageCount--;
        }
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }
}
