import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';
import 'auth_provider.dart';

/// Notifier for managing wallet state
class WalletNotifier extends StateNotifier<AsyncValue<WalletModel?>> {
  final WalletService _service = WalletService();
  final Ref _ref;

  WalletNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<String?>>(authProvider, (_, next) {
      next.whenData((uid) {
        if (uid == null || uid.isEmpty) {
          state = const AsyncValue.data(null);
          return;
        }
        _loadWallet(uid);
      });
    });

    _ref.read(authProvider).whenData((uid) {
      if (uid != null && uid.isNotEmpty) {
        _loadWallet(uid);
      }
    });
  }

  /// Load wallet from service
  Future<void> _loadWallet(String userId) async {
    try {
      state = const AsyncValue.loading();
      final wallet = await _service.getWalletBalance(userId);
      if (wallet == null) {
        await _service.initializeWallet(userId);
        final newWallet = await _service.getWalletBalance(userId);
        state = AsyncValue.data(newWallet);
      } else {
        state = AsyncValue.data(wallet);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Top up wallet
  Future<bool> topUp(String userId, double amount, {String? method}) async {
    try {
      final success = await _service.topUp(userId, amount, method: method);
      if (success) {
        final updated = state.whenData((wallet) => wallet);
        updated.whenData((wallet) {
          if (wallet != null) {
            final newWallet = wallet.copyWith(balance: wallet.balance + amount);
            state = AsyncValue.data(newWallet);
          }
        });
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Withdraw from wallet
  Future<bool> withdraw(
    String userId,
    double amount, {
    String? description,
  }) async {
    try {
      final success = await _service.withdraw(
        userId,
        amount,
        description: description,
      );
      if (success) {
        final updated = state.whenData((wallet) => wallet);
        updated.whenData((wallet) {
          if (wallet != null && wallet.balance >= amount) {
            final newWallet = wallet.copyWith(balance: wallet.balance - amount);
            state = AsyncValue.data(newWallet);
          }
        });
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> transfer(
    String fromUserId,
    String toUserId,
    double amount,
  ) async {
    try {
      final success = await _service.transfer(fromUserId, toUserId, amount);
      if (success) {
        await _loadWallet(fromUserId);
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Process payment using wallet
  Future<bool> processPayment(
    String userId,
    double amount, {
    String? orderId,
    String? description,
  }) async {
    try {
      final success = await _service.processPayment(
        userId,
        amount,
        orderId: orderId,
        description: description,
      );
      if (success) {
        final updated = state.whenData((wallet) => wallet);
        updated.whenData((wallet) {
          if (wallet != null && wallet.balance >= amount) {
            final newWallet = wallet.copyWith(balance: wallet.balance - amount);
            state = AsyncValue.data(newWallet);
          }
        });
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Refresh wallet balance
  Future<void> refresh(String userId) async {
    await _loadWallet(userId);
  }
}

/// Wallet provider using StateNotifierProvider
final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<WalletModel?>>((ref) {
      return WalletNotifier(ref);
    });

/// Real-time wallet balance stream provider
final walletStreamProvider = StreamProvider.autoDispose
    .family<WalletModel?, String>((ref, userId) {
      return WalletService().getWalletBalanceStream(userId);
    });

/// Transaction history provider
final transactionsProvider = FutureProvider.autoDispose
    .family<List<TransactionModel>, String>((ref, userId) async {
      return WalletService().getTransactionHistory(userId);
    });

/// Real-time transaction history stream provider
final transactionsStreamProvider = StreamProvider.autoDispose
    .family<List<TransactionModel>, String>((ref, userId) {
      return WalletService().getTransactionHistoryStream(userId);
    });

/// Transactions with limit provider
final transactionsLimitProvider = FutureProvider.autoDispose
    .family<List<TransactionModel>, (String, int)>((ref, params) async {
      return WalletService().getTransactionHistory(params.$1, limit: params.$2);
    });
