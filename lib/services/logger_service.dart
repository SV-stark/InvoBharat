import 'package:talker_flutter/talker_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final talkerProvider = Provider<Talker>((final ref) => TalkerFlutter.init());

final class RiverpodTalkerObserver extends ProviderObserver {
  final Talker talker;
  RiverpodTalkerObserver({required this.talker});

  @override
  void didUpdateProvider(
    final ProviderObserverContext context,
    final Object? previousValue,
    final Object? newValue,
  ) {
    talker.log('Provider ${context.provider.name ?? context.provider.runtimeType} updated');
  }

  @override
  void didAddProvider(
    final ProviderObserverContext context,
    final Object? value,
  ) {
    talker.log('Provider ${context.provider.name ?? context.provider.runtimeType} added');
  }

  @override
  void providerDidFail(
    final ProviderObserverContext context,
    final Object error,
    final StackTrace stackTrace,
  ) {
    talker.handle(error, stackTrace, 'Provider ${context.provider.name ?? context.provider.runtimeType} failed');
  }
}
