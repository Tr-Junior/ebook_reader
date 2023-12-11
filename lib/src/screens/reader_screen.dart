import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:ebook_reader/src/models/book.dart';

class ReaderScreen extends StatelessWidget {
  final Book book;

  const ReaderScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reader Screen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(book.coverUrl, height: 200),
            const SizedBox(height: 16),
            Text(book.author),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                VocsyEpub.setConfig(
                  themeColor: Theme.of(context).primaryColor,
                  identifier: "ABook",
                  scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                  allowSharing: true,
                  enableTts: true,
                  nightMode: true,
                );

                VocsyEpub.open(
                  book.downloadUrl,
                  lastLocation: EpubLocator.fromJson({
                    "bookId": "2239",
                    "href": "/OEBPS/ch06.xhtml",
                    "created": 1539934158390,
                    "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"},
                  }),
                );
              },
              child: Text('Abrir Livro'),
            ),
          ],
        ),
      ),
    );
  }
}
