import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import 'admin_controller.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsyncValue = ref.watch(adminParentsProvider);
    final adminControllerState = ref.watch(adminControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: adminControllerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : parentsAsyncValue.when(
              data: (parents) {
                if (parents.isEmpty) {
                  return const Center(child: Text("No parents found."));
                }
                return RefreshIndicator(
                   onRefresh: () async => ref.refresh(adminParentsProvider),
                  child: ListView.builder(
                    itemCount: parents.length,
                    itemBuilder: (context, index) {
                      final parent = parents[index];
                      return _ParentListItem(parent: parent);
                    },
                  ),
                );
              },
              error: (err, stack) => Center(child: Text("Error: $err")),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

class _ParentListItem extends ConsumerWidget {
  final UserProfile parent;

  const _ParentListItem({required this.parent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kidsAsyncValue = ref.watch(adminKidsProvider(parent.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(parent.fullName ?? "Unknown Parent"),
        subtitle: Text("${parent.email ?? 'No Email'} \nBalance: \$${parent.balance.toStringAsFixed(2)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => _showAddMoneyDialog(context, ref, parent),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          kidsAsyncValue.when(
            data: (kids) {
              if (kids.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No kids linked."),
                );
              }
              return Column(
                children: kids.map((kid) => _KidListItem(kid: kid, parentId: parent.id)).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Error fetching kids: $err"),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Money to ${user.fullName}"),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Amount", prefixText: "\$"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  ref.read(adminControllerProvider.notifier).addMoney(user.id, amount).then((_) {
                     // Invalidate happens in controller
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

class _KidListItem extends ConsumerWidget {
  final UserProfile kid;
  final String parentId;

  const _KidListItem({required this.kid, required this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.child_care),
      title: Text(kid.fullName ?? "Unknown Kid"),
      subtitle: Text("Balance: \$${kid.balance.toStringAsFixed(2)}"),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.blue),
        onPressed: () => _showAddMoneyDialog(context, ref, kid),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Money to ${user.fullName}"),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Amount", prefixText: "\$"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  await ref.read(adminControllerProvider.notifier).addMoney(user.id, amount);
                  // Refresh this specific kid list
                  ref.invalidate(adminKidsProvider(parentId));
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
