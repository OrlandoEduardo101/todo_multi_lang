import 'package:flutter/material.dart';
import 'package:todo_flutter/src/shared/reactive_ui/rx_command.dart';

/// A builder widget that listens to a `Command` and rebuilds its child based on the command's state (loading, error, or data). It provides customizable builders for each state, allowing for flexible UI updates. The `loadingBehavior` parameter determines whether the loading indicator replaces the content or overlays it (useful for pagination scenarios).
/// Example usage:
/// ```dart/// RxCommandBuilder(
///   rxCommand: myCommand,
///   builder: (context, cmd) {
///     if (cmd is RxCommand<String> && cmd.completed) {
///       return Text(cmd.value);
///     }
///     return const SizedBox.shrink();
///   },
///   loadingBuilder: (context, cmd) => const CircularProgressIndicator(),
///   errorBuilder: (context, cmd) => Text('Error: ${cmd.error}'),
///   loadingBehavior: RxLoadingBehavior.overlay, // para mostrar o loading junto com o conteúdo
/// );
enum RxLoadingBehavior {
  replace, // substitui o conteúdo (padrão - carga inicial)
  overlay, // mostra loading junto com o conteúdo (paginação)
}

class RxCommandBuilder extends StatelessWidget {
  const RxCommandBuilder({
    super.key,
    required this.rxCommand,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.loadingBehavior = RxLoadingBehavior.replace, // <- novo
    this.child,
  });

  final Command rxCommand;
  final RxLoadingBehavior loadingBehavior; // <- novo
  final Widget Function(BuildContext, Command) builder;
  final Widget? Function(BuildContext, Command)? loadingBuilder;
  final Widget? Function(BuildContext, Command)? errorBuilder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: rxCommand,
      builder: (context, _) {
        final cmd = rxCommand is RxCommand ? rxCommand as RxCommand : null;

        if (cmd?.error != null) {
          return errorBuilder?.call(context, rxCommand) ?? Text('Error: ${cmd!.error}');
        }

        final isLoading = cmd?.isExecuting ?? false;

        // loading de tela cheia
        if (isLoading && loadingBehavior == RxLoadingBehavior.replace) {
          return loadingBuilder?.call(context, rxCommand) ?? const Center(child: CircularProgressIndicator());
        }

        // loading inline (paginação) — monta a lista + footer
        if (isLoading && loadingBehavior == RxLoadingBehavior.overlay) {
          return Column(
            children: [
              Expanded(child: builder(context, rxCommand)),
              loadingBuilder?.call(context, rxCommand) ??
                  const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            ],
          );
        }

        return builder(context, rxCommand);
      },
    );
  }
}
