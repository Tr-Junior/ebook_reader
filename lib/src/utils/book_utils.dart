import 'package:flutter/material.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/book.dart';
import '../services/book_service.dart';

class BookUtils {
  static Future<void> downloadAndOpenBook(
      BuildContext context, Book book) async {
    try {
      final String downloadedBookPath =
          await BookService().downloadOrOpenBook(book);

      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "ABook",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: true,
      );

      VocsyEpub.open(downloadedBookPath);
    } catch (error) {
      print('Erro ao abrir o livro: $error');
    }
  }
}
