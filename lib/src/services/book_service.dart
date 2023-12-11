import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebook_reader/src/models/book.dart';

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
}
