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

  List<String> pickedImage = [];

  @override
  void initState() {
    context.read<ImageViewModel>().getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ImageViewModel imageViewModel = context.watch<ImageViewModel>();
    var size = MediaQuery.of(context).size;

    final double itemHeight = size.height / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: GridView.builder(
                itemCount: imageViewModel.imagesList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  childAspectRatio: (itemWidth / itemHeight),
                ),
                shrinkWrap: true,
                itemBuilder: (context, index){
                  var image = imageViewModel.imagesList[index];

                  return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              pickedImage.contains(image.id) ? pickedImage.remove(image.id) : pickedImage.add(image.id);
                            });
                          },
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CachedNetworkImage(imageUrl: '${image.downloadUrl}.jpg', width: double.maxFinite, height: double.maxFinite, fit: BoxFit.cover,),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(10),
                                      //   child: Container(
                                      //       decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(5),
                                      //           color: Colors.white
                                      //       ),
                                      //       child: Padding(
                                      //           padding: const EdgeInsets.all(8),
                                      //           child: widget.allMaterialsModel.multimediaType == 'audio' ? Icon(Icons.headphones_rounded, size: 15,)
                                      //               : const Icon(Icons.play_arrow_rounded, size: 15,)
                                      //       )
                                      //   ),
                                      // )
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

                  //   GestureDetector(
                  //   onTap: (){
                  //     openUrl(book.downloadLink);
                  //   },
                  //   child: Container(
                  //     height: screenWidth(context, 0.5),
                  //     width: double.maxFinite,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Flexible(fit: FlexFit.tight, child: Image.network(book.cover, width: double.maxFinite, fit: BoxFit.cover,)),
                  //         // Container(
                  //         //   height: 100,
                  //         //   width: double.maxFinite,
                  //         //   child: Image.network(book.cover, height: 50, scale: 1,),
                  //         // ),
                  //         AppText(
                  //           book.title.replaceFirst(book.title[0], book.title[0].toUpperCase()),
                  //           size: ts4,
                  //           weight: FontWeight.bold,
                  //           textOverflow: TextOverflow.ellipsis,
                  //         ),
                  //         AppText(
                  //           book.author.replaceFirst(book.title[0], book.title[0].toUpperCase()),
                  //           size: ts5,
                  //           weight: FontWeight.w400,
                  //           color: Colors.black.withOpacity(0.4),
                  //           textOverflow: TextOverflow.ellipsis,
                  //         ),
                  //         AppText(
                  //           book.pubYear,
                  //           size: ts5,
                  //           weight: FontWeight.w400,
                  //           color: const Color(0xff5F5D5C),
                  //           textOverflow: TextOverflow.ellipsis,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // );
                  // Text(materialViewModel.books[index].title);
                }
            ),
          ),
          pickedImage.isNotEmpty ? ElevatedButton(
              onPressed: () async {
                // var imageString = await imageViewModel.getImagesBytes('${imageViewModel.imagesList[0].downloadUrl}.jpg');
                // print(imageString?.bodyBytes);
                // Isolate.spawn(, message)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => DownloadImage(pickedImageIds: pickedImage))
                );
              },
              child: Text(
                'Download'
              )
          ) : Container()
        ],
      )
    );

  }
}
