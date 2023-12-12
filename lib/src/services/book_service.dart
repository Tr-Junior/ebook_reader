import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ebook_reader/src/models/book.dart';
import 'package:path_provider/path_provider.dart';

class BookService {
  final Dio _dio = Dio();
  static final BookService _instance = BookService._internal();

  factory BookService() => _instance;

  BookService._internal() {
    _dio.interceptors.add(
        DioCacheInterceptor(options: CacheOptions(store: MemCacheStore())));
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('https://escribo.com/books.json');
      final List<dynamic> data = response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Erro ao carregar os livros: $error');
    }
  }

  Future<String> downloadBook(Book book) async {
    try {
      final response = await _dio.get(book.downloadUrl,
          options: Options(responseType: ResponseType.bytes));
      final List<int> bytes = response.data;
      final String filePath = await saveBookToLocal(book, bytes);
      return filePath;
    } catch (error) {
      throw Exception('Erro ao baixar o livro: $error');
    }
  }

  Future<String> saveBookToLocal(Book book, List<int> bytes) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = "${appDocDir.path}/${book.title}.epub";

    final File file = File(filePath);
    await file.writeAsBytes(bytes);

    return filePath;
  }

  Future<bool> isBookDownloaded(Book book) async {
    final String filePath = await getLocalBookPath(book);
    return File(filePath).existsSync();
  }

  Future<String> downloadOrOpenBook(Book book) async {
    final bool isDownloaded = await isBookDownloaded(book);

    if (isDownloaded) {
      return getLocalBookPath(book);
    } else {
      try {
        final response = await _dio.get(book.downloadUrl,
            options: Options(responseType: ResponseType.bytes));
        final List<int> bytes = response.data;
        final String filePath = await saveBookToLocal(book, bytes);
        return filePath;
      } catch (error) {
        throw Exception('Erro ao baixar o livro: $error');
      }
    }
  }

  Future<String> getLocalBookPath(Book book) async {
    final String fileName = "${book.title}.epub";
    final String directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/$fileName';
  }
}
