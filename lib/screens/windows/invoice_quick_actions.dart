import 'package:fluent_ui/fluent_ui.dart';
import '../../models/invoice.dart';

class InvoiceQuickActions extends StatefulWidget {
  final Invoice invoice;
  final Function(BuildContext, Invoice) onDelete;
  final Function(BuildContext, Invoice) onMarkPaid;
  final Function(BuildContext, Invoice) onRecurring;
  final Function(BuildContext, Invoice) onDuplicate; // New
  final Function(BuildContext, Invoice) onEmail; // New

  const InvoiceQuickActions({
    super.key,
    required this.invoice,
    required this.onDelete,
    required this.onMarkPaid,
    required this.onRecurring,
    required this.onDuplicate, // New
    required this.onEmail, // New
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
            builder: (flyoutContext) {
              return MenuFlyout(
                items: [
                  MenuFlyoutItem(
                    text: const Text('Mark Paid'),
                    leading: Icon(FluentIcons.money, color: Colors.green),
                    onPressed: widget.invoice.balanceDue <= 0
                        ? null
                        : () {
                            Flyout.of(flyoutContext).close();
                            widget.onMarkPaid(context, widget.invoice);
                          },
                  ),
                  MenuFlyoutItem(
                    text: const Text('Make Recurring'),
                    leading: const Icon(FluentIcons.repeat_all),
                    onPressed: () {
                      Flyout.of(flyoutContext).close();
                      widget.onRecurring(context, widget.invoice);
                    },
                  ),
                  MenuFlyoutItem(
                    text: const Text('Duplicate'),
                    leading: const Icon(FluentIcons.copy),
                    onPressed: () {
                      Flyout.of(flyoutContext).close();
                      widget.onDuplicate(context, widget.invoice);
                    },
                  ),
                  MenuFlyoutItem(
                    text: const Text('Email'),
                    leading: const Icon(FluentIcons.mail),
                    onPressed: () {
                      Flyout.of(flyoutContext).close();
                      widget.onEmail(context, widget.invoice);
                    },
                  ),
                  const MenuFlyoutSeparator(),
                  MenuFlyoutItem(
                    text: const Text('Delete'),
                    leading: Icon(FluentIcons.delete, color: Colors.red),
                    onPressed: () {
                      Flyout.of(flyoutContext).close();
                      widget.onDelete(context, widget.invoice);
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
