import 'package:advertising_app/data/model/favorite_item_interface_model.dart';
import 'ad_priority.dart';

class RealEstateModel implements FavoriteItemInterface {

  @override
  String get id => title;
  final String title;
  final String price;
  final String image;
  final String details;
  final String contact;
  final String location;
  final String date;
  final bool isPremium;
  final List<String> _images;
  final AdPriority priority;
  final String? emirate;
  final String? district;
  final String? area;
  
  final String? propertyType;
  final String? contractType;


  RealEstateModel(this.emirate, this.district, this.area, this.propertyType, this.contractType, {
    required this.title,
    required this.contact,
    required this.price,
    required this.image,
    required this.location,
    required this.date,
    required this.details,
    required this.isPremium,
    required List<String> images, 
    required this.priority,
  }) : _images = images;


  @override
  String get line1 => "";



@override
  List<String> get images => _images; 
}
