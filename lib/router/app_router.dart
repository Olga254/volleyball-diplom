import 'package:go_router/go_router.dart';
import '../screens/auth/role_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/authorization_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/team_screen.dart';
import '../screens/main/team_edit_screen.dart';
import '../screens/main/add_player_screen.dart';
import '../screens/main/schedule_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/main/game_search_screen.dart';
import '../screens/main/notifications_screen.dart';
import '../screens/main/teams_follow_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/role',
    routes: [
      GoRoute(path: '/role', builder: (context, state) => const RoleScreen()),
      GoRoute(path: '/registration', builder: (context, state) => const RegistrationScreen()),
      GoRoute(path: '/authorization', builder: (context, state) => const AuthorizationScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/team', builder: (context, state) => const TeamScreen()),
      GoRoute(path: '/team/edit', builder: (context, state) => const TeamEditScreen()),
      GoRoute(path: '/team/add-player', builder: (context, state) => const AddPlayerScreen()),
      GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/game-search', builder: (context, state) => const GameSearchScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/teams-follow', builder: (context, state) => const TeamsFollowScreen()),
    ],
  );
}