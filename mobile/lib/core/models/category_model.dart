import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double startingPrice;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.startingPrice,
  });

  static const List<ServiceCategory> defaultCategories = [
    ServiceCategory(
      id: 'plumbing',
      name: 'Su Tesisatı',
      description: 'Kaçak tespiti, musluk & batarya, sifon, gider açma',
      icon: Icons.water_drop_rounded,
      color: AppColors.primary,
      startingPrice: 450,
    ),
    ServiceCategory(
      id: 'electrical',
      name: 'Elektrik & Aydınlatma',
      description: 'Priz montajı, avize, sigorta arızası, hat çekimi',
      icon: Icons.bolt_rounded,
      color: AppColors.orange,
      startingPrice: 350,
    ),
    ServiceCategory(
      id: 'paint',
      name: 'Boya & Badana',
      description: 'Daire boyama, lokal alçı tamiri, tavan boyası',
      icon: Icons.format_paint_rounded,
      color: AppColors.emerald,
      startingPrice: 1200,
    ),
    ServiceCategory(
      id: 'carpentry',
      name: 'Montaj & Marangoz',
      description: 'Mobilya kurulumu, kapı ayarı, menteşe, dolap tamiri',
      icon: Icons.handyman_rounded,
      color: Color(0xFF8B5CF6),
      startingPrice: 400,
    ),
    ServiceCategory(
      id: 'cleaning',
      name: 'Temizlik & Hijyen',
      description: 'Tadilat sonrası detaylı temizlik, cam & balkon',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF06B6D4),
      startingPrice: 850,
    ),
    ServiceCategory(
      id: 'hvac',
      name: 'Klima & Kombi',
      description: 'Klima gaz dolumu, petek temizliği, bakım ve onarım',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFFEC4899),
      startingPrice: 600,
    ),
  ];
}
