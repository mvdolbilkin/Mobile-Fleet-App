import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/domain/payment_transaction.dart';

void main() {
  // ─── PaymentTransaction.fromJson ──────────────────────────────────────────

  group('PaymentTransaction.fromJson', () {
    final baseJson = {
      'id': 'tx-1',
      'amount': '1500',
      'contractor': {'id': 'drv-1', 'name': 'Иванов Иван', 'avatar_url': null},
      'created_at': '2024-05-01T10:00:00Z',
      'status': 'completed',
      'transaction_type': 'instant_payout',
    };

    test('парсит полный объект', () {
      final tx = PaymentTransaction.fromJson(baseJson);
      expect(tx.id, 'tx-1');
      expect(tx.amount, '1500');
      expect(tx.contractor.name, 'Иванов Иван');
      expect(tx.status, 'completed');
      expect(tx.transactionType, 'instant_payout');
      expect(tx.createdAt, DateTime.parse('2024-05-01T10:00:00Z'));
    });

    test('contractor null/не объект → Неизвестно', () {
      final tx = PaymentTransaction.fromJson({...baseJson, 'contractor': null});
      expect(tx.contractor.name, 'Неизвестно');
    });

    test('пустой json → не выбрасывает', () {
      expect(() => PaymentTransaction.fromJson({}), returnsNormally);
    });
  });

  // ─── isError / isCompleted / isTopup ─────────────────────────────────────

  group('PaymentTransaction вычисляемые поля', () {
    PaymentTransaction make({String status = 'completed', String type = 'instant_payout'}) =>
        PaymentTransaction(
          id: 'tx',
          amount: '100',
          contractor: PaymentTransactionContractor(id: 'c', name: 'Test'),
          createdAt: DateTime(2024),
          transactionType: type,
          status: status,
        );

    test('isError true при status == error', () {
      expect(make(status: 'error').isError, isTrue);
    });

    test('isError false при status == completed', () {
      expect(make(status: 'completed').isError, isFalse);
    });

    test('isCompleted true при status == completed', () {
      expect(make(status: 'completed').isCompleted, isTrue);
    });

    test('isTopup true при transactionType == topup', () {
      expect(make(type: 'topup').isTopup, isTrue);
    });

    test('isTopup false при instant_payout', () {
      expect(make(type: 'instant_payout').isTopup, isFalse);
    });
  });

  // ─── typeLabel ────────────────────────────────────────────────────────────

  group('PaymentTransaction.typeLabel', () {
    PaymentTransaction makeTx(String type) => PaymentTransaction(
          id: 'tx',
          amount: '0',
          contractor: PaymentTransactionContractor(id: '', name: ''),
          createdAt: DateTime(2024),
          transactionType: type,
        );

    test('instant_payout → Моментальная выплата', () {
      expect(makeTx('instant_payout').typeLabel, 'Моментальная выплата');
    });

    test('topup → Пополнение', () {
      expect(makeTx('topup').typeLabel, 'Пополнение');
    });

    test('statement_payout → Ведомость', () {
      expect(makeTx('statement_payout').typeLabel, 'Ведомость');
    });

    test('single_payout → Выплата', () {
      expect(makeTx('single_payout').typeLabel, 'Выплата');
    });

    test('неизвестный тип → возвращается как есть', () {
      expect(makeTx('batch_payout').typeLabel, 'batch_payout');
    });
  });

  // ─── amountFormatted ──────────────────────────────────────────────────────

  group('PaymentTransaction.amountFormatted', () {
    PaymentTransaction makeTx({required String amount, required String type}) =>
        PaymentTransaction(
          id: 'tx',
          amount: amount,
          contractor: PaymentTransactionContractor(id: '', name: ''),
          createdAt: DateTime(2024),
          transactionType: type,
        );

    test('topup 1500 → +1500,00', () {
      expect(makeTx(amount: '1500', type: 'topup').amountFormatted, '+1500,00');
    });

    test('payout 500.5 → -500,50', () {
      expect(makeTx(amount: '500.5', type: 'instant_payout').amountFormatted, '-500,50');
    });

    test('payout целое → ,00', () {
      expect(makeTx(amount: '200', type: 'single_payout').amountFormatted, '-200,00');
    });
  });

  // ─── PaymentTransactionListResponse ───────────────────────────────────────

  group('PaymentTransactionListResponse.fromJson', () {
    test('парсит список транзакций', () {
      final resp = PaymentTransactionListResponse.fromJson({
        'transactions': [
          {
            'id': 'tx-1',
            'amount': '100',
            'contractor': {'id': 'c1', 'name': 'A'},
            'created_at': '2024-01-01T00:00:00Z',
            'transaction_type': 'topup',
          },
        ],
        'cursor': 'cursor-abc',
      });
      expect(resp.transactions.length, 1);
      expect(resp.transactions.first.id, 'tx-1');
      expect(resp.cursor, 'cursor-abc');
    });

    test('пустой список', () {
      final resp = PaymentTransactionListResponse.fromJson({'transactions': []});
      expect(resp.transactions, isEmpty);
      expect(resp.cursor, isNull);
    });
  });
}
