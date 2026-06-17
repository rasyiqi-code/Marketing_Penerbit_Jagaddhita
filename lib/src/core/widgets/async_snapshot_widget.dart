import 'package:flutter/material.dart';

/// A wrapper widget to reduce boilerplate code for FutureBuilder or StreamBuilder snapshots.
class AsyncSnapshotWidget<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool Function(T data)? isEmpty;
  final Widget? emptyWidget;

  const AsyncSnapshotWidget({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.isEmpty,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(context, snapshot.error!);
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Terjadi kesalahan: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
      return loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    final data = snapshot.data as T;

    if (isEmpty != null && isEmpty!(data)) {
      return emptyWidget ?? const Center(child: Text('Tidak ada data'));
    }

    return builder(context, data);
  }
}
