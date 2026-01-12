import 'package:fluent_ui/fluent_ui.dart';
import '../../models/invoice.dart';

class InvoiceQuickActions extends StatefulWidget {
  final Invoice invoice;
  final Function(BuildContext, Invoice) onDelete;
  final Function(BuildContext, Invoice) onMarkPaid;
  final Function(BuildContext, Invoice) onRecurring;

  const InvoiceQuickActions({
    super.key,
    required this.invoice,
    required this.onDelete,
    required this.onMarkPaid,
    required this.onRecurring,
  });

  @override
  State<InvoiceQuickActions> createState() => _InvoiceQuickActionsState();
}

class _InvoiceQuickActionsState extends State<InvoiceQuickActions> {
  final _controller = FlyoutController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capture context for callbacks
    final parentContext = context;

    return FlyoutTarget(
      controller: _controller,
      child: IconButton(
        icon: const Icon(FluentIcons.more),
        onPressed: () {
          _controller.showFlyout(
            autoModeConfiguration: FlyoutAutoConfiguration(
              preferredMode: FlyoutPlacementMode.bottomCenter,
            ),
            barrierDismissible: true,
            dismissOnPointerMoveAway: false,
            builder: (context) {
              return MenuFlyout(
                items: [
                  MenuFlyoutItem(
                    text: const Text('Mark Paid'),
                    leading: Icon(FluentIcons.money, color: Colors.green),
                    onPressed: widget.invoice.balanceDue <= 0
                        ? null
                        : () {
                            Flyout.of(context).close();
                            widget.onMarkPaid(parentContext, widget.invoice);
                          },
                  ),
                  MenuFlyoutItem(
                    text: const Text('Make Recurring'),
                    leading: Icon(FluentIcons.repeat_all),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.onRecurring(parentContext, widget.invoice);
                    },
                  ),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    text: const Text('Delete'),
                    leading: Icon(FluentIcons.delete, color: Colors.red),
                    onPressed: () {
                      Flyout.of(context).close();
                      widget.onDelete(parentContext, widget.invoice);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
