import 'package:flutter/cupertino.dart';

import '../../features/auth/data/models/author.dart';
import '../../features/auth/views/forgot_password_page.dart';
import '../../features/auth/views/login_animation.dart';
import '../../features/auth/views/login_intro_page.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/signup_page.dart';
import '../../features/base/views/base_page.dart';
import '../../features/base/views/loading_app_page.dart';
import '../../features/categories/views/category_page.dart';
import '../../features/comments/views/comment_page.dart';
import '../../features/explore/views/all_authors_page.dart';
import '../../features/explore/views/author_page.dart';
import '../../features/explore/views/search_page.dart';
import '../../features/notification/views/notification_page.dart';
import '../../features/onboarding/views/select_language_theme_page.dart';
import '../../features/posts/data/models/article_model.dart';
import '../../features/posts/views/components/view_post_image_full_screen.dart';
import '../../features/posts/views/post_page.dart';
import '../../features/recommendation/views/select_preference_page.dart';
import '../../features/settings/views/information_page.dart';
import '../../features/tag/data/models/post_tag.dart';
import '../../features/tag/views/tag_posts_page.dart';
import 'app_routes.dart';
import 'unknown_page.dart';

class RouteGenerator {
  static Route? onGenerate(RouteSettings settings) {
    final route = settings.name;
    final args = settings.arguments;

    switch (route) {
      case AppRoutes.initial:
        return CupertinoPageRoute(builder: (_) => const LoadingAppPage());

      case AppRoutes.loadingApp:
        return CupertinoPageRoute(builder: (_) => const LoadingAppPage());

      case AppRoutes.selectThemeAndLang:
        return CupertinoPageRoute(
            builder: (_) => const SelectLanguageAndThemePage());

      case AppRoutes.entryPoint:
        return CupertinoPageRoute(builder: (_) => const EntryPointUI());

      case AppRoutes.login:
        return CupertinoPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.loginAnimation:
        return CupertinoPageRoute(builder: (_) => const LoggingInAnimation());

      case AppRoutes.loginIntro:
        return CupertinoPageRoute(builder: (_) => const LoginIntroPage());

      case AppRoutes.signup:
        return CupertinoPageRoute(builder: (_) => const SignUpPage());

      case AppRoutes.forgotPass:
        return CupertinoPageRoute(builder: (_) => const ForgotPasswordPage());

      case AppRoutes.search:
        return CupertinoPageRoute(builder: (_) => const SearchPage());

      case AppRoutes.notification:
        return CupertinoPageRoute(builder: (_) => const NotificationPage());

      case AppRoutes.post:
        if (args is ArticleModel) {
          return CupertinoPageRoute(builder: (_) => PostPage(article: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.comment:
        if (args is ArticleModel) {
          return CupertinoPageRoute(builder: (_) => CommentPage(article: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.category:
        if (args is CategoryPageArguments) {
          return CupertinoPageRoute(
              builder: (_) => CategoryPage(arguments: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.tag:
        if (args is PostTag) {
          return CupertinoPageRoute(builder: (_) => TagPage(tag: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.authorPage:
        if (args is AuthorData) {
          return CupertinoPageRoute(
              builder: (_) => AuthorPostPage(author: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.contact:
        return CupertinoPageRoute(builder: (_) => const ContactPage());

      case AppRoutes.viewImageFullScreen:
        if (args is String) {
          return CupertinoPageRoute(
              builder: (_) => ViewImageFullScreen(url: args));
        } else {
          return errorRoute();
        }

      case AppRoutes.allAuthors:
        return CupertinoPageRoute(builder: (_) => const AllAuthorsPage());

      case AppRoutes.selectYourPreference:
        return CupertinoPageRoute(builder: (_) => const SelectPreferencePage());

      default:
        return errorRoute();
    }
  }

  static Route? errorRoute() =>
      CupertinoPageRoute(builder: (_) => const UnknownPage());
}
