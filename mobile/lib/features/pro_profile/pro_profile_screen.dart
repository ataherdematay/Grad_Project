import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/auth_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ProProfileScreen extends StatelessWidget {
  const ProProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Usta Profilim & Hak Ediş'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Pro Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ahmet Yılmaz', style: AppTypography.h3),
                        Text('Mavi Hat Su Tesisatı (14 Yıl)',
                            style: AppTypography.bodySmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 18, color: AppColors.amber),
                            const SizedBox(width: 4),
                            Text('4.9 (248 Tamamlanan İş)',
                                style: AppTypography.bodySmall
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Role Switch to Customer Mode
            InkWell(
              onTap: () {
                context.read<AuthBloc>().add(const SwitchRoleEvent());
                context.go('/customer/home');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Müşteri Moduna Geç',
                              style: AppTypography.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                          Text(
                            'Evinde veya işyerinde tadilat için usta çağır',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Verifications Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doğrulanmış Rozetlerim', style: AppTypography.h4),
                  const SizedBox(height: 12),
                  _BadgeTile(
                    title: 'T.C. Kimlik Onaylı',
                    desc: 'Nüfus ve Vatandaşlık İşleri kontrolü yapıldı',
                  ),
                  const SizedBox(height: 8),
                  _BadgeTile(
                    title: 'Adli Sicil Kaydı Temiz',
                    desc: 'e-Devlet adli sicil belgesi onaylandı',
                  ),
                  const SizedBox(height: 8),
                  _BadgeTile(
                    title: '12 Ay Garanti Taahhüdü',
                    desc: 'BiTadilat kurumsal garanti sözleşmesi imzalandı',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bank details
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kayıtlı IBAN Bilgisi (Hak Ediş)',
                      style: AppTypography.h4),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Yapı Kredi Bankası\nTR34 0006 7010 0000 0098 2311 44',
                          style: AppTypography.bodySmall
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              tileColor: AppColors.surface,
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Çıkış Yap',
                  style: AppTypography.h4.copyWith(color: AppColors.error)),
              onTap: () {
                context.read<AuthBloc>().add(const LogoutEvent());
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String title;
  final String desc;

  const _BadgeTile({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.verified_rounded, size: 20, color: AppColors.emerald),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.bodySmall
                      .copyWith(fontWeight: FontWeight.w700)),
              Text(desc, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
