import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:read_up/src/utils/error_handling.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

import '../models/book.dart';
import '../services/book_service.dart';

var logger = Logger();

class BookUtils {
  static Future<void> downloadAndOpenBook(
      BuildContext context, Book book) async {
    try {
      final String downloadedBookPath =
          await BookService(DioBookDownloader(), FileBookStorage())
              .downloadOrOpenBook(book);

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

class FavoriteBookManager {
  static Future<void> toggleFavorite({
    required Book book,
    required List<int> favoriteBookIds,
    required SharedPreferences prefs,
    required Function(List<int>) onFavoritesUpdated,
  }) async {
    try {
      var tempOutput = List<int>.from(favoriteBookIds);
      tempOutput.contains(book.id)
          ? tempOutput.remove(book.id)
          : tempOutput.add(book.id);
      prefs.setString('books_id', utf8.decode(tempOutput));
      onFavoritesUpdated(tempOutput);
    } on AppException catch (e) {
      logger.e('Erro ao alterar favorito: $e');
    }
  }
}
