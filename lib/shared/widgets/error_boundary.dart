import 'package:flutter/material.dart';

/// 错误边界 - 捕获渲染错误
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _error = null;
    _stackTrace = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _defaultErrorBuilder(_error!, _stackTrace);
    }

    return ErrorWidget.builder = (details) {
      return _defaultErrorBuilder(details.exception, details.stack);
    };

    return widget.child;
  }

  Widget _defaultErrorBuilder(Object error, StackTrace? stackTrace) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                '渲染错误',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              if (stackTrace != null)
                Text(
                  stackTrace.toString(),
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
