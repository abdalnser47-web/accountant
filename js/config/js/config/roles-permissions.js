/**
 * نظام الصلاحيات القائم على الأدوار (RBAC)
 * مع حماية على مستوى العمليات
 */

export const Roles = {
  ADMIN: 'admin',
  USER: 'user',
  VIEWER: 'viewer'
};

export const Permissions = {
  // Inventory
  INVENTORY_READ: 'inventory:read',
  INVENTORY_WRITE: 'inventory:write',
  INVENTORY_DELETE: 'inventory:delete',
  // Accounting
  ACCOUNTING_READ: 'accounting:read',
  ACCOUNTING_WRITE: 'accounting:write',
  ACCOUNTING_DELETE: 'accounting:delete',
  TRANSACTION_CREATE: 'transaction:create',
  TRANSACTION_APPROVE: 'transaction:approve',
  // Reports & Export
  REPORTS_READ: 'reports:read',
  EXPORT_DATA: 'export:data',
  // Settings & Admin
  SETTINGS_WRITE: 'settings:write',
  USER_MANAGE: 'user:manage',
  SYNC_MANAGE: 'sync:manage'
};

export const RolePermissions = {
  [Roles.ADMIN]: Object.values(Permissions),
  [Roles.USER]: [
    Permissions.INVENTORY_READ, Permissions.INVENTORY_WRITE,
    Permissions.ACCOUNTING_READ, Permissions.ACCOUNTING_WRITE,
    Permissions.TRANSACTION_CREATE, Permissions.REPORTS_READ, Permissions.EXPORT_DATA
  ],
  [Roles.VIEWER]: [
    Permissions.INVENTORY_READ, Permissions.ACCOUNTING_READ, Permissions.REPORTS_READ
  ]
};

export class PermissionGuard {
  constructor(user) {
    this.user = user;
    this.role = user?.role || Roles.VIEWER;
    this.permissions = RolePermissions[this.role] || [];
  }

  has(permission) { return this.permissions.includes(permission); }
  hasAny(permissions) { return permissions.some(p => this.permissions.includes(p)); }
  hasAll(permissions) { return permissions.every(p => this.permissions.includes(p)); }

  require(permission, action = 'execute') {
    if (!this.has(permission)) {
      throw new SecurityError(
        `Permission denied: ${permission} required for ${action}`,
        'PERMISSION_DENIED',
        { role: this.role, required: permission }
      );
    }
    return true;
  }
}

export class SecurityError extends Error {
  constructor(message, code, details = {}) {
    super(message);
    this.name = 'SecurityError';
    this.code = code;
    this.details = details;
    this.timestamp = new Date().toISOString();
  }
}