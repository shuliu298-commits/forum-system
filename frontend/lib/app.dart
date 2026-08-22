import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/api_client.dart';
import 'pages/login_page.dart';
import 'pages/post_list_page.dart';
import 'pages/user_list_page.dart';
import 'services/auth_state.dart';
import 'services/post_service.dart';
import 'services/user_service.dart';

/// 应用根组件:依赖装配 + 主题 + 路由。
class ForumApp extends StatelessWidget {
  const ForumApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final userService = UserService(apiClient);
    final postService = PostService(apiClient);
    final authState = AuthState(userService, preferences);
    ApiClient.unauthorizedHandler = authState.onUnauthorized;

    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: userService),
        Provider.value(value: postService),
        ChangeNotifierProvider.value(value: authState),
      ],
      child: MaterialApp(
        title: '论坛系统',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: PostListPage.routeName,
        routes: {
          PostListPage.routeName: (_) => const PostListPage(),
          UserListPage.routeName: (_) => const UserListPage(),
          LoginPage.routeName: (_) => const LoginPage(),
        },
      ),
    );
  }
}
