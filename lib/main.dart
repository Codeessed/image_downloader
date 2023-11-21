import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:image_downloader/view/download-image-page.dart';
import 'package:image_downloader/viewmodel/image-viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


import 'helpers/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpLocator();
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ImageViewModel()),
          ],
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'General Sans',
      ),
      home: const MyHomePage(title: 'Images'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImageStreamListener _imageStreamListener;

  List<String> pickedImage = [];

  @override
  void initState() {
    _imageStreamListener = ImageStreamListener((info, synchronousCall) {
      if (synchronousCall && info != null && info.image != null) {
        // Image has finished loading
        print('Image finished loading!');
      }
    });
    context.read<ImageViewModel>().getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ImageViewModel imageViewModel = context.watch<ImageViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: imageViewModel.loading ? Center(
        child: CircularProgressIndicator(),
      ) : imageViewModel.error.isNotEmpty ?
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              imageViewModel.error,
              textAlign: TextAlign.center,
            ),
            TextButton(
                onPressed: (){
                  imageViewModel.getImages();
                },
                child: Text(
                  'Retry',
                )
            )
          ],
        ),
      ): Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GridView.builder(
                itemCount: imageViewModel.imagesList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index){
                  var image = imageViewModel.imagesList[index];

                  return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: '${image.downloadUrl}.jpg',
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        fit: BoxFit.fitHeight,
                                      imageBuilder: (context, imageProvider) {
                                        return GestureDetector(
                                          onTap: (){
                                            setState(() {
                                              pickedImage.contains(image.id) ? pickedImage.remove(image.id) : pickedImage.add(image.id);
                                            });
                                          },
                                            child: Image(image: imageProvider)
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Image ${image.id}',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        pickedImage.contains(image.id) ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(Icons.check, size: 10,),
                            ),
                          ),
                        ) : Container()
                      ]
                  );
                }
            ),
          ),
          pickedImage.isNotEmpty ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (builder) => DownloadImage(pickedImageIds: pickedImage))
                  );
                },
                child: Text(
                    'Download'
                )
            ),
          ) : Container()
        ],
      )
    );

  }
}
