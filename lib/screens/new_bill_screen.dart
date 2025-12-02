import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/providers/user_provider.dart';
import 'package:swarn_abhushan/screens/templates_screen.dart';
import 'package:swarn_abhushan/services/user_service.dart';
import 'package:swarn_abhushan/utils/constant.dart';
import 'package:swarn_abhushan/utils/item_form_dialog.dart';
import '../models/item.dart';
import '../screens/payment_screen.dart';
import '../providers/templates_provider.dart'; // 999881230647 aws account number

class NewBillScreen extends ConsumerStatefulWidget {
  const NewBillScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  late UserService userService;
  late VoidCallback _onUserFieldChanged;
  User? _selectedUser;
  bool _isAddingNewUser = false;
  final List<Item> _items = [];

  void _addItemDialog({Item? prefill}) {
    showDialog<Item>(
      context: context,
      builder: (_) => ItemFormDialog(
        prefill: prefill,
        title: prefill == null ? 'Add Item' : 'Add From Template',
        confirmText: prefill == null ? 'Add' : 'Save',
        onSubmit: (result) {
          if (prefill != null) {
            final index = _items.indexWhere((it) => it.uuid == prefill.uuid);
            if (index != -1) {
              setState(() => _items[index] = result);
            } else {
              setState(() => _items.add(result));
            }
            Navigator.pop(context);
            return;
          }
          setState(() => _items.add(result));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _editItemDialog(int index) {
    final current = _items[index];
    showDialog(
      context: context,
      builder: (_) => ItemFormDialog(
        prefill: current,
        title: 'Edit Item',
        confirmText: 'Save',
        keepPrefillId: true,
        onSubmit: (item) {
          setState(() => _items[index] = item);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userService = ref.read(userServiceProvider);
    _onUserFieldChanged = () => setState(() {});
    _customerNameCtrl.addListener(_onUserFieldChanged);
    _customerPhoneCtrl.addListener(_onUserFieldChanged);
    Future.microtask(() async {
      await userService.fetchUsers(null, 1, 50);
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.removeListener(_onUserFieldChanged);
    _customerPhoneCtrl.removeListener(_onUserFieldChanged);
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templateNotifierProvider).items;
    CalculateTax calc = CalculateTax(_items, 0, 0);
    final gold = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('New Bill')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
          child: Column(
            spacing: 12.0,
            children: [
              if (_isAddingNewUser)
                ...[
                  TextFormField(
                    controller: _customerNameCtrl,
                    decoration: const InputDecoration(labelText: 'Customer Name'),
                  ),
                  TextFormField(
                    controller: _customerPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      TextButton(onPressed: () {
                        setState(() {
                          _isAddingNewUser = false;
                          _customerNameCtrl.clear();
                          _customerPhoneCtrl.clear();
                        });
                      }, child: const Text('Cancel'),),
                      ElevatedButton(onPressed: _isValidUser ? _saveUser : null, child: const Text('Save'),),
                    ],
                  ),
                ]
              else 
                ...[
                  SizedBox(height: 2),
                  _buildUserSearch(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _isAddingNewUser = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New User'),
                    ),
                  ),
                ],
        
              Row(
                children: [
                  Text(
                    'Items (${_items.length})',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _addItemDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SizedBox(
                          height: 360,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Container(
                                  height: 4.0,
                                  width: 40.0,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                              ),
                              ListTile(
                                title: const Text('Templates'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TemplatesScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: templates.isEmpty
                                    ? const Center(
                                        child: Text(
                                            'No templates. Add from Templates screen.'),
                                      )
                                    : ListView.builder(
                                        itemCount: templates.length,
                                        itemBuilder: (c, idx) {
                                          final t = templates[idx];
                                          return ListTile(
                                            title: Text(
                                                t.name.isNotEmpty ? t.name : t.type),
                                            subtitle: Text(
                                                'Wt:${t.weight}g • Rate:₹${t.pricePerGram} • Making:₹${t.makingCharge}'),
                                            trailing: IconButton(
                                              icon:
                                                  const Icon(Icons.add_circle_outline),
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _addItemDialog(prefill: t);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Quick Add'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: BorderSide(color: gold),
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 100.0, maxHeight: MediaQuery.of(context).size.height * 0.5,),
                child: _items.isEmpty
                  ? const SizedBox(child: Center(child: Text('No items added')))
                  : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final it = _items[i];
                      return Card(
                        child: ListTile(
                          title: Text(it.name.isNotEmpty ? it.name : it.type),
                          subtitle: Text(
                              'Wt: ${it.weight}g • Rate: ₹${it.pricePerGram.toStringAsFixed(2)} • Making: ${it.makingCharge.toStringAsFixed(2)}% • Total: ₹${it.total.toStringAsFixed(2)}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _editItemDialog(i);
                              if (v == 'remove') {
                                setState(() => _items.removeAt(i));
                              }
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(
                                  value: 'remove', child: Text('Remove')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subtotal: ₹ ${calc.subtotal.toStringAsFixed(2)}'),
                            Text('Making: ₹ ${calc.totalMaking.toStringAsFixed(2)}'),
                            const SizedBox(height: 6),
                            Text(
                              'Grand Total: ₹ ${calc.grandTotal.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: gold),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _items.isEmpty || !_isNextEnabled
                          ? null
                          : () => _goToPreview(calc),
                        child: const Text('Next: Payment'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<User>> _fetchFilteredUsers(WidgetRef ref, String? filter) async {
    final userState = ref.read(userNotifierProvider);
    final lower = (filter ?? '').toLowerCase();

    await Future.delayed(const Duration(milliseconds: 100));

    final localFiltered = userState.users.where((u) {
      if (lower.isEmpty) return true;
      final byName = u.name.toLowerCase().contains(lower);
      final byPhone = (u.mobile).toLowerCase().contains(lower);
      return byName || byPhone;
    }).toList();
    if (lower.length < 2 || localFiltered.isNotEmpty || userState.users.length <= 20) {
      return localFiltered;
    }
    try {
      final remoteUsers = await userService.fetchUsers(lower, 1, 20);
      final Map<String, User> merged = {
        for (var u in localFiltered)
          if (u.uuid != null) u.uuid!: u,
        for (var u in remoteUsers)
          if (u.uuid != null) u.uuid!: u,
      };

      final results = merged.values.toList();

      if (results.isEmpty) {
        results.add(
          User(
            uuid: 'add_new',
            name: '➕ Add "$filter"',
            mobile: filter ?? '',
            email: '',
            address: '',
          ),
        );
      }

      return results;
    } catch (e, st) {
      debugPrint('Error fetching users: $e\n$st');
      return localFiltered;
    }
  }

  Widget _buildUserSearch(BuildContext context) {
    return DropdownSearch<User>(
      mode: Mode.form,
      items: (String? filter, _) => _fetchFilteredUsers(ref, filter),
      selectedItem: _selectedUser,
      compareFn: (a, b) => a.uuid == b.uuid,
      itemAsString: (User? u) => u?.name ?? '',
      filterFn: (User u, String filter) {
        final q = filter.toLowerCase();
        final byName = u.name.toLowerCase().contains(q);
        final byPhone = (u.mobile).toLowerCase().contains(q);
        return byName || byPhone;
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: BoxConstraints(
          minHeight: 0,
          maxHeight: 300,
        ),
        searchFieldProps: const TextFieldProps(
          decoration: InputDecoration(
            labelText: 'Search or Add User',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      ),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Select Customer',
          border: OutlineInputBorder(),
        ),
      ),
      onChanged: (User? selectedUser) {
        if (selectedUser == null) return;
        if (selectedUser.uuid == 'add_new') {
          setState(() {
            _isAddingNewUser = true;
            _selectedUser = null;
            _customerNameCtrl.clear();
            _customerPhoneCtrl.clear();
          });
        } else {
          setState(() {
            _isAddingNewUser = false;
            _selectedUser = selectedUser;
            _customerNameCtrl.text = selectedUser.name;
            _customerPhoneCtrl.text = selectedUser.mobile;
          });
        }
      },
    );
  }

  bool get _isNextEnabled {
    if (_isAddingNewUser) {
      return _customerNameCtrl.text.trim().isNotEmpty &&
        RegExp(r'^[0-9]{10}$').hasMatch(_customerPhoneCtrl.text);
    } else {
      return _selectedUser != null;
    }
  }

  Future<void> _goToPreview(CalculateTax calc) async {
    User? finalUser = _selectedUser;
    final billDraft = {
      'customerId': finalUser?.uuid,
      'customerName': finalUser?.name ?? _customerNameCtrl.text.trim(),
      'customerPhone': finalUser?.mobile ?? _customerPhoneCtrl.text.trim(),
      'items': _items,
      'grandTotal': calc.grandTotal,
    };

    if(mounted){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(billDraft: billDraft),
        ),
      );
    }
  }

  bool get _isValidUser {
    return _customerNameCtrl.text.trim().isNotEmpty && _customerPhoneCtrl.text.trim().isNotEmpty;
  }

  Future<void> _saveUser() async {
    final name = _customerNameCtrl.text.trim();
    final phone = _customerPhoneCtrl.text.trim();

    try {
      final userService = ref.read(userServiceProvider);
      final newUser = await userService.createUser(name: name, phone: phone);
      if (mounted) {
        setState(() {
          _isAddingNewUser = false;
          _selectedUser = newUser;
          _customerNameCtrl.clear();
          _customerPhoneCtrl.clear();
        });
      }
    } catch (e) {
      debugPrint("$e");
      //
    }
  }
}
