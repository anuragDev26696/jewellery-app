import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swarn_abhushan/providers/user_provider.dart';
import '../services/user_service.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final ScrollController _scrollController = ScrollController();
  late UserService userService;
  bool _isLoadMore = false;
  
  @override
  void initState() {
    super.initState();
    userService = ref.read(userServiceProvider);
    // Load initial users
    Future.microtask(() async {
      await userService.fetchUsers(null, 1, 10);
    });

    // Add listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onScroll() async {
    final userState = ref.read(userNotifierProvider);

    if(_isLoadMore || userState.isLastPage) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _isLoadMore = true;
      try {
        await userService.fetchUsers(null, userState.page + 1, userState.limit);
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
                await userService.fetchUsers(null,1,userState.limit);
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
                    onTap: () {
                      // navigate or show user details
                    },
                  );
                },
              ),
            ),
    );
  }
}
