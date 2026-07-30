import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models.dart';
import '../api_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<CategoryModel> _categories = [];
  List<ServiceModel> _services = [];
  bool _loading = true;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    // Load categories only once
    if (_categories.isEmpty) {
      _categories = await ApiService.getCategories();
    }
    
    _services = await ApiService.getServices(categoryId: _selectedCategoryId);
    
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(kColorBg),
        appBar: AppBar(
          title: Text('خدماتنا', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildCategoryFilters(),
            Expanded(
              child: _loading 
                  ? const Center(child: CircularProgressIndicator(color: Color(kColorPrimary)))
                  : _buildServicesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final isSelected = isAll ? _selectedCategoryId == null : _selectedCategoryId == _categories[index - 1].categoryId;
          
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(
                isAll ? 'الكل' : '${_categories[index - 1].iconName} ${_categories[index - 1].nameAr}',
                style: GoogleFonts.cairo(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(kColorSecondary),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(kColorPrimary),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? const Color(kColorPrimary) : const Color(kColorBorder)),
              ),
              onSelected: (selected) {
                if (selected) _onCategorySelected(isAll ? null : _categories[index - 1].categoryId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    if (_services.isEmpty) {
      return Center(
        child: Text('لا توجد خدمات في هذا التصنيف حالياً.', style: GoogleFonts.cairo(color: const Color(kColorTextLight))),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/service_detail', arguments: service);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(kColorBg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(kColorBorder)),
                    ),
                    child: const Center(child: Text('❄️', style: TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.nameAr,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(kColorSecondary)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.shortDescriptionAr,
                          style: GoogleFonts.cairo(fontSize: 13, color: const Color(kColorTextLight)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${service.basePriceSar} ريال / ${service.priceUnit}',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(kColorPrimary)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(kColorBg),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ضمان ${service.warrantyDays} يوم',
                                style: GoogleFonts.cairo(fontSize: 10, color: const Color(kColorSecondary), fontWeight: FontWeight.w600),
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
          ),
        );
      },
    );
  }
}
