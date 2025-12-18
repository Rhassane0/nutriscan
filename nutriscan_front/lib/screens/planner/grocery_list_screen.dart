import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/planner_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/loading_indicator.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  // État local pour gérer les items cochés immédiatement
  final Set<int> _localPurchasedItems = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlannerProvider>().loadGroceryLists();
    });
  }

  void _initializeLocalState(List<dynamic> items) {
    if (!_initialized) {
      for (var item in items) {
        if (item.id != null && item.purchased) {
          _localPurchasedItems.add(item.id!);
        }
      }
      _initialized = true;
    }
  }

  Future<void> _toggleItem(int? itemId, bool newValue, PlannerProvider provider) async {
    if (itemId == null) return;

    // Mise à jour locale immédiate
    setState(() {
      if (newValue) {
        _localPurchasedItems.add(itemId);
      } else {
        _localPurchasedItems.remove(itemId);
      }
    });

    // Mise à jour sur le serveur
    try {
      await provider.toggleItemPurchased(itemId, newValue);
    } catch (e) {
      // En cas d'erreur, revenir à l'état précédent
      setState(() {
        if (newValue) {
          _localPurchasedItems.remove(itemId);
        } else {
          _localPurchasedItems.add(itemId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final isFrench = context.watch<LocaleProvider>().isFrench;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? 'Liste de Courses' : 'Grocery List'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initialized = false;
                _localPurchasedItems.clear();
              });
              context.read<PlannerProvider>().loadGroceryLists();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: Consumer<PlannerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return LoadingIndicator(message: isFrench ? 'Chargement de la liste...' : 'Loading list...');
            }

            if (provider.currentGroceryList == null) {
              return _buildEmptyState(isDark);
            }

            final groceryList = provider.currentGroceryList!;

            // Initialiser l'état local avec les données du serveur
            _initializeLocalState(groceryList.items);

            // Calculer les stats avec l'état local
            final totalItems = groceryList.items.length;
            final purchasedItems = groceryList.items.where((item) =>
              item.id != null && _localPurchasedItems.contains(item.id)
            ).length;
            final progress = totalItems > 0 ? purchasedItems / totalItems : 0.0;

            return Column(
              children: [
                // En-tête avec progression
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isFrench
                          ? '$purchasedItems / $totalItems articles achetés'
                          : '$purchasedItems / $totalItems items purchased',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withAlpha(50),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste des catégories
                Expanded(
                  child: groceryList.categories.isEmpty
                      ? Center(
                          child: Text(
                            isFrench ? 'Aucun article dans la liste' : 'No items in the list',
                            style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: groceryList.categories.length,
                          itemBuilder: (context, index) {
                            final category = groceryList.categories[index];
                            final categoryPurchased = category.items.where((item) =>
                              item.id != null && _localPurchasedItems.contains(item.id)
                            ).length;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: isDark ? 0 : 2,
                              color: isDark ? AppTheme.darkSurface : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  initiallyExpanded: index == 0,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(category.category).withAlpha(isDark ? 50 : 30),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getCategoryEmoji(category.category),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  title: Text(
                                    _formatCategoryName(category.category),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$categoryPurchased/${category.items.length} achetés',
                                    style: TextStyle(color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: categoryPurchased == category.items.length
                                          ? AppTheme.successGreen.withAlpha(isDark ? 50 : 30)
                                          : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[200]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${category.items.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: categoryPurchased == category.items.length
                                            ? AppTheme.successGreen
                                            : (isDark ? AppTheme.darkTextSecondary : Colors.grey[700]),
                                      ),
                                    ),
                                  ),
                                  children: category.items.map((item) {
                                    final isPurchased = item.id != null && _localPurchasedItems.contains(item.id);

                                    return InkWell(
                                      onTap: () => _toggleItem(item.id, !isPurchased, provider),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isPurchased
                                              ? AppTheme.successGreen.withAlpha(isDark ? 20 : 10)
                                              : null,
                                          border: Border(
                                            top: BorderSide(color: isDark ? AppTheme.darkDivider : Colors.grey[200]!),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Checkbox custom
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: isPurchased
                                                    ? AppTheme.successGreen
                                                    : (isDark ? AppTheme.darkSurfaceLight : Colors.white),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isPurchased
                                                      ? AppTheme.successGreen
                                                      : (isDark ? AppTheme.darkBorder : Colors.grey[400]!),
                                                  width: 2,
                                                ),
                                              ),
                                              child: isPurchased
                                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                                  : null,
                                            ),
                                            const SizedBox(width: 16),
                                            // Détails de l'item
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      decoration: isPurchased ? TextDecoration.lineThrough : null,
                                                      color: isPurchased
                                                          ? (isDark ? AppTheme.darkTextTertiary : Colors.grey[500])
                                                          : (isDark ? AppTheme.darkTextPrimary : Colors.grey[800]),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    const categoryNames = {
      'VEGETABLES': 'Légumes',
      'FRUITS': 'Fruits',
      'PROTEIN': 'Protéines',
      'DAIRY': 'Produits laitiers',
      'GRAINS': 'Céréales',
      'SPICES': 'Épices',
      'CONDIMENTS': 'Condiments',
      'BEVERAGES': 'Boissons',
      'SNACKS': 'Snacks',
      'OTHER': 'Autres',
      'Autres': 'Autres',
    };
    return categoryNames[category] ?? category;
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'VEGETABLES': '🥬',
      'FRUITS': '🍎',
      'PROTEIN': '🥩',
      'DAIRY': '🥛',
      'GRAINS': '🌾',
      'SPICES': '🧂',
      'CONDIMENTS': '🫙',
      'BEVERAGES': '🥤',
      'SNACKS': '🍪',
      'OTHER': '📦',
      'Autres': '📦',
    };
    return emojis[category] ?? '🛒';
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'VEGETABLES': Colors.green,
      'FRUITS': Colors.orange,
      'PROTEIN': Colors.red,
      'DAIRY': Colors.blue,
      'GRAINS': Colors.brown,
      'SPICES': Colors.amber,
      'CONDIMENTS': Colors.purple,
      'BEVERAGES': Colors.cyan,
      'SNACKS': Colors.pink,
      'OTHER': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  Widget _buildEmptyState(bool isDark) {
    final isFrench = context.watch<LocaleProvider>().isFrench;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Text('🛒', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            isFrench ? 'Aucune liste de courses' : 'No grocery list',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFrench
              ? 'Générez un plan repas pour créer\nvotre liste de courses'
              : 'Generate a meal plan to create\nyour grocery list',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: Text(isFrench ? 'Retour au planificateur' : 'Back to planner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
