import 'dart:convert';
import 'dart:io';

import 'package:ReadUP/src/models/book.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';

class BookService {
  final Dio _dio = Dio();
  static final BookService _instance = BookService._internal();

  factory BookService() => _instance;

  BookService._internal() {
    _dio.interceptors.add(
      DioCacheInterceptor(options: CacheOptions(store: MemCacheStore())),
    );
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('https://escribo.com/books.json');
      return (response.data as List)
          .map((json) => Book.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Erro ao carregar os livros: $error');
    }
  }

  Future<String> downloadOrOpenBook(Book book) async {
    final String filePath = await getLocalBookPath(book);

    if (await isBookDownloaded(filePath)) {
      return filePath;
    }

    try {
      final List<int> bytes = await _downloadBookBytes(book.downloadUrl);
      return saveBookToLocal(book, bytes);
    } catch (error) {
      throw Exception('Erro ao baixar o livro: $error');
    }
  }

  Future<List<int>> _downloadBookBytes(String url) async {
    final response =
        await _dio.get(url, options: Options(responseType: ResponseType.bytes));
    return response.data;
  }

  Future<String> saveBookToLocal(Book book, List<int> bytes) async {
    final String filePath = await getLocalBookPath(book);
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<bool> isBookDownloaded(String filePath) async {
    return File(filePath).existsSync();
  }

  Future<String> getLocalBookPath(Book book) async {
    final fileName = "${book.title}.epub";
    final directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/$fileName';
  }
}
