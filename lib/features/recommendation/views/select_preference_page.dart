import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_pro/core/constants/app_defaults.dart';
import 'package:news_pro/features/auth/providers/authors_pagination.dart';
import 'package:news_pro/features/auth/providers/user_data_provider.dart';
import 'package:news_pro/features/categories/providers/preference_categories_controller.dart';
import 'package:news_pro/features/recommendation/views/components/author_selection_widget.dart';
import 'package:news_pro/features/recommendation/views/components/category_selection_widget.dart';
import 'package:news_pro/features/recommendation/views/components/preference_section_header.dart';
import 'package:news_pro/features/recommendation/views/components/tag_selection_widget.dart';
import 'package:news_pro/core/routes/app_routes.dart';
import 'package:news_pro/features/config/providers/config_providers.dart';
import 'package:news_pro/features/recommendation/providers/recommended_posts_provider.dart';
import 'package:news_pro/features/tag/providers/tags_controller.dart';
import 'package:news_pro/features/recommendation/views/components/preference_loading_shimmer.dart';

class SelectPreferencePage extends ConsumerStatefulWidget {
  const SelectPreferencePage({
    super.key,
    this.isDialog = false,
  });

  final bool isDialog;

  @override
  ConsumerState<SelectPreferencePage> createState() =>
      _SelectPreferencePageState();
}

class _SelectPreferencePageState extends ConsumerState<SelectPreferencePage> {
  // Selected IDs
  final Set<int> _selectedCategories = {};
  final Set<int> _selectedTags = {};
  final Set<int> _selectedAuthors = {};

  bool _isLoadingPrefs = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 2. Load User Preferences
    await _loadPreferences();

    // 1. Load Data Sequentially
    await ref.read(preferenceCategoriesController.notifier).getPosts();
    await ref.read(tagsController.notifier).getPosts();
    await ref.read(usersController.notifier).getPosts();

    if (mounted) {
      setState(() {
        _isLoadingPrefs = false;
      });
    }
  }

  Future<void> _loadPreferences() async {
    // Try to get from user data provider first (local/fast)
    final userData = await ref.read(userDataProvider.future);
    if (userData != null) {
      if (mounted) {
        setState(() {
          try {
            _selectedCategories.addAll(
                userData.savedCategories.map((e) => int.tryParse(e) ?? 0));
            _selectedTags
                .addAll(userData.savedTags.map((e) => int.tryParse(e) ?? 0));
            _selectedAuthors
                .addAll(userData.savedAuthors.map((e) => int.tryParse(e) ?? 0));
            // Remove 0s if any failed parse
            _selectedCategories.remove(0);
            _selectedTags.remove(0);
            _selectedAuthors.remove(0);
          } catch (e) {
            debugPrint('Error parsing user data preferences: $e');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving &&
          _selectedCategories.isEmpty &&
          _selectedTags.isEmpty &&
          _selectedAuthors.isEmpty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isSaving) return;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('unsaved_changes'.tr()),
            content: Text('unsaved_changes_message'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('discard'.tr()),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('personalize_feed'.tr()),
          leading: widget.isDialog
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: _isLoadingPrefs
            ? const PreferenceLoadingShimmer()
            : SafeArea(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDefaults.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PreferenceSectionHeader(title: 'categories'.tr()),
                      CategorySelectionWidget(
                        selectedIds: _selectedCategories,
                        onToggle: (id) {
                          setState(() {
                            if (_selectedCategories.contains(id)) {
                              _selectedCategories.remove(id);
                            } else {
                              _selectedCategories.add(id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      PreferenceSectionHeader(title: 'tags'.tr()),
                      TagSelectionWidget(
                        selectedIds: _selectedTags,
                        onToggle: (id) {
                          setState(() {
                            if (_selectedTags.contains(id)) {
                              _selectedTags.remove(id);
                            } else {
                              _selectedTags.add(id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      PreferenceSectionHeader(title: 'authors'.tr()),

                      AuthorSelectionWidget(
                        selectedIds: _selectedAuthors,
                        onToggle: (id) {
                          setState(() {
                            if (_selectedAuthors.contains(id)) {
                              _selectedAuthors.remove(id);
                            } else {
                              _selectedAuthors.add(id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: _DoneButton(
          onPressed: _saveAndContinue,
          isSaving: _isSaving,
        ),
      ),
    );
  }

  void _saveAndContinue() async {
    setState(() {
      _isSaving = true;
    });

    final controller = ref.read(recommendedPostsProvider.notifier);
    final isLoginEnabled =
        ref.read(configProvider).value?.isLoginEnabled ?? false;
    final user = ref.read(userDataProvider);

    await controller.saveAndContinue(
      selectedCategories: _selectedCategories,
      selectedTags: _selectedTags,
      selectedMembers: _selectedAuthors,
      ref: ref,
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          if (widget.isDialog) {
            Navigator.pop(context);
          } else if (isLoginEnabled && user.value == null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (v) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.entryPoint,
              (v) => false,
            );
          }
        }
      },
      onError: (msg) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({
    required this.onPressed,
    required this.isSaving,
  });

  final Function() onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDefaults.padding,
        right: AppDefaults.padding,
        bottom: MediaQuery.of(context).padding.bottom,
        top: AppDefaults.padding,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSaving ? null : onPressed,
          child: isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text('save_preferences'.tr()),
        ),
      ),
    );
  }
}
