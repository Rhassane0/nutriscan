import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../services/ai_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../providers/theme_provider.dart';

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({super.key});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, String>> _dietTypes = {
    'Tous': {'emoji': '🍽️', 'label': 'Tous'},
    'balanced': {'emoji': '⚖️', 'label': 'Équilibré'},
    'high-protein': {'emoji': '💪', 'label': 'Riche en protéines'},
    'low-carb': {'emoji': '🥩', 'label': 'Faible en glucides'},
    'low-fat': {'emoji': '🥗', 'label': 'Faible en gras'},
  };

  final Map<String, Map<String, String>> _healthLabelsInfo = {
    'vegetarian': {'emoji': '🥬', 'label': 'Végétarien'},
    'vegan': {'emoji': '🌱', 'label': 'Végan'},
    'gluten-free': {'emoji': '🌾', 'label': 'Sans gluten'},
    'dairy-free': {'emoji': '🥛', 'label': 'Sans lactose'},
    'peanut-free': {'emoji': '🥜', 'label': 'Sans arachides'},
    'tree-nut-free': {'emoji': '🌰', 'label': 'Sans fruits à coque'},
  };

  String _selectedDiet = 'Tous';
  final Set<String> _selectedHealthLabels = {};
  int _maxCalories = 800;

  final List<String> _popularSearches = ['Chicken', 'Salad', 'Pasta', 'Salmon', 'Beef', 'Vegetarian', 'Soup', 'Rice'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchRecipes([String? query]) async {
    final searchQuery = query ?? _searchController.text.trim();

    if (searchQuery.isEmpty) {
      setState(() => _error = 'Veuillez entrer un terme de recherche');
      return;
    }

    if (query != null) _searchController.text = query;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aiService = context.read<AiService>();
      final recipes = await aiService.searchRecipes(
        query: searchQuery,
        dietType: _selectedDiet == 'Tous' ? null : _selectedDiet,
        healthLabels: _selectedHealthLabels.isNotEmpty ? _selectedHealthLabels.toList() : null,
        maxCalories: _maxCalories,
      );

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche de Recettes'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(isDark),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: Column(
          children: [
            // Barre de recherche
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une recette (ex: poulet, salade...)',
                      hintStyle: TextStyle(
                        color: isDark ? AppTheme.darkTextTertiary : Colors.grey[500],
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _recipes = []);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                      ),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _searchRecipes(),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isLoading ? 'Recherche...' : 'Rechercher'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filtres actifs
            if (_selectedHealthLabels.isNotEmpty || _selectedDiet != 'Tous')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark
                    ? AppTheme.primaryGreen.withAlpha(30)
                    : AppTheme.primaryGreen.withAlpha(20),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 16, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_selectedDiet != 'Tous')
                              _buildActiveChip(
                                '${_dietTypes[_selectedDiet]!['emoji']} ${_dietTypes[_selectedDiet]!['label']}',
                                () => setState(() => _selectedDiet = 'Tous'),
                                isDark,
                              ),
                            ..._selectedHealthLabels.map((label) => _buildActiveChip(
                              '${_healthLabelsInfo[label]?['emoji'] ?? '🏷️'} ${_healthLabelsInfo[label]?['label'] ?? label}',
                              () => setState(() => _selectedHealthLabels.remove(label)),
                              isDark,
                            )),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedDiet = 'Tous';
                        _selectedHealthLabels.clear();
                      }),
                      child: const Text('Effacer', style: TextStyle(color: AppTheme.errorRed)),
                    ),
                  ],
                ),
              ),

            // Contenu principal
            Expanded(
              child: _isLoading
                  ? const LoadingIndicator(message: 'Recherche de recettes...')
                  : _error != null
                      ? _buildErrorState(isDark)
                      : _recipes.isEmpty
                          ? _buildEmptyState(isDark)
                          : _buildRecipesList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        deleteIcon: Icon(Icons.close, size: 16, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
        onDeleted: onRemove,
        backgroundColor: isDark ? AppTheme.darkSurfaceLight : Colors.white,
        side: const BorderSide(color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
            ),
            const SizedBox(height: 24),
            Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _searchRecipes(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final hasSearched = _searchController.text.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Text(hasSearched ? '🔍' : '🍳', style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            hasSearched ? 'Aucune recette trouvée pour "${_searchController.text}"' : 'Recherchez des recettes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearched
                ? 'Essayez avec des termes plus généraux comme "chicken", "pasta", "salad"...'
                : 'Entrez un ingrédient ou un plat pour commencer',
            style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          if (hasSearched) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppTheme.accentBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Conseil : Utilisez des termes en anglais pour plus de résultats (chicken, beef, fish...)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          Text(
            'Suggestions populaires',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _popularSearches.map((search) => ActionChip(
              avatar: Icon(Icons.search, size: 16, color: isDark ? AppTheme.primaryGreenLight : AppTheme.primaryGreen),
              label: Text(
                search,
                style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
              ),
              onPressed: () => _searchRecipes(search),
              backgroundColor: isDark
                  ? AppTheme.primaryGreen.withAlpha(40)
                  : AppTheme.primaryGreen.withAlpha(20),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
          child: Row(
            children: [
              Text(
                '${_recipes.length} recette${_recipes.length > 1 ? 's' : ''} trouvée${_recipes.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Text(
                'pour "${_searchController.text}"',
                style: TextStyle(
                  color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recipes.length,
            itemBuilder: (context, index) => _buildRecipeCard(_recipes[index], isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isDark ? 0 : 3,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe, isDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge calories
            Stack(
              children: [
                if (recipe.image != null && recipe.image!.isNotEmpty)
                  Image.network(
                    recipe.image!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                      );
                    },
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(isDark),
                  )
                else
                  _buildPlaceholderImage(isDark),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text('${recipe.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildNutrientBadge('🥩', '${recipe.proteins.toStringAsFixed(0)}g', isDark),
                      const SizedBox(width: 8),
                      _buildNutrientBadge('🍞', '${recipe.carbs.toStringAsFixed(0)}g', isDark),
                      const SizedBox(width: 8),
                      _buildNutrientBadge('🥑', '${recipe.fats.toStringAsFixed(0)}g', isDark),
                      const Spacer(),
                      if (recipe.servings > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurfaceElevated : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people, size: 14, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.servings}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextSecondary : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRecipeDetails(recipe, isDark),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('Détails'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side: const BorderSide(color: AppTheme.primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('${recipe.name} ajouté au plan')),
                                ]),
                                backgroundColor: AppTheme.successGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      height: 180,
      color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 48, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextTertiary : Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBadge(String emoji, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceElevated : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🔍 Filtres',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.close, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          '🍽️ Type de régime',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _dietTypes.entries.map((entry) {
                            final isSelected = _selectedDiet == entry.key;
                            return ChoiceChip(
                              label: Text(
                                '${entry.value['emoji']} ${entry.value['label']}',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() => _selectedDiet = entry.key);
                                setState(() {});
                              },
                              selectedColor: AppTheme.primaryGreen.withAlpha(50),
                              backgroundColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          '⚠️ Restrictions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _healthLabelsInfo.entries.map((entry) {
                            final isSelected = _selectedHealthLabels.contains(entry.key);
                            return FilterChip(
                              label: Text(
                                '${entry.value['emoji']} ${entry.value['label']}',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.errorRed
                                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    _selectedHealthLabels.add(entry.key);
                                  } else {
                                    _selectedHealthLabels.remove(entry.key);
                                  }
                                });
                                setState(() {});
                              },
                              selectedColor: AppTheme.errorRed.withAlpha(50),
                              backgroundColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Text(
                              '🔥 Calories max',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$_maxCalories kcal',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                            ),
                          ],
                        ),
                        Slider(
                          value: _maxCalories.toDouble(),
                          min: 100,
                          max: 1500,
                          divisions: 28,
                          activeColor: AppTheme.primaryGreen,
                          inactiveColor: isDark ? AppTheme.darkBorder : Colors.grey[300],
                          onChanged: (value) {
                            setModalState(() => _maxCalories = value.toInt());
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              if (_searchController.text.isNotEmpty) _searchRecipes();
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Appliquer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRecipeDetails(Recipe recipe, bool isDark) {
    // Calculate daily value percentages
    final dvCalories = (recipe.calories / 2000 * 100).clamp(0.0, 200.0);
    final dvProtein = (recipe.proteins / 50 * 100).clamp(0.0, 200.0);
    final dvCarbs = (recipe.carbs / 260 * 100).clamp(0.0, 200.0);
    final dvFat = (recipe.fats / 70 * 100).clamp(0.0, 200.0);

    // Calculate health score
    int healthScore = 50;
    if (recipe.proteins > 20) healthScore += 15;
    if (recipe.proteins > 10) healthScore += 10;
    if (recipe.carbs < 30) healthScore += 10;
    if (recipe.fats < 20) healthScore += 10;
    if (recipe.calories < 500) healthScore += 10;
    healthScore = healthScore.clamp(0, 100);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1F1B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with image
                      if (recipe.image != null && recipe.image!.isNotEmpty)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                recipe.image!,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppTheme.primaryGreen.withOpacity(0.3), AppTheme.primaryGreenDark.withOpacity(0.2)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(Icons.restaurant, size: 64, color: AppTheme.primaryGreen.withOpacity(0.5)),
                                ),
                              ),
                            ),
                            // Health Score Badge
                            Positioned(
                              top: 12, right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: healthScore >= 70 ? Colors.green : healthScore >= 40 ? Colors.orange : Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text('$healthScore', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // Recipe Title
                      Text(
                        recipe.name,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick Info Row
                      Row(
                        children: [
                          if (recipe.servings > 0)
                            _buildQuickInfo(Icons.people_outline, '${recipe.servings} portions', isDark),
                          if (recipe.prepTime != null) ...[
                            const SizedBox(width: 16),
                            _buildQuickInfo(Icons.timer_outlined, '${recipe.prepTime} min', isDark),
                          ],
                          const SizedBox(width: 16),
                          _buildQuickInfo(Icons.local_fire_department, '${recipe.calories.toInt()} kcal', isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Diet & Health Labels
                      if ((recipe.dietLabels != null && recipe.dietLabels!.isNotEmpty) ||
                          (recipe.healthLabels != null && recipe.healthLabels!.isNotEmpty)) ...[
                        Text('Labels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.textDark)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [
                            if (recipe.dietLabels != null)
                              ...recipe.dietLabels!.take(5).map((label) => _buildLabelChip(label, Colors.purple, isDark)),
                            if (recipe.healthLabels != null)
                              ...recipe.healthLabels!.take(5).map((label) => _buildLabelChip(label, AppTheme.primaryGreen, isDark)),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Nutrition Section - Main Macros
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppTheme.primaryGreen.withOpacity(0.15), AppTheme.primaryGreen.withOpacity(0.05)]
                                : [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.primaryGreen.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pie_chart, color: AppTheme.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Text('Valeurs Nutritionnelles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.textDark)),
                                const Spacer(),
                                Text('par portion', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildMacroCard('Calories', '${recipe.calories.toInt()}', 'kcal', AppTheme.caloriesColor, dvCalories, isDark)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildMacroCard('Protéines', '${recipe.proteins.toStringAsFixed(1)}', 'g', AppTheme.proteinColor, dvProtein, isDark)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildMacroCard('Glucides', '${recipe.carbs.toStringAsFixed(1)}', 'g', AppTheme.carbsColor, dvCarbs, isDark)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildMacroCard('Lipides', '${recipe.fats.toStringAsFixed(1)}', 'g', AppTheme.fatColor, dvFat, isDark)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Macro Distribution Visual
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Répartition des Macros', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700])),
                            const SizedBox(height: 12),
                            _buildMacroDistributionBar(recipe, isDark),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMacroLegend('Protéines', AppTheme.proteinColor, _calculateMacroPercent(recipe.proteins, recipe)),
                                _buildMacroLegend('Glucides', AppTheme.carbsColor, _calculateMacroPercent(recipe.carbs, recipe)),
                                _buildMacroLegend('Lipides', AppTheme.fatColor, _calculateMacroPercent(recipe.fats, recipe)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ingredients Section
                      if (recipe.ingredients.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.list_alt, color: AppTheme.accentTeal, size: 20),
                            const SizedBox(width: 8),
                            Text('Ingrédients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.textDark)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${recipe.ingredients.length} items', style: TextStyle(fontSize: 12, color: AppTheme.accentTeal, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                          ),
                          child: Column(
                            children: recipe.ingredients.asMap().entries.map((entry) => Padding(
                              padding: EdgeInsets.only(bottom: entry.key < recipe.ingredients.length - 1 ? 10 : 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppTheme.textMedium, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Instructions Section
                      if (recipe.instructions != null && recipe.instructions!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.menu_book, color: AppTheme.secondaryOrange, size: 20),
                            const SizedBox(width: 8),
                            Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...recipe.instructions!.asMap().entries.map((entry) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark]),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(entry.value, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white70 : AppTheme.textMedium)),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                      ],

                      // Source Link
                      if (recipe.url != null) ...[
                        GestureDetector(
                          onTap: () {
                            // TODO: Open URL
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link, color: Colors.blue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('Voir la recette originale', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                ),
                                Icon(Icons.open_in_new, color: Colors.blue, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Fermer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
                                side: BorderSide(color: isDark ? Colors.white30 : Colors.grey[400]!),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('${recipe.name} ajouté au plan !')),
                                    ]),
                                    backgroundColor: AppTheme.successGreen,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_circle, size: 20),
                              label: const Text('Ajouter au plan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickInfo(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.textDark)),
        ],
      ),
    );
  }

  Widget _buildLabelChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label.replaceAll('-', ' ').replaceAll('_', ' '),
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, String unit, Color color, double dvPercent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${dvPercent.toInt()}% AJR', style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistributionBar(Recipe recipe, bool isDark) {
    final total = recipe.proteins * 4 + recipe.carbs * 4 + recipe.fats * 9;
    final proteinPercent = total > 0 ? (recipe.proteins * 4 / total) : 0.0;
    final carbsPercent = total > 0 ? (recipe.carbs * 4 / total) : 0.0;
    final fatPercent = total > 0 ? (recipe.fats * 9 / total) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 12,
        child: Row(
          children: [
            Expanded(flex: (proteinPercent * 100).toInt().clamp(1, 100), child: Container(color: AppTheme.proteinColor)),
            Expanded(flex: (carbsPercent * 100).toInt().clamp(1, 100), child: Container(color: AppTheme.carbsColor)),
            Expanded(flex: (fatPercent * 100).toInt().clamp(1, 100), child: Container(color: AppTheme.fatColor)),
          ],
        ),
      ),
    );
  }

  double _calculateMacroPercent(double macro, Recipe recipe) {
    final total = recipe.proteins * 4 + recipe.carbs * 4 + recipe.fats * 9;
    if (macro == recipe.fats) {
      return total > 0 ? (macro * 9 / total * 100) : 0.0;
    }
    return total > 0 ? (macro * 4 / total * 100) : 0.0;
  }

  Widget _buildMacroLegend(String label, Color color, double percent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text('$label ${percent.toInt()}%', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
