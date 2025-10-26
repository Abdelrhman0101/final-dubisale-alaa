import 'dart:io';
import 'package:advertising_app/constant/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../providers/google_maps_provider.dart';
import '../providers/restaurant_details_provider.dart';
import '../providers/restaurants_info_provider.dart';

const Color KTextColor = Color.fromRGBO(0, 30, 91, 1);

class RestaurantsSaveAdScreen extends StatefulWidget {
  final String adId;
  
  const RestaurantsSaveAdScreen({Key? key, required this.adId}) : super(key: key);

  @override
  State<RestaurantsSaveAdScreen> createState() => _RestaurantsSaveAdScreenState();
}

class _RestaurantsSaveAdScreenState extends State<RestaurantsSaveAdScreen> {
  // Controllers for editable fields
  final TextEditingController _priceRangeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Contact info
  String? selectedPhoneNumber;
  String? selectedWhatsAppNumber;
  
  // Images
  File? _mainImage;
  List<File> _thumbnailImages = [];
  final ImagePicker _picker = ImagePicker();
  
  // Loading states
  bool _isLoading = false;
  bool _isUpdating = false;
  
  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  @override
  void dispose() {
    _priceRangeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantData() async {
    setState(() => _isLoading = true);
    
    try {
      final detailsProvider = context.read<RestaurantDetailsProvider>();
      final infoProvider = context.read<RestaurantsInfoProvider>();
      
      // Load restaurant details
      await detailsProvider.fetchAdDetails(int.parse(widget.adId));
      
      // Load contact info
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      if (token != null) {
        await infoProvider.fetchContactInfo(token: token);
      }
      
      // Populate editable fields with current data
      final ad = detailsProvider.adDetails;
      if (ad != null) {
        _priceRangeController.text = ad.priceRange ?? '';
        _descriptionController.text = ad.description ?? '';
        selectedPhoneNumber = ad.phoneNumber;
        selectedWhatsAppNumber = ad.whatsappNumber;
      }
    } catch (e) {
      debugPrint('Error loading restaurant data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickMainImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _mainImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking main image: $e');
    }
  }

  Future<void> _pickThumbnailImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _thumbnailImages.addAll(images.map((image) => File(image.path)));
          // Limit to 5 thumbnail images
          if (_thumbnailImages.length > 5) {
            _thumbnailImages = _thumbnailImages.take(5).toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking thumbnail images: $e');
    }
  }

