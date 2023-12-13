import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_up/src/models/book.dart';

abstract class BookDownloader {
  Future<String> downloadBook(Book book);
}

class DioBookDownloader implements BookDownloader {
  final Dio _dio = Dio();

  @override
  Future<String> downloadBook(Book book) async {
    final response = await _dio.get(book.downloadUrl,
        options: Options(responseType: ResponseType.bytes));
    final bytes = response.data;
    return saveBookToLocal(book, bytes);
  }

  Future<String> saveBookToLocal(Book book, List<int> bytes) async {
    final fileName = "${book.title}.epub";
    final directory = (await getApplicationDocumentsDirectory()).path;
    final filePath = '$directory/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}

abstract class BookStorage {
  Future<bool> isBookDownloaded(String filePath);
  Future<String> getLocalBookPath(Book book);
}

class FileBookStorage implements BookStorage {
  @override
  Future<bool> isBookDownloaded(String filePath) async {
    return File(filePath).existsSync();
  }

  @override
  Future<String> getLocalBookPath(Book book) async {
    final fileName = "${book.title}.epub";
    final directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/$fileName';
  }
}

class BookService {
  final BookDownloader _bookDownloader;
  final BookStorage _bookStorage;

  BookService(this._bookDownloader, this._bookStorage) {
    _setupInterceptor();
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await Dio().get('https://escribo.com/books.json');
      return (response.data as List)
          .map((json) => Book.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Erro ao carregar os livros: $error');
    }
  }

  Future<void> _setupInterceptor() async {
    Dio().interceptors.add(
          DioCacheInterceptor(
            options: CacheOptions(
              store: MemCacheStore(),
              policy: CachePolicy.request,
              hitCacheOnErrorExcept: [500],
            ),
          ),
        );
  }

  Future<String> downloadOrOpenBook(Book book) async {
    final filePath = await _bookStorage.getLocalBookPath(book);

    if (await _bookStorage.isBookDownloaded(filePath)) {
      return filePath;
    }

    try {
      return await _bookDownloader.downloadBook(book);
    } catch (error) {
      throw Exception('Erro ao baixar o livro: $error');
    }
  }
}
