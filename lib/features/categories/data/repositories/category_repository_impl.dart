import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getCategories() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    if (maps.isEmpty) {
      await seedDefaultCategories();
      return getCategories();
    }

    return maps.map((e) => CategoryModel.fromMap(e)).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  @override
  Future<void> saveCategory(CategoryEntity category) async {
    final db = await DatabaseHelper.database;
    final model = CategoryModel.fromEntity(category);
    await db.insert(
      'categories',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> seedDefaultCategories() async {
    final db = await DatabaseHelper.database;
    final defaultCategories = [
      const CategoryModel(
        id: 'cat_food',
        name: 'Makanan & Minuman',
        iconName: 'restaurant',
        colorValue: 0xFFF59E0B, // Amber
        type: TransactionType.expense,
        monthlyBudgetLimit: 2500000,
      ),
      const CategoryModel(
        id: 'cat_transport',
        name: 'Transportasi',
        iconName: 'directions_car',
        colorValue: 0xFF3B82F6, // Blue
        type: TransactionType.expense,
        monthlyBudgetLimit: 1000000,
      ),
      const CategoryModel(
        id: 'cat_shopping',
        name: 'Belanja',
        iconName: 'shopping_bag',
        colorValue: 0xFF8B5CF6, // Purple
        type: TransactionType.expense,
        monthlyBudgetLimit: 1500000,
      ),
      const CategoryModel(
        id: 'cat_bills',
        name: 'Tagihan & Utilitas',
        iconName: 'receipt_long',
        colorValue: 0xFFEF4444, // Red
        type: TransactionType.expense,
        monthlyBudgetLimit: 1000000,
      ),
      const CategoryModel(
        id: 'cat_entertainment',
        name: 'Hiburan',
        iconName: 'sports_esports',
        colorValue: 0xFFEC4899, // Pink
        type: TransactionType.expense,
        monthlyBudgetLimit: 800000,
      ),
      const CategoryModel(
        id: 'cat_health',
        name: 'Kesehatan',
        iconName: 'local_hospital',
        colorValue: 0xFF06B6D4, // Cyan
        type: TransactionType.expense,
      ),
      const CategoryModel(
        id: 'cat_salary',
        name: 'Gaji Bulanan',
        iconName: 'account_balance_wallet',
        colorValue: 0xFF10B981, // Emerald
        type: TransactionType.income,
      ),
      const CategoryModel(
        id: 'cat_freelance',
        name: 'Freelance & Bisnis',
        iconName: 'trending_up',
        colorValue: 0xFF14B8A6, // Teal
        type: TransactionType.income,
      ),
    ];

    final batch = db.batch();
    for (final cat in defaultCategories) {
      batch.insert(
        'categories',
        cat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }
}
