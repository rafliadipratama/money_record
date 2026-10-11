import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/math/expression_evaluator.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import 'category_selector_chips.dart';

class InteractiveNumpadSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final ValueChanged<TransactionEntity> onSave;

  const InteractiveNumpadSheet({
    super.key,
    required this.categories,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CategoryEntity> categories,
    required ValueChanged<TransactionEntity> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InteractiveNumpadSheet(
        categories: categories,
        onSave: onSave,
      ),
    );
  }

  @override
  State<InteractiveNumpadSheet> createState() => _InteractiveNumpadSheetState();
}

class _InteractiveNumpadSheetState extends State<InteractiveNumpadSheet> {
  final TextEditingController _titleController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategoryId;

  String _expression = '';
  double _calculatedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Default to first matching category
    _updateDefaultCategory();
  }

  void _updateDefaultCategory() {
    final matching = widget.categories.where((c) => c.type == _selectedType).toList();
    if (matching.isNotEmpty) {
      _selectedCategoryId = matching.first.id;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  void _appendInput(String val) {
    HapticFeedback.lightImpact();
    setState(() {
      _expression += val;
      _recalculate();
    });
  }

  void _backspace() {
    HapticFeedback.lightImpact();
    if (_expression.isNotEmpty) {
      setState(() {
        _expression = _expression.substring(0, _expression.length - 1);
        _recalculate();
      });
    }
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _expression = '';
      _calculatedAmount = 0.0;
    });
  }

  void _recalculate() {
    if (_expression.isEmpty) {
      _calculatedAmount = 0.0;
      return;
    }

    try {
      _calculatedAmount = ExpressionEvaluator.evaluate(_expression);
    } catch (e) {
      // Expression in progress of typing (e.g. "15000 + ")
    }
  }

  void _submit() {
    HapticFeedback.heavyImpact();
    final title = _titleController.text.trim();

    if (_calculatedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal transaksi yang valid')),
      );
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama / judul transaksi')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori transaksi')),
      );
      return;
    }

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      title: title,
      amount: _calculatedAmount,
      type: _selectedType,
      categoryId: _selectedCategoryId!,
      date: DateTime.now(),
    );

    widget.onSave(transaction);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = _selectedType == TransactionType.expense;
    final activeColor = isExpense ? AppColors.expense : AppColors.income;

    final filteredCategories = widget.categories
        .where((c) => c.type == _selectedType)
        .toList();

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.cardBorderDark),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMutedDark.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Type Selector [Pengeluaran | Pemasukan]
          Row(
            children: [
              Expanded(
                child: _buildTypeSegment(
                  title: 'Pengeluaran',
                  isSelected: _selectedType == TransactionType.expense,
                  activeColor: AppColors.expense,
                  onTap: () {
                    setState(() {
                      _selectedType = TransactionType.expense;
                      _updateDefaultCategory();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeSegment(
                  title: 'Pemasukan',
                  isSelected: _selectedType == TransactionType.income,
                  activeColor: AppColors.income,
                  onTap: () {
                    setState(() {
                      _selectedType = TransactionType.income;
                      _updateDefaultCategory();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Amount & Expression Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.contains('+') || _expression.contains('-')) ...[
                  Text(
                    _expression,
                    style: AppTypography.caption.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  _calculatedAmount > 0
                      ? CurrencyFormatter.format(_calculatedAmount)
                      : (_expression.isEmpty ? 'Rp 0' : _expression),
                  style: AppTypography.balanceDisplay.copyWith(
                    color: activeColor,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title TextField
          TextField(
            controller: _titleController,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Judul transaksi (mis: Makan Siang, Kopi)',
              hintStyle: AppTypography.caption,
              prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.textSecondaryDark),
              filled: true,
              fillColor: AppColors.bgDark,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: activeColor),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Horizontal Category Chips
          CategorySelectorChips(
            categories: filteredCategories.isNotEmpty ? filteredCategories : widget.categories,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (id) => setState(() => _selectedCategoryId = id),
          ),
          const SizedBox(height: 16),

          // Custom In-App Numpad Grid
          _buildNumpadGrid(activeColor),
        ],
      ),
    );
  }

  Widget _buildTypeSegment({
    required String title,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.18) : AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.cardBorderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          title,
          style: AppTypography.subheadline.copyWith(
            fontSize: 14,
            color: isSelected ? activeColor : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadGrid(Color activeColor) {
    return Column(
      children: [
        Row(
          children: [
            _buildNumpadBtn('1'),
            _buildNumpadBtn('2'),
            _buildNumpadBtn('3'),
            _buildOpBtn('+', activeColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadBtn('4'),
            _buildNumpadBtn('5'),
            _buildNumpadBtn('6'),
            _buildOpBtn('-', activeColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadBtn('7'),
            _buildNumpadBtn('8'),
            _buildNumpadBtn('9'),
            _buildNumpadBtn('000'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildNumpadBtn('0'),
            _buildActionBtn('C', _clear),
            _buildActionBtn('⌫', _backspace),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.check_rounded, size: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadBtn(String val) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _appendInput(val),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                val,
                style: AppTypography.headline.copyWith(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpBtn(String op, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _appendInput(op),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                op,
                style: AppTypography.headline.copyWith(fontSize: 20, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
