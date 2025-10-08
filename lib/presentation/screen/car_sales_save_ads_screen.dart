import 'dart:io';
import 'package:advertising_app/data/model/car_ad_model.dart';
import 'package:advertising_app/presentation/providers/car_sales_ad_provider.dart';
import 'package:advertising_app/presentation/screen/car_rent_ads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:advertising_app/generated/l10n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// تعريف الثوابت المستخدمة في الألوان
const Color KTextColor = Color.fromRGBO(0, 30, 91, 1);
const Color KPrimaryColor = Color.fromRGBO(1, 84, 126, 1);
final Color KDisabledColor = Colors.white;
final Color KDisabledTextColor = Colors.grey.shade600;

class CarSalesSaveAdScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final int adId;

  const CarSalesSaveAdScreen({
    Key? key,
    required this.onLanguageChange,
    required this.adId,
  }) : super(key: key);

  @override
  State<CarSalesSaveAdScreen> createState() => _CarSalesSaveAdScreenState();
}

class _CarSalesSaveAdScreenState extends State<CarSalesSaveAdScreen> {
  // --- Controllers & Variables for EDITABLE fields ---
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedPhoneNumber;
  String? selectedWhatsAppNumber;
  
  // متغيرات لحفظ الصور الجديدة التي يختارها المستخدم
  File? _mainImageFile;
  final List<File> _thumbnailImageFiles = [];
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    // جلب بيانات الإعلان وملء الحقول بمجرد فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarAdProvider>(context, listen: false)
          .fetchAdDetails(widget.adId)
          .then((_) {
        // نستخدم listen: false لأننا في initState
        final provider = Provider.of<CarAdProvider>(context, listen: false);
        if (provider.adDetails != null) {
          _populateFields(provider.adDetails!);
        }
      });
    });
  }
  
  // دالة لملء الـ controllers والمتغيرات بالبيانات التي تم جلبها
  void _populateFields(CarAdModel ad) {
    if (mounted) { // للتأكد من أن الـ widget مازال موجوداً
      setState(() {
        _priceController.text = ad.price;
        _descriptionController.text = ad.description;
        selectedPhoneNumber = ad.phoneNumber;
        selectedWhatsAppNumber = ad.whatsapp;
      });
    }
  }

  // --- دوال للتعامل مع الأحداث (الحفظ واختيار الصور) ---
  
  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _mainImageFile = File(image.path));
    }
  }

  Future<void> _pickThumbnailImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _thumbnailImageFiles.clear(); // مسح الصور القديمة قبل إضافة الجديدة
        _thumbnailImageFiles.addAll(images.map((xfile) => File(xfile.path)));
      });
    }
  }

  void _onSaveChanges() async {
      final provider = Provider.of<CarAdProvider>(context, listen: false);
      
      // Create the update data map
      Map<String, dynamic> updateData = {
        'price': _priceController.text,
        'description': _descriptionController.text,
        'phoneNumber': selectedPhoneNumber ?? '',
        'whatsapp': selectedWhatsAppNumber,
      };
      
      // Add images if they exist
      if (_mainImageFile != null) {
        updateData['mainImage'] = _mainImageFile;
      }
      if (_thumbnailImageFiles.isNotEmpty) {
        updateData['thumbnailImages'] = _thumbnailImageFiles;
      }
      
      bool success = await provider.updateAd(updateData, widget.adId.toString());

      if (mounted) {
          if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح'), backgroundColor: Colors.green));
              context.pop(); // العودة للشاشة السابقة
          } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: ${provider.updateAdError}'), backgroundColor: Colors.red));
          }
      }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم Provider للاستماع لحالة التحميل أو الخطأ
    final provider = context.watch<CarAdProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: provider.isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : provider.detailsError != null
              ? Center(child: Text('حدث خطأ أثناء جلب البيانات: ${provider.detailsError}'))
              : provider.adDetails == null
                  ? const Center(child: Text('لم يتم العثور على الإعلان.'))
                  : _buildFormUI(provider.adDetails!), // بناء الواجهة بعد جلب البيانات
    );
  }
  
  // هذه الدالة تحتوي على كل الواجهة الخاصة بك مع آلية لمنع الشاشة البيضاء
  Widget _buildFormUI(CarAdModel ad) {
    try {
      final s = S.of(context);
      final currentLocale = Localizations.localeOf(context).languageCode;
      final Color borderColor = Color.fromRGBO(8, 194, 201, 1);
      
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),
              GestureDetector(
                onTap: () => context.pop(),
                child: Row(children: [ const SizedBox(width: 5), Icon(Icons.arrow_back_ios, color: KTextColor, size: 20.sp), Transform.translate(offset: Offset(-3.w, 0), child: Text(s.back, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: KTextColor))), ],),
              ),
              SizedBox(height: 7.h),
              Center(child: Text(s.appTitle, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24.sp, color: KTextColor))),
              SizedBox(height: 8.h),
              
              // عرض البيانات من الإعلان الذي تم جلبه
              _buildReadOnlyField(s.make, ad.make),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.model, ad.model), _buildReadOnlyField(s.trim, ad.trim ?? 'N/A'), ]),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.year, ad.year), _buildReadOnlyField(s.km, ad.km), ]),
              const SizedBox(height: 7),
              _buildEditableTextField(s.price, 'AED', _priceController, borderColor, currentLocale, isNumber: true),
              const SizedBox(height: 7),
              _buildReadOnlyField(s.specs, ad.specs ?? 'N/A'),
              const SizedBox(height: 7),
              _buildTitleBox(context, s.title, ad.title, borderColor, currentLocale),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.carType, ad.carType ?? 'N/A'), _buildReadOnlyField(s.transType, ad.transType), _buildReadOnlyField(s.fuelType, ad.fuelType ?? 'N/A'),]),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.color, ad.color ?? 'N/A'), _buildReadOnlyField(s.interiorColor, ad.interiorColor ?? 'N/A'), _buildReadOnlyField(s.warranty, ad.warranty ? 'Yes' : 'No'),]),
              const SizedBox(height: 15),
              _buildFormRow([ _buildReadOnlyField(s.engineCapacity, ad.engineCapacity ?? 'N/A', titleFontSize: 12.5), _buildReadOnlyField(s.cylinders, ad.cylinders ?? 'N/A'), _buildReadOnlyField(s.horse_power, ad.horsepower ?? 'N/A'),]),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.doorsNo, ad.doorsNo ?? 'N/A'), _buildReadOnlyField(s.seatsNo, ad.seatsNo ?? 'N/A'), _buildReadOnlyField(s.steeringSide, ad.steeringSide ?? 'N/A'),]),
              const SizedBox(height: 7),
              _buildReadOnlyField(s.advertiserName, ad.advertiserName),
              const SizedBox(height: 7),
              _buildFormRow([
                  TitledSelectOrAddField( title: s.phoneNumber, value: selectedPhoneNumber, items: [ad.phoneNumber, '00971501111111'], onChanged: (newValue) => setState(() => selectedPhoneNumber = newValue), isNumeric: true),
                  TitledSelectOrAddField( title: s.whatsApp, value: selectedWhatsAppNumber, items: [ad.whatsapp ?? '', '00971502222222'], onChanged: (newValue) => setState(() => selectedWhatsAppNumber = newValue), isNumeric: true),
              ]),
              const SizedBox(height: 7),
              _buildFormRow([ _buildReadOnlyField(s.emirate, ad.emirate), _buildReadOnlyField(s.advertiserType, ad.advertiserType), ]),
              const SizedBox(height: 7),
              _buildReadOnlyField(s.area, ad.area ?? 'N/A'),
              const SizedBox(height: 7),
              TitledDescriptionBox(title: s.describeYourCar, controller: _descriptionController, borderColor: borderColor),
              const SizedBox(height: 10),
              
              // التعامل مع الصور
              _buildImageButton(s.addMainImage, Icons.add_a_photo_outlined, borderColor, onPressed: _pickMainImage),
              if(_mainImageFile != null) ...[const SizedBox(height: 4), Text('  تم اختيار صورة رئيسية جديدة', style: TextStyle(color: Colors.green))],
              const SizedBox(height: 7),
              _buildImageButton(s.add14Images, Icons.add_photo_alternate_outlined, borderColor, onPressed: _pickThumbnailImages),
              if(_thumbnailImageFiles.isNotEmpty) ...[const SizedBox(height: 4), Text('  تم اختيار ${_thumbnailImageFiles.length} صورة مصغرة جديدة', style: TextStyle(color: Colors.green))],
              const SizedBox(height: 10),

              // باقي الواجهة
              Text(s.location, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp, color: KTextColor)),
              SizedBox(height: 4.h),
              Directionality(textDirection: TextDirection.ltr, child: Row(children: [ SvgPicture.asset('assets/icons/locationicon.svg', width: 20.w, height: 20.h), SizedBox(width: 8.w), Expanded(child: Text('Dubai souq alharaj', style: TextStyle(fontSize: 14.sp, color: KTextColor, fontWeight: FontWeight.w500))),],),),
              SizedBox(height: 8.h),
              _buildMapSection(context),
              const SizedBox(height: 10),
              
              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: Consumer<CarAdProvider>(
                    builder: (context, provider, child){
                      return ElevatedButton(
                        onPressed: provider.isUpdatingAd ? null : _onSaveChanges,
                        child: provider.isUpdatingAd 
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                            : Text(s.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      // إذا حدث أي خطأ أثناء بناء الواجهة، سنعرض شاشة خطأ بدلاً من شاشة بيضاء
      print('----------- UI RENDER ERROR CAUGHT -----------');
      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');
      return Container(
        color: Colors.red.withOpacity(0.1),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('UI Render Error:\n\n$e\n\n$stackTrace',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textDirection: TextDirection.ltr,
          ),
        ),
      );
    }
  }

  // --- دوال المساعدة ---
   Widget _buildFormRow(List<Widget> children) { return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((child) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0), child: child))).toList()); }
   Widget _buildEditableTextField(String title, String hintText, TextEditingController controller, Color borderColor, String currentLocale, {bool isNumber = false}) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: KTextColor, fontSize: 14.sp)), const SizedBox(height: 4), SizedBox(height: 48, child: TextFormField(controller: controller, style: TextStyle(fontWeight: FontWeight.w500, color: KTextColor, fontSize: 12.sp), textAlign: currentLocale == 'ar' ? TextAlign.right : TextAlign.left, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: Colors.grey.shade400), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: KPrimaryColor, width: 2)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), fillColor: Colors.white, filled: true)),) ]); }
   Widget _buildReadOnlyField(String title, String value, {double? titleFontSize}) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: KTextColor, fontSize: titleFontSize ?? 14.sp)), const SizedBox(height: 4), Container(height: 48, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.centerLeft, decoration: BoxDecoration(color: KDisabledColor, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: KDisabledTextColor, fontSize: 12.sp), overflow: TextOverflow.ellipsis, maxLines: 1))]); }
   Widget _buildTitleBox(BuildContext context, String title, String initialValue, Color borderColor, String currentLocale) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: KTextColor, fontSize: 14.sp)), const SizedBox(height: 4), TextFormField(initialValue: initialValue, readOnly: true, style: TextStyle(fontWeight: FontWeight.w500, color: KDisabledTextColor, fontSize: 14.sp), decoration: InputDecoration(filled: true, fillColor: KDisabledColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade400)), contentPadding: const EdgeInsets.all(12)))]); }
   Widget _buildImageButton(String title, IconData icon, Color borderColor, {required VoidCallback onPressed}) { return SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: Icon(icon, color: KTextColor), label: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: KTextColor, fontSize: 16.sp)), onPressed: onPressed, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))))); }
   Widget _buildMapSection(BuildContext context) { return SizedBox(height: 320.h, width: double.infinity, child: Stack(children: [ Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/map.png', fit: BoxFit.cover))), Positioned(top: 180, left: 30, right: 30, child: const Icon(Icons.location_pin, color: Colors.red, size: 40)), Positioned(bottom: 10, left: 10, right: 155, child: ElevatedButton.icon(icon: const Icon(Icons.location_on_outlined, color: Colors.white, size: 26), label: Text(S.of(context).locateMe, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)), onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: KPrimaryColor, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))) ],),); }

}



class TitledDescriptionBox extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final Color borderColor;
  final int maxLength;
  const TitledDescriptionBox({Key? key, required this.title, required this.controller, required this.borderColor, this.maxLength = 5000}) : super(key: key);
  @override
  State<TitledDescriptionBox> createState() => _TitledDescriptionBoxState();
}
class _TitledDescriptionBoxState extends State<TitledDescriptionBox> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if(mounted){
         setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: TextStyle(fontWeight: FontWeight.w600, color: KTextColor, fontSize: 14.sp)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: widget.borderColor)),
          child: Column(
            children: [
              TextFormField(
                controller: widget.controller,
                maxLines: null,
                maxLength: widget.maxLength,
                style: TextStyle(fontWeight: FontWeight.w500, color: KTextColor, fontSize: 14.sp),
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(12), counterText: ""),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text('${widget.controller.text.length}/${widget.maxLength}', style: const TextStyle(color: Colors.grey, fontSize: 12), textDirection: TextDirection.ltr)),
              )
            ],
          ),
        ),
      ],
    );
  }
}