import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ebook_reader/src/models/book.dart';
import 'package:path_provider/path_provider.dart';

class BookService {
  Future<List<Book>> getBooks() async {
    final response =
        await http.get(Uri.parse('https://escribo.com/books.json'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar os livros');
    }
  }

  Future<String> downloadBook(Book book) async {
    final response = await http.get(Uri.parse(book.downloadUrl));

    if (response.statusCode == 200) {
      final List<int> bytes = response.bodyBytes;

      final String filePath = await saveBookToLocal(book, bytes);

      return filePath;
    } else {
      throw Exception('Erro ao baixar o livro');
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
      final response = await http.get(Uri.parse(book.downloadUrl));

      if (response.statusCode == 200) {
        final List<int> bytes = response.bodyBytes;

        final String filePath = await saveBookToLocal(book, bytes);

        return filePath;
      } else {
        throw Exception('Erro ao baixar o livro');
      }
    }
  }

  Future<String> getLocalBookPath(Book book) async {
    final String fileName = "${book.title}.epub";
    final String directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/$fileName';
  }
}
