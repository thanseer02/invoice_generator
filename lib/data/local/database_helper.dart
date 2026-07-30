import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "invoice_generator.db";
  static const _databaseVersion = 6;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Phase 1 SaaS Tables
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        email TEXT,
        displayName TEXT,
        isGuest INTEGER DEFAULT 0,
        role TEXT DEFAULT 'admin'
      )
    ''');

    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        companyId TEXT NOT NULL,
        userId TEXT NOT NULL,
        entity TEXT NOT NULL,
        entityId TEXT NOT NULL,
        action TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        details TEXT
      )
    ''');

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        gstNumber TEXT,
        notes TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Products Table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        taxRate REAL NOT NULL DEFAULT 0.0,
        sku TEXT,
        barcode TEXT,
        discount REAL NOT NULL DEFAULT 0.0,
        unit TEXT,
        imagePath TEXT,
        category TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Invoices Table
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        invoiceNumber TEXT NOT NULL,
        customerId TEXT NOT NULL,
        issueDate TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        subtotal REAL NOT NULL,
        taxAmount REAL NOT NULL,
        discount REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        terms TEXT,
        currency TEXT NOT NULL DEFAULT 'USD',
        isRecurring INTEGER DEFAULT 0,
        recurringFrequency TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    // InvoiceItems Table
    await db.execute('''
      CREATE TABLE invoice_items (
        id TEXT PRIMARY KEY,
        invoiceId TEXT NOT NULL,
        productId TEXT,
        description TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE SET NULL
      )
    ''');

    // Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        invoiceId TEXT NOT NULL,
        amount REAL NOT NULL,
        paymentDate TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        companyId TEXT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        expenseDate TEXT NOT NULL,
        notes TEXT,
        receiptPath TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create Indexes
    await db.execute('CREATE INDEX idx_invoices_customer_id ON invoices (customerId)');
    await db.execute('CREATE INDEX idx_invoice_items_invoice_id ON invoice_items (invoiceId)');
    await db.execute('CREATE INDEX idx_payments_invoice_id ON payments (invoiceId)');

    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) { 
      try { await db.execute('ALTER TABLE customers ADD COLUMN gstNumber TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE customers ADD COLUMN notes TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE customers ADD COLUMN isFavorite INTEGER DEFAULT 0'); } catch(e){}
    }
    if (oldVersion < 3) {
      try { await db.execute('ALTER TABLE products ADD COLUMN sku TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN discount REAL DEFAULT 0.0'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN unit TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN category TEXT'); } catch(e){}
    }
    if (oldVersion < 4) {
      try { await db.execute('ALTER TABLE invoices ADD COLUMN terms TEXT'); } catch(e){}
      try { await db.execute("ALTER TABLE invoices ADD COLUMN currency TEXT NOT NULL DEFAULT 'USD'"); } catch(e){}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS invoice_items (
            id TEXT PRIMARY KEY,
            invoiceId TEXT NOT NULL,
            productId TEXT,
            description TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            unitPrice REAL NOT NULL,
            total REAL NOT NULL,
            FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE,
            FOREIGN KEY (productId) REFERENCES products (id) ON DELETE SET NULL
          )
        ''');
      } catch (e) {}
    }
    if (oldVersion < 5) {
      try { await db.execute('ALTER TABLE invoices ADD COLUMN isRecurring INTEGER DEFAULT 0'); } catch(e){}
      try { await db.execute('ALTER TABLE invoices ADD COLUMN recurringFrequency TEXT'); } catch(e){}
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS companies (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          companyId TEXT,
          email TEXT,
          displayName TEXT,
          isGuest INTEGER DEFAULT 0,
          role TEXT DEFAULT 'admin'
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id TEXT PRIMARY KEY,
          companyId TEXT NOT NULL,
          userId TEXT NOT NULL,
          entity TEXT NOT NULL,
          entityId TEXT NOT NULL,
          action TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          details TEXT
        )
      ''');
      try { await db.execute('ALTER TABLE customers ADD COLUMN companyId TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE products ADD COLUMN companyId TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE invoices ADD COLUMN companyId TEXT'); } catch(e){}
      try { await db.execute('ALTER TABLE expenses ADD COLUMN companyId TEXT'); } catch(e){}
    }
  }

  Future<void> _seedInitialData(Database db) async {
    // Insert default settings
    await db.insert('settings', {'key': 'defaultCurrency', 'value': '\$'});
    await db.insert('settings', {'key': 'defaultTaxRate', 'value': '0.0'});
  }
}
