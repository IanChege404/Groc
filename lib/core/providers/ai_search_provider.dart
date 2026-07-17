import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/logger.dart';

final aiSearchProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  try {
    if (query.isEmpty) return [];

    // Get all products first
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('products').get();
    final allProducts = snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();

    if (allProducts.isEmpty) return [];

    // Use Anthropic API for semantic search
    final apiKey = const String.fromEnvironment(
      'ANTHROPIC_API_KEY',
      defaultValue: 'sk-ant-placeholder-your-api-key-here',
    );
    const systemPrompt = '''You are a product search assistant for an African grocery e-commerce platform.
Given a user search query and a list of products, rank the products by relevance.
Return ONLY a JSON array of product IDs in order of relevance.
Example: ["product_id_1", "product_id_2", "product_id_3"]
Do not include any other text.''';

    final productList = allProducts
        .map((p) => '- ${p.id}: ${p.name} (${p.category}) - ${p.description}')
        .join('\n');

    final userMessage = 'Search Query: "$query"\n\n'
        'Available Products:\n'
        '$productList\n\n'
        'Return the product IDs ranked by relevance to the search query.';

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 500,
        'system': systemPrompt,
        'messages': [
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      Logger.warning(
        'Anthropic API returned ${response.statusCode}: ${response.body}',
        'aiSearchProvider',
      );
      return _basicSearch(query, allProducts);
    }

    final responseData = jsonDecode(response.body);
    final responseText = (responseData['content'] as List<dynamic>?)
        ?.where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join() ?? '';

    // Parse the response
    final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(responseText);
    if (jsonMatch == null) {
      Logger.warning(
        'No JSON found in AI response: $responseText',
        'aiSearchProvider',
      );
      // Fallback to basic search
      return _basicSearch(query, allProducts);
    }

    final jsonStr = jsonMatch.group(0)!;
    final ids = (jsonStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(','))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final results = <ProductModel>[];
    for (final id in ids) {
      final product = allProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => ProductModel(
          id: '',
          name: '',
          description: '',
          category: '',
          categoryId: '',
          price: 0,
          mainPrice: 0,
          stock: 0,
          image: '',
          images: [],
          rating: 0,
          reviewCount: 0,
          weight: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (product.id.isNotEmpty) results.add(product);
    }

    Logger.info(
      'AI search returned ${results.length} results for query: $query',
      'aiSearchProvider',
    );

    return results;
  } catch (e, stack) {
    Logger.error(
      'Error in AI search: $e\nStack: $stack',
      'aiSearchProvider',
    );
    // Fallback to empty list or basic search
    return [];
  }
});

final searchRecommendationsProvider =
    FutureProvider.family<List<String>, String>((ref, partialQuery) async {
  try {
    if (partialQuery.length < 2) return [];

    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: partialQuery)
        .where('name', isLessThan: partialQuery + 'z')
        .limit(5)
        .get();

    final recommendations = snapshot.docs
        .map((doc) => (doc.data()['name'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return recommendations;
  } catch (e) {
    Logger.error('Error getting search recommendations: $e', 'searchRecommendationsProvider');
    return [];
  }
});

List<ProductModel> _basicSearch(String query, List<ProductModel> products) {
  final lowerQuery = query.toLowerCase();
  final results = products
      .where((p) =>
          p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery))
      .toList();

  // Sort by relevance: exact matches first, then name matches, then description
  results.sort((a, b) {
    final aNameMatch = a.name.toLowerCase().startsWith(lowerQuery);
    final bNameMatch = b.name.toLowerCase().startsWith(lowerQuery);
    if (aNameMatch && !bNameMatch) return -1;
    if (!aNameMatch && bNameMatch) return 1;
    return 0;
  });

  return results;
}
