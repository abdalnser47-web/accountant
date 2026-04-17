import 'package:equatable/equatable.dart';

/// نوع التصنيف
enum CategoryType {
  income,   // دخل
  expense,  // مصروف
}

/// كيان التصنيف المالي
class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final int order;
  final bool isActive;
  final bool isSystem;          // تصنيف نظام (لا يمكن حذفه)
  final String? parentId;       // للتصنيفات الفرعية
  final List<String>? subCategories;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.order = 0,
    this.isActive = true,
    this.isSystem = false,
    this.parentId,
    this.subCategories,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });
  
  /// إنشاء نسخة معدلة من الكيان
  CategoryEntity copyWith({
    String? id,
    String? userId,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    int? order,
    bool? isActive,
    bool? isSystem,
    String? parentId,
    List<String>? subCategories,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      isSystem: isSystem ?? this.isSystem,
      parentId: parentId ?? this.parentId,
      subCategories: subCategories ?? this.subCategories,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// التحقق مما إذا كان التصنيف للدخل
  bool get isIncome => type == CategoryType.income;
  
  /// التحقق مما إذا كان التصنيف للمصروفات
  bool get isExpense => type == CategoryType.expense;
  
  /// التحقق مما إذا كان تصنيفًا رئيسيًا
  bool get isParent => parentId == null;
  
  /// التحقق مما إذا كان تصنيفًا فرعيًا
  bool get isSubCategory => parentId != null;
  
  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        parentId,
        isActive,
      ];
}

/// تصنيفات افتراضية للنظام
class DefaultCategories {
  /// تصنيفات المصروفات الافتراضية
  static const List<Map<String, dynamic>> expenseCategories = [
    {'name': 'طعام وطعام', 'icon': 'restaurant', 'color': '#FF7043'},
    {'name': 'نقل ومواصلات', 'icon': 'directions_car', 'color': '#42A5F5'},
    {'name': 'تسوق', 'icon': 'shopping_bag', 'color': '#AB47BC'},
    {'name': 'ترفيه', 'icon': 'movie', 'color': '#EC407A'},
    {'name': 'فواتير وخدمات', 'icon': 'receipt', 'color': '#26A69A'},
    {'name': 'صحة وعلاج', 'icon': 'medical_services', 'color': '#66BB6A'},
    {'name': 'تعليم', 'icon': 'school', 'color': '#8D6E63'},
    {'name': 'رواتب', 'icon': 'payments', 'color': '#4CAF50'},
    {'name': 'إيجار', 'icon': 'home', 'color': '#FFA726'},
    {'name': 'أخرى', 'icon': 'more_horiz', 'color': '#9E9E9E'},
  ];
  
  /// تصنيفات الدخل الافتراضية
  static const List<Map<String, dynamic>> incomeCategories = [
    {'name': 'راتب', 'icon': 'account_balance_wallet', 'color': '#4CAF50'},
    {'name': 'مكافأة', 'icon': 'card_giftcard', 'color': '#66BB6A'},
    {'name': 'استثمار', 'icon': 'trending_up', 'color': '#FFCA28'},
    {'name': 'هدية', 'icon': 'redeem', 'color': '#EF5350'},
    {'name': 'أخرى', 'icon': 'more_horiz', 'color': '#9E9E9E'},
  ];
}
