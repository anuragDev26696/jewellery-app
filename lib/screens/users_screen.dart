import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/providers/billing_provider.dart';
import 'package:swarn_abhushan/providers/user_provider.dart';
import 'package:swarn_abhushan/utils/bill_item.dart';
import 'package:swarn_abhushan/utils/user_form.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadMore = false;
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(userNotifierProvider.notifier).searchUsers(null, 1, 10);
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _onScroll() async {
    final userState = ref.read(userNotifierProvider);

    if(_isLoadMore || userState.isLastPage) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _isLoadMore = true;
      try {
        await ref.read(userNotifierProvider.notifier).searchUsers(null, userState.page + 1, userState.limit);
      } finally {
        _isLoadMore = false;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: userState.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(userNotifierProvider.notifier).searchUsers(null,1,userState.limit);
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: userState.isLastPage
                    ? userState.users.length
                    : userState.users.length + 1,
                itemBuilder: (context, index) {
                  if (index == userState.users.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = userState.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.mobile),
                    onTap: () => _showBills(user),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        color: Colors.black26,
                        child: Text(user.name.trim()[0], style: const TextStyle(fontSize: 18) ),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(itemBuilder: (context) => _dropdownMenuEntries(context), onSelected: (value) async {
                      if(value == 'edit') {
                        _openBottomSheet(context, user);
                      } else if(value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete this user?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(userNotifierProvider.notifier).deleteUser(user.uuid!);
                        }
                      }
                    },),
                  );
                },
              ),
            ),
    );
  }
  List<PopupMenuItem<String>> _dropdownMenuEntries(BuildContext ctx) {
    return [
      PopupMenuItem(value: 'edit', child: Text('Edit') ),
      PopupMenuItem(value: 'delete', child: Text('Delete') ),
    ];
  }
  
  void _openBottomSheet(BuildContext context, User user) {
    FormGroup? formGroup;
    bool isValidForm = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: UserReactiveForm(
                    user: user,
                    onFormCreated: (form, statusStream) {
                      formGroup = form;
                    },
                    onFormStatusChange: (status) {
                      setSheetState(() => isValidForm = status);
                    },
                    onSaved: (updatedUser) async {
                      await ref.read(userNotifierProvider.notifier).updateUser(updatedUser);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValidForm
                      ? () {
                        if (formGroup != null) {
                          final updatedUser = User(
                            uuid: user.uuid,
                            name: formGroup!.control('name').value,
                            mobile: formGroup!.control('mobile').value,
                            email: formGroup!.control('email').value,
                            address: formGroup!.control('address').value,
                          );
                          Navigator.pop(context);
                          ref.read(userNotifierProvider.notifier).updateUser(updatedUser);
                        }
                      }
                      : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showBills(User user) {
    ref.read(billingNotifierProvider.notifier).fetchBills(null, 1, 20, customerId: user.uuid!);
    final scrollController = ScrollController();

    showModalBottomSheet(context: context, builder: (ctx) => Consumer(builder: (context, ref, _) {
      final billState = ref.watch(billingNotifierProvider);
      scrollController.addListener(() {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
          if (!billState.isLastPage && !billState.isLoading) {
            ref.read(billingServiceProvider).fetchBills(null, billState.page + 1, billState.limit, customerId: user.uuid!);
          }
        }
      });
    
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Bills for ${user.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            ),
            const Divider(height: 1,),
            if (billState.isLoading && billState.bills.isEmpty)
              const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
            else if (billState.bills.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No bills found for this user.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: billState.bills.length + (billState.isLastPage ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index < billState.bills.length) {
                      final bill = billState.bills[index];
                      return BillItem(bill: bill, status: bill.paymentStatus);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      );
    }));
  }
}
