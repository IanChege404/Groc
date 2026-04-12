import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../utils/logger.dart';
import 'firestore_service.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  late FirestoreService _firestoreService;

  factory WalletService() {
    return _instance;
  }

  WalletService._internal() {
    _firestoreService = FirestoreService();
  }

  /// Get wallet balance
  Future<WalletModel?> getWalletBalance(String userId) async {
    try {
      return await _firestoreService.getWallet(userId);
    } catch (e) {
      Logger.error(
        'Error getting wallet balance: $e',
        'WalletService.getWalletBalance',
      );
      return null;
    }
  }

  /// Get wallet balance stream (real-time)
  Stream<WalletModel?> getWalletBalanceStream(String userId) {
    return _firestoreService.getWalletStream(userId);
  }

  /// Initialize wallet for new user
  Future<void> initializeWallet(String userId) async {
    try {
      await _firestoreService.initializeWallet(userId);
      Logger.info('Wallet initialized', 'WalletService.initializeWallet');
    } catch (e) {
      Logger.error(
        'Error initializing wallet: $e',
        'WalletService.initializeWallet',
      );
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<TransactionModel>> getTransactionHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      return await _firestoreService.getTransactionHistory(
        userId,
        limit: limit,
      );
    } catch (e) {
      Logger.error(
        'Error getting transaction history: $e',
        'WalletService.getTransactionHistory',
      );
      return [];
    }
  }

  /// Get transaction history stream (real-time)
  Stream<List<TransactionModel>> getTransactionHistoryStream(String userId) {
    return _firestoreService.getTransactionsStream(userId);
  }

  /// Top up wallet
  Future<bool> topUp(String userId, double amount, {String? method}) async {
    try {
      final wallet = await getWalletBalance(userId);
      if (wallet == null) return false;

      final newBalance = wallet.balance + amount;
      await _firestoreService.updateWalletBalance(userId, newBalance);

      // Create transaction record
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'credit',
        amount: amount,
        category: 'topup',
        timestamp: DateTime.now(),
        description: 'Top up wallet via ${method ?? "payment"}',
        reference: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestoreService.addTransaction(userId, transaction);
      Logger.info('Wallet topped up: +$amount', 'WalletService.topUp');
      return true;
    } catch (e) {
      Logger.error('Error topping up wallet: $e', 'WalletService.topUp');
      rethrow;
    }
  }

  /// Withdraw from wallet
  Future<bool> withdraw(
    String userId,
    double amount, {
    String? description,
  }) async {
    try {
      final wallet = await getWalletBalance(userId);
      if (wallet == null || wallet.balance < amount) {
        Logger.error('Insufficient balance', 'WalletService.withdraw');
        return false;
      }

      final newBalance = wallet.balance - amount;
      await _firestoreService.updateWalletBalance(userId, newBalance);

      // Create transaction record
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'debit',
        amount: amount,
        category: 'withdrawal',
        timestamp: DateTime.now(),
        description: description ?? 'Wallet withdrawal',
        reference: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestoreService.addTransaction(userId, transaction);
      Logger.info('Withdrawn from wallet: -$amount', 'WalletService.withdraw');
      return true;
    } catch (e) {
      Logger.error(
        'Error withdrawing from wallet: $e',
        'WalletService.withdraw',
      );
      rethrow;
    }
  }

  /// Transfer between wallets
  Future<bool> transfer(
    String fromUserId,
    String toUserId,
    double amount,
  ) async {
    try {
      final fromWallet = await getWalletBalance(fromUserId);
      if (fromWallet == null || fromWallet.balance < amount) {
        Logger.error(
          'Insufficient balance for transfer',
          'WalletService.transfer',
        );
        return false;
      }

      // Deduct from sender
      final newFromBalance = fromWallet.balance - amount;
      await _firestoreService.updateWalletBalance(fromUserId, newFromBalance);

      // Add to receiver
      final toWallet = await getWalletBalance(toUserId);
      if (toWallet != null) {
        final newToBalance = toWallet.balance + amount;
        await _firestoreService.updateWalletBalance(toUserId, newToBalance);
      }

      // Create transaction records
      final referenceId = DateTime.now().millisecondsSinceEpoch.toString();

      final fromTransaction = TransactionModel(
        id: '${referenceId}_from',
        type: 'debit',
        amount: amount,
        category: 'transfer',
        timestamp: DateTime.now(),
        description: 'Transfer to user $toUserId',
        reference: referenceId,
      );

      final toTransaction = TransactionModel(
        id: '${referenceId}_to',
        type: 'credit',
        amount: amount,
        category: 'transfer',
        timestamp: DateTime.now(),
        description: 'Transfer from user $fromUserId',
        reference: referenceId,
      );

      await _firestoreService.addTransaction(fromUserId, fromTransaction);
      await _firestoreService.addTransaction(toUserId, toTransaction);

      Logger.info(
        'Transfer completed: $amount from $fromUserId to $toUserId',
        'WalletService.transfer',
      );
      return true;
    } catch (e) {
      Logger.error('Error transferring: $e', 'WalletService.transfer');
      rethrow;
    }
  }

  /// Process payment using wallet (for orders)
  Future<bool> processPayment(
    String userId,
    double amount, {
    String? orderId,
    String? description,
  }) async {
    try {
      final wallet = await getWalletBalance(userId);
      if (wallet == null || wallet.balance < amount) {
        Logger.error(
          'Insufficient wallet balance for payment',
          'WalletService.processPayment',
        );
        return false;
      }

      final newBalance = wallet.balance - amount;
      await _firestoreService.updateWalletBalance(userId, newBalance);

      // Create transaction record
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'debit',
        amount: amount,
        category: 'purchase',
        timestamp: DateTime.now(),
        description: description ?? 'Payment via wallet',
        relatedOrderId: orderId,
        reference: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestoreService.addTransaction(userId, transaction);
      Logger.info(
        'Payment processed: -$amount for order $orderId',
        'WalletService.processPayment',
      );
      return true;
    } catch (e) {
      Logger.error(
        'Error processing payment: $e',
        'WalletService.processPayment',
      );
      rethrow;
    }
  }

  /// Add cashback to wallet
  Future<void> addCashback(
    String userId,
    double amount, {
    String? reason,
  }) async {
    try {
      final wallet = await getWalletBalance(userId);
      if (wallet == null) return;

      final newBalance = wallet.balance + amount;
      await _firestoreService.updateWalletBalance(userId, newBalance);

      // Create transaction record
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'credit',
        amount: amount,
        category: 'cashback',
        timestamp: DateTime.now(),
        description: reason ?? 'Cashback reward',
        reference: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _firestoreService.addTransaction(userId, transaction);
      Logger.info('Cashback added: +$amount', 'WalletService.addCashback');
    } catch (e) {
      Logger.error('Error adding cashback: $e', 'WalletService.addCashback');
      rethrow;
    }
  }
}
