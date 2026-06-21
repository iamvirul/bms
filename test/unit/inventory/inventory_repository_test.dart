import 'package:bms/core/errors/app_exception.dart';
import 'package:bms/data/database/app_database.dart';
import 'package:bms/data/repositories/inventory_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

StockLevel _stock({double qty = 50}) => StockLevel(
      productId: 'prod-1',
      qty: qty,
      updatedAt: DateTime(2024),
    );

void main() {
  late MockInventoryDao inventoryDao;
  late MockAuditLogDao auditLogDao;
  late InventoryRepository repo;

  setUpAll(() {
    registerFallbackValue(const StockCompanion());
    registerFallbackValue(const ProductsCompanion());
    // StockMovementsCompanion.insert requires all non-default columns.
    // Using the default companion (all absent) as fallback is enough for any().
    registerFallbackValue(const StockMovementsCompanion());
  });

  setUp(() {
    inventoryDao = MockInventoryDao();
    auditLogDao = MockAuditLogDao();
    repo = InventoryRepository(inventoryDao: inventoryDao, auditLogDao: auditLogDao);
  });

  // Helper to stub auditLogDao.log with newValue matcher.
  void _stubAuditLog() {
    when(() => auditLogDao.log(
          id: any(named: 'id'),
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          userId: any(named: 'userId'),
          userName: any(named: 'userName'),
          newValue: any(named: 'newValue'),
        )).thenAnswer((_) async {});
  }

  group('InventoryRepository', () {
    group('adjustStock', () {
      test('throws BusinessRuleException when resulting qty would go negative', () async {
        when(() => inventoryDao.getStock('prod-1')).thenAnswer((_) async => _stock(qty: 10));

        await expectLater(
          () => repo.adjustStock(
            productId: 'prod-1',
            delta: -20,
            reason: 'sale',
            userId: 'u1',
            userName: 'Admin',
          ),
          throwsA(isA<BusinessRuleException>()),
        );

        verifyNever(() => inventoryDao.upsertStock(any()));
        verifyNever(() => inventoryDao.recordMovement(any()));
      });

      test('records an "out" movement for negative delta', () async {
        when(() => inventoryDao.getStock('prod-1')).thenAnswer((_) async => _stock(qty: 50));
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        when(() => inventoryDao.recordMovement(any())).thenAnswer((_) async {});

        await repo.adjustStock(
          productId: 'prod-1',
          delta: -5,
          reason: 'sale',
          userId: 'u1',
          userName: 'Admin',
        );

        final captured = verify(() => inventoryDao.recordMovement(captureAny())).captured;
        final companion = captured.first as StockMovementsCompanion;
        expect(companion.type.value, 'out');
        expect(companion.qty.value, 5.0);
      });

      test('records an "in" movement for positive delta', () async {
        when(() => inventoryDao.getStock('prod-1')).thenAnswer((_) async => _stock(qty: 50));
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        when(() => inventoryDao.recordMovement(any())).thenAnswer((_) async {});

        await repo.adjustStock(
          productId: 'prod-1',
          delta: 10,
          reason: 'restock',
          userId: 'u1',
          userName: 'Admin',
        );

        final captured = verify(() => inventoryDao.recordMovement(captureAny())).captured;
        final companion = captured.first as StockMovementsCompanion;
        expect(companion.type.value, 'in');
        expect(companion.qty.value, 10.0);
      });

      test('treats no existing stock row as zero qty', () async {
        when(() => inventoryDao.getStock('prod-1')).thenAnswer((_) async => null);
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        when(() => inventoryDao.recordMovement(any())).thenAnswer((_) async {});

        await repo.adjustStock(
          productId: 'prod-1',
          delta: 20,
          reason: 'initial',
          userId: 'u1',
          userName: 'Admin',
        );

        final captured = verify(() => inventoryDao.upsertStock(captureAny())).captured;
        final companion = captured.first as StockCompanion;
        expect(companion.qty.value, 20.0);
      });

      test('respects custom movementType when provided', () async {
        when(() => inventoryDao.getStock('prod-1')).thenAnswer((_) async => _stock());
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        when(() => inventoryDao.recordMovement(any())).thenAnswer((_) async {});

        await repo.adjustStock(
          productId: 'prod-1',
          delta: 5,
          reason: 'customer return',
          userId: 'u1',
          userName: 'Admin',
          movementType: 'return_in',
        );

        final captured = verify(() => inventoryDao.recordMovement(captureAny())).captured;
        final companion = captured.first as StockMovementsCompanion;
        expect(companion.type.value, 'return_in');
      });
    });

    group('createProduct', () {
      test('writes audit log with entityType "product" and action "create"', () async {
        when(() => inventoryDao.insertProduct(any())).thenAnswer((_) async => 'prod-new');
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        _stubAuditLog();

        await repo.createProduct(
          name: 'Widget',
          unitType: 'pcs',
          costPrice: 50.0,
          sellPrice: 80.0,
          userId: 'u1',
          userName: 'Admin',
        );

        final captured = verify(() => auditLogDao.log(
              id: any(named: 'id'),
              entityType: captureAny(named: 'entityType'),
              entityId: any(named: 'entityId'),
              action: captureAny(named: 'action'),
              userId: any(named: 'userId'),
              userName: any(named: 'userName'),
              newValue: any(named: 'newValue'),
            )).captured;

        expect(captured[0], 'product');
        expect(captured[1], 'create');
      });

      test('returns a non-empty product id', () async {
        when(() => inventoryDao.insertProduct(any())).thenAnswer((_) async => 'prod-new');
        when(() => inventoryDao.upsertStock(any())).thenAnswer((_) async {});
        _stubAuditLog();

        final id = await repo.createProduct(
          name: 'Widget',
          unitType: 'pcs',
          costPrice: 50.0,
          sellPrice: 80.0,
          userId: 'u1',
          userName: 'Admin',
        );

        expect(id, isNotEmpty);
      });
    });
  });
}
