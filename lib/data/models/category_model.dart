import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/category_entity.dart';

/// نموذج التصنيف المالي
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    super.order = 0,
    super.isActive = true,
    super.isSystem = false,
    super.parentId,
    super.subCategories,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  });
  
  /// إنشاء نموذج من كيان
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: entity.type,
      icon: entity.icon,
      color: entity.color,
      order: entity.order,
      isActive: entity.isActive,
      isSystem: entity.isSystem,
      parentId: entity.parentId,
      subCategories: entity.subCategories,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  
  /// إنشاء نموذج من خريطة Firestore
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: CategoryType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => CategoryType.expense,
      ),
      icon: data['icon'],
      color: data['color'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      isSystem: data['isSystem'] ?? false,
      parentId: data['parentId'],
      subCategories: data['subCategories'] != null 
          ? List<String>.from(data['subCategories']) 
          : null,
      metadata: data['metadata'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  /// تحويل النموذج إلى خريطة Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'icon': icon,
      'color': color,
      'order': order,
      'isActive': isActive,
      'isSystem': isSystem,
      'parentId': parentId,
      'subCategories': subCategories,
      'metadata': metadata,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  @override
  CategoryModel copyWith({
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
    return CategoryModel(
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
}