  void _removeThumbnailImage(int index) {
    setState(() {
      _thumbnailImages.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (_isUpdating) return;
    
    setState(() => _isUpdating = true);
    
    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final detailsProvider = context.read<RestaurantDetailsProvider>();
      
      // Prepare update data
      final updateData = <String, dynamic>{};
      
      // Add changed fields
      final currentAd = detailsProvider.adDetails;
      if (currentAd != null) {
        if (_priceRangeController.text.trim() != (currentAd.priceRange ?? '')) {
          updateData['price_range'] = _priceRangeController.text.trim();
        }
        if (_descriptionController.text.trim() != (currentAd.description ?? '')) {
          updateData['description'] = _descriptionController.text.trim();
        }
        if (selectedPhoneNumber != currentAd.phoneNumber) {
          updateData['phone_number'] = selectedPhoneNumber;
        }
        if (selectedWhatsAppNumber != currentAd.whatsappNumber) {
          updateData['whatsapp_number'] = selectedWhatsAppNumber;
        }
      }
      
      // Add images if selected
      if (_mainImage != null) {
        updateData['main_image'] = _mainImage;
      }
      if (_thumbnailImages.isNotEmpty) {
        updateData['thumbnail_images'] = _thumbnailImages;
      }
      
      if (updateData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد تغييرات للحفظ')),
        );
        return;
      }
      
      // Update the restaurant ad
      await detailsProvider.updateRestaurantAd(
        adId: int.parse(widget.adId),
        priceRange: updateData['price_range'],
        description: updateData['description'],
        phoneNumber: updateData['phone_number'],
        whatsappNumber: updateData['whatsapp_number'],
        mainImage: updateData['main_image'],
        thumbnailImages: updateData['thumbnail_images'],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ التغييرات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final borderColor = const Color.fromRGBO(8, 194, 201, 1);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(s.edit),
        backgroundColor: Colors.white,
        foregroundColor: KTextColor,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer2<RestaurantDetailsProvider, RestaurantsInfoProvider>(
              builder: (context, detailsProvider, infoProvider, child) {
                final ad = detailsProvider.adDetails;
                
                if (ad == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'لم يتم العثور على الإعلان',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Read-only fields
                      _buildFormRow([
                        _buildDetailBox(s.emirate, ad.emirate ?? ''),
                        _buildDetailBox(s.district, ad.district ?? ''),
                      ]),
                      const SizedBox(height: 7),
                      
                      _buildFormRow([
                        _buildDetailBox(s.category, ad.category ?? ''),
                        _buildDetailBox(s.area, ad.area ?? ''),
                      ]),
                      const SizedBox(height: 7),
                      
                      // Editable price range field
                      _buildTitledTextFormField(
                        s.price,
                        _priceRangeController,
                        borderColor,
                        hintText: 'AED 50-100',
                        isRequired: true,
                      ),
                      const SizedBox(height: 7),
                      
                      // Read-only title field
                      _buildDetailBox(s.title, ad.title ?? ''),
                      const SizedBox(height: 7),
                      
                      // Read-only advertiser name
                      _buildDetailBox(s.advertiserName, ad.advertiserName ?? ''),
                      const SizedBox(height: 7),
                      
                      // Editable contact fields
                      _buildFormRow([
                        TitledSelectOrAddField(
                          title: s.phoneNumber,
                          value: selectedPhoneNumber,
                          items: infoProvider.phoneNumbers,
                          onChanged: (newValue) => setState(() => selectedPhoneNumber = newValue),
                          isNumeric: true,
                          onAddNew: (value) async {
                            final token = await const FlutterSecureStorage().read(key: 'auth_token');
                            if (token != null) {
                              final success = await infoProvider.addContactItem('phone_numbers', value, token: token);
                              if (success && mounted) {
                                setState(() => selectedPhoneNumber = value);
                              }
                            }
                          },
                        ),
                        TitledSelectOrAddField(
                          title: s.whatsApp,
                          value: selectedWhatsAppNumber,
                          items: infoProvider.whatsappNumbers,
                          onChanged: (newValue) => setState(() => selectedWhatsAppNumber = newValue),
                          isNumeric: true,
                          onAddNew: (value) async {
                            final token = await const FlutterSecureStorage().read(key: 'auth_token');
                            if (token != null) {
                              final success = await infoProvider.addContactItem('whatsapp_numbers', value, token: token);
                              if (success && mounted) {
                                setState(() => selectedWhatsAppNumber = value);
                              }
                            }
                          },
                        ),
                      ]),
                      const SizedBox(height: 7),
                      
                      // Editable description field
                      TitledDescriptionBox(
                        title: s.description,
                        controller: _descriptionController,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 10),
                      
                      // Image upload sections
                      _buildImageButton(
                        s.addMainImage,
                        Icons.add_a_photo_outlined,
                        borderColor,
                        onPressed: _pickMainImage,
                      ),
                      if (_mainImage != null) ...[
                        const SizedBox(height: 8),
                        _buildSelectedImage(_mainImage!, isMain: true),
                      ],
                      const SizedBox(height: 10),
                      
                      _buildImageButton(
                        s.add9Images,
                        Icons.add_photo_alternate_outlined,
                        borderColor,
                        onPressed: _pickThumbnailImages,
                      ),
                      if (_thumbnailImages.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildThumbnailImagesGrid(),
                      ],
                      const SizedBox(height: 10),
                      
                      // Map section
                      _buildMapSection(context, ad),
                      const SizedBox(height: 20),
                      
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: _isUpdating ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF01547E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  s.save,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Helper methods
  Widget _buildFormRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((child) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: child,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDetailBox(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: KTextColor,
            fontSize: 14.sp,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: value.isEmpty ? Colors.grey : KTextColor,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitledTextFormField(
    String title,
    TextEditingController controller,
    Color borderColor, {
    String? hintText,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: KTextColor,
                fontSize: 14.sp,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.sp,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: KTextColor,
            fontSize: 12.sp,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: KTextColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildImageButton(
    String title,
    IconData icon,
    Color borderColor, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: KTextColor),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: KTextColor,
            fontSize: 16.sp,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ));
    }

  Widget _buildSelectedImage(File image, {bool isMain = false}) {
    return Container(
      height: isMain ? 200.h : 120.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.file(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isMain) {
                    _mainImage = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _thumbnailImages.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  _thumbnailImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeThumbnailImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapSection(BuildContext context, dynamic ad) {
    final s = S.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.location,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: KTextColor,
          ),
        ),
        SizedBox(height: 4.h),
        
        // Location display
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/locationicon.svg',
                width: 20.w,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${ad.address  ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: KTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        
        // Map container
        SizedBox(
          height: 220.h,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    'assets/images/map.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 80.h,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.sp,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  label: Text(
                    s.locateMe,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement locate me functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01547E),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom widgets needed for the screen
class TitledSelectOrAddField extends StatefulWidget {
  final String title;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final bool isNumeric;
  final Function(String) onAddNew;

  const TitledSelectOrAddField({
    Key? key,
    required this.title,
    this.value,
    required this.items,
    required this.onChanged,
    this.isNumeric = false,
    required this.onAddNew,
  }) : super(key: key);

  @override
  State<TitledSelectOrAddField> createState() => _TitledSelectOrAddFieldState();
}

class _TitledSelectOrAddFieldState extends State<TitledSelectOrAddField> {
  late TextEditingController _controller;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableSelectOrAddBottomSheet(
        title: widget.title,
        items: widget.items,
        currentValue: widget.value,
        isNumeric: widget.isNumeric,
        onSelected: (value) {
          widget.onChanged(value);
          setState(() {
            _controller.text = value ?? '';
          });
        },
        onAddNew: widget.onAddNew,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: KTextColor,
            fontSize: 14.sp,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _showBottomSheet,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(8, 194, 201, 1)),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value?.isEmpty == true || widget.value == null
                        ? 'اختر ${widget.title}'
                        : widget.value!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: widget.value?.isEmpty == true || widget.value == null
                          ? Colors.grey
                          : KTextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: KTextColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchableSelectOrAddBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? currentValue;
  final bool isNumeric;
  final Function(String?) onSelected;
  final Function(String) onAddNew;

  const _SearchableSelectOrAddBottomSheet({
    Key? key,
    required this.title,
    required this.items,
    this.currentValue,
    required this.isNumeric,
    required this.onSelected,
    required this.onAddNew,
  }) : super(key: key);

  @override
  State<_SearchableSelectOrAddBottomSheet> createState() =>
      _SearchableSelectOrAddBottomSheetState();
}

class _SearchableSelectOrAddBottomSheetState
    extends State<_SearchableSelectOrAddBottomSheet> {
  late TextEditingController _searchController;
  List<String> _filteredItems = [];
  bool _isAddingNew = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      _filteredItems = widget.items
          .where((item) =>
              item.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _addNewItem() async {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() => _isAddingNew = true);
      try {
        await widget.onAddNew(_searchController.text.trim());
        widget.onSelected(_searchController.text.trim());
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إضافة العنصر: $e')),
        );
      } finally {
        setState(() => _isAddingNew = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'اختر ${widget.title}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: KTextColor,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: 'ابحث أو أضف جديد...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty &&
                        !widget.items.contains(_searchController.text.trim())
                    ? IconButton(
                        icon: _isAddingNew
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add),
                        onPressed: _isAddingNew ? null : _addNewItem,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color.fromRGBO(8, 194, 201, 1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color.fromRGBO(8, 194, 201, 1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: KTextColor, width: 2),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Items list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item == widget.currentValue;
                
                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? KTextColor : KTextColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: KTextColor)
                      : null,
                  onTap: () {
                    widget.onSelected(item);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TitledDescriptionBox extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color borderColor;
  final int maxLength;
  final String? hintText;

  const TitledDescriptionBox({
    Key? key,
    required this.title,
    required this.controller,
    required this.borderColor,
    this.maxLength = 5000,
    this.hintText,
  }) : super(key: key);

  @override
  State<TitledDescriptionBox> createState() => _TitledDescriptionBoxState();
}

class _TitledDescriptionBoxState extends State<TitledDescriptionBox> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: KTextColor,
            fontSize: 14.sp,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: widget.borderColor),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: widget.controller,
                maxLines: null,
                minLines: 3,
                maxLength: widget.maxLength,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: KTextColor,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  counterText: "",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '${widget.controller.text.length}/${widget.maxLength}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}