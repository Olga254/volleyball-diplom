import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/authorization_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/role_details_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/team_screen.dart';
import '../screens/main/schedule_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/main/game_search_screen.dart';
import '../screens/main/notifications_screen.dart';
import '../screens/main/teams_follow_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_games_screen.dart';
import '../screens/captain/captain_panel_screen.dart';
import '../screens/captain/captain_create_game_screen.dart';
import '../screens/referee/referee_profile_screen.dart';
import '../screens/fan/fan_settings_screen.dart';
import '../screens/amateur/amateur_create_game_screen.dart';
import '../screens/amateur/amateur_application_screen.dart';
import '../screens/amateur/amateur_applications_list_screen.dart';
import '../screens/amateur/game_details_screen.dart';
import '../screens/notifications/invitations_screen.dart';
import '../screens/team/team_profile_screen.dart';
import '../screens/team/add_player_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/authorization',
    routes: [
      GoRoute(path: '/authorization', builder: (context, state) => const AuthorizationScreen()),
      GoRoute(path: '/registration', builder: (context, state) => const RegistrationScreen()),
      GoRoute(path: '/role-selection', builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/role-details', builder: (context, state) => const RoleDetailsScreen()),
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/team', builder: (context, state) => const TeamScreen()),
          GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/game-search', builder: (context, state) => const GameSearchScreen()),
          GoRoute(path: '/teams-follow', builder: (context, state) => const TeamsFollowScreen()),
        ],
      ),
      GoRoute(path: '/team/add-player', builder: (context, state) => const AddPlayerScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminPanelScreen()),
      GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
      GoRoute(path: '/admin/games', builder: (context, state) => const AdminGamesScreen()),
      GoRoute(path: '/captain', builder: (context, state) => const CaptainPanelScreen()),
      GoRoute(path: '/captain/create-game', builder: (context, state) => const CaptainCreateGameScreen()),
      GoRoute(path: '/referee/:name', builder: (context, state) => RefereeProfileScreen(refereeName: state.pathParameters['name']!)),
      GoRoute(path: '/fan-settings', builder: (context, state) => const FanSettingsScreen()),
      GoRoute(path: '/amateur/create-game', builder: (context, state) => const AmateurCreateGameScreen()),
      GoRoute(path: '/amateur/application', builder: (context, state) => const AmateurApplicationScreen()),
      GoRoute(path: '/amateur/applications/:gameId', builder: (context, state) => AmateurApplicationsListScreen(gameId: state.pathParameters['gameId']!)),
      GoRoute(path: '/game-details/:gameId', builder: (context, state) {
        final game = state.extra as Map<String, dynamic>;
        return GameDetailsScreen(game: game);
      }),
      GoRoute(path: '/invitations', builder: (context, state) => const InvitationsScreen()),
      GoRoute(path: '/team-profile/:teamId', builder: (context, state) => TeamProfileScreen(teamId: state.pathParameters['teamId']!)),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    ],
  );
}