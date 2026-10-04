import 'package:flutter/material.dart';
import '../../models/category_model.dart';

/// Daftar kategori bawaan yang dipakai di seluruh aplikasi.
///
/// - `id` berupa string unik (mis. 'cat_coffee').
/// - `name` adalah label yang ditampilkan.
/// - `icon` dan `color` dipetakan ke nilai Material Design.
///
/// Akses melalui `DefaultCategories.list` atau `DefaultCategories.byId(id)`.
class DefaultCategories {
  // Daftar kategori pengeluaran (expense).
  static const List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'cat_coffee',
      name: 'Coffee',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF8E4C3B), // dark peach
    ),
    CategoryModel(
      id: 'cat_food',
      name: 'Food',
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFD97706), // orange
    ),
    CategoryModel(
      id: 'cat_groceries',
      name: 'Groceries',
      icon: Icons.shopping_cart_outlined,
      color: Color(0xFF006C49), // primary green
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Transport',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF6366F1), // indigo
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFBD382B), // expense red
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF6B21A8), // purple
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFF1E40AF), // deep blue
    ),
  ];

  // Daftar kategori pemasukan (income).
  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'cat_salary',
      name: 'Salary',
      icon: Icons.attach_money_rounded,
      color: Color(0xFF006C49), // primary green
    ),
    CategoryModel(
      id: 'cat_freelance',
      name: 'Freelance',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF16A34A), // emerald
    ),
    CategoryModel(
      id: 'cat_investment',
      name: 'Investment',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF7C3AED), // violet
    ),
    CategoryModel(
      id: 'cat_gift',
      name: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFEAB308), // amber
    ),
  ];

  /// Semua kategori (expense + income) dalam satu list.
  static List<CategoryModel> get all => [...expenseCategories, ...incomeCategories];

  /// Cari kategori berdasarkan `id`. Mengembalikan `null` bila tidak ditemukan.
  static CategoryModel? byId(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
