import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/default_categories.dart';
import '../../core/database/db_helper.dart';
import '../../models/transaction_model.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _amount = '18.50';
  String _note = 'Coffee & Snacks';
  int _selectedCategoryIndex = 0;

    final List<Map<String, dynamic>> _categories = DefaultCategories.expenseCategories
        .map((c) => {
          'id': c.id,
          'label': c.name,
          'icon': c.icon,
          'color': c.color,
          'bgColor': const Color(0xFFFFDED4), // placeholder pastel background
        })
        .toList();

  void _onKeyPress(String val) {
    setState(() {
      if (val == 'C') {
        _amount = '0';
      } else if (val == 'DEL') {
        if (_amount.isNotEmpty && _amount != '0') {
          _amount = _amount.substring(0, _amount.length - 1);
          if (_amount.isEmpty) _amount = '0';
        }
      } else if (val == '.') {
        if (!_amount.contains('.')) {
          _amount = '$_amount.';
        }
      } else if (val == '00') {
        if (_amount != '0') {
          _amount = '$_amount 00'.replaceAll(' ', '');
        }
      } else {
        if (_amount == '0') {
          _amount = val;
        } else {
          _amount = '$_amount$val';
        }
      }
    });
  }

    /// Save the transaction to SQLite and close the screen.
  Future<void> _saveTransaction() async {
    // Basic validation
    if (_amount.isEmpty || _amount == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah uang')),
      );
      return;
    }

    // Resolve selected category id (fallback if missing)
    final selectedCat = _categories[_selectedCategoryIndex];
    final catId = selectedCat['id'] as String? ?? 'cat_unknown';

    // Build TransactionModel
    final tx = TransactionModel(
      title: _note,
      amount: double.parse(_amount.replaceAll(',', '')),
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      categoryId: catId,
      date: DateTime.now(),
      note: _note,
    );

    await DbHelper.instance.insertTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi tersimpan')),
    );
    Navigator.pop(context, true); // return true to signal refresh
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE2CFC2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.onSurface,
                size: 22,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Add Transaction',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Date Selector Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2EB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2CFC2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF8E4C3B),
                ),
                SizedBox(width: 4),
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Profile Avatar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFD4EFE1),
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Color(0xFFFFDED4),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Color(0xFF8E4C3B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expense / Income Segment Switcher
                    _buildTypeSegmentSwitcher(),
                    const SizedBox(height: 12),

                    // Amount & Note Card
                    _buildAmountCard(),
                    const SizedBox(height: 16),

                    // Category Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                        Text(
                          'Horizontal scroll',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8E9A92),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Categories Horizontal Scroll List
                    _buildCategoryChips(),
                  ],
                ),
              ),
            ),

            // Bottom Numeric Keypad
            _buildNumericKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSegmentSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _isExpense ? const Color(0xFFFFDED4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8E4C3B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isExpense ? FontWeight.w700 : FontWeight.w500,
                        color: _isExpense ? const Color(0xFF8E4C3B) : const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Income Button
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isExpense = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: !_isExpense ? const Color(0xFFD4EFE1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF006C49),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !_isExpense ? FontWeight.w700 : FontWeight.w500,
                        color: !_isExpense ? const Color(0xFF006C49) : const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Header: EXPENSE AMOUNT + Wallet Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isExpense ? const Color(0xFF8E4C3B) : const Color(0xFF006C49),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isExpense ? 'EXPENSE AMOUNT' : 'INCOME AMOUNT',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: _isExpense ? const Color(0xFF8E4C3B) : const Color(0xFF006C49),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDD6FE), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 13,
                      color: Color(0xFF59579A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Wallet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF59579A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Amount Row with blinking green cursor
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                r'$ ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF006C49),
                ),
              ),
              Text(
                _amount,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 2.5,
                height: 28,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF006C49),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Note / Description Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2CFC2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  size: 18,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _note,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFDED4) : const Color(0xFFFAF1E8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF0C8BC) : const Color(0xFFF0DDD0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: cat['color'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF8E4C3B) : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2EB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 1, 2, 3, DEL
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildActionKey(
                icon: Icons.backspace_outlined,
                iconColor: const Color(0xFFBD382B),
                bgColor: const Color(0xFFFFD4DF),
                onTap: () => _onKeyPress('DEL'),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: 4, 5, 6, C
          Row(
            children: [
              _buildKey('4'),
              _buildKey('5'),
              _buildKey('6'),
              _buildKey('C', isAction: true),
            ],
          ),
          const SizedBox(height: 6),

          // Row 3 & 4: 7, 8, 9, 0, ., 00 + Tall Save Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left 3 columns
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Row 3 (7, 8, 9)
                    Row(
                      children: [
                        _buildKey('7'),
                        _buildKey('8'),
                        _buildKey('9'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Row 4 (., 0, 00)
                    Row(
                      children: [
                        _buildKey('.'),
                        _buildKey('0'),
                        _buildKey('00'),
                      ],
                    ),
                  ],
                ),
              ),

              // Right column: Tall Save Button
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: GestureDetector(
                    onTap: () async {
                      await _saveTransaction();
                    },
                    child: Container(
                      height: 98,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00583A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00583A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, {bool isAction = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: InkWell(
          onTap: () => _onKeyPress(label),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF1E8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF0DDD0),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isAction ? const Color(0xFF8E4C3B) : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF3C6CF),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
