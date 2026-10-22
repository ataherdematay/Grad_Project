import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 19: Usta ile Mesajlaşma (SCR-07)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S19InAppChatScreen extends StatefulWidget {
  const S19InAppChatScreen({super.key});

  @override
  State<S19InAppChatScreen> createState() => _S19InAppChatScreenState();
}

class _S19InAppChatScreenState extends State<S19InAppChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Merhaba Ata Bey, randevunuzu onayladım. Yarın 14:00’te Kadıköy’deki adresinizde olacağım. Arızalı vananın veya borunun fotoğrafı varsa buradan gönderebilirsiniz.',
      'time': '15:32',
    },
    {
      'isMe': true,
      'text': 'Merhaba usta, teşekkürler. Lavabonun altındaki sızdıran vananın fotoğrafını yüklüyorum.',
      'time': '15:35',
    },
    {
      'isMe': true,
      'isImage': true,
      'imageName': 'banyo_vana_hasar.jpg',
      'time': '15:35',
    },
    {
      'isMe': false,
      'text': 'Fotoğrafı inceledim, uygun pirinç vana ve yedek contalarla geleceğim. Görüşmek üzere.',
      'time': '15:38',
    },
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'text': text,
        'time': '15:40',
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/18');
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: const Text('MH', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Mavi Hat Tesisat',
                          style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 15, color: AppColors.emerald),
                    ],
                  ),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('Çevrimiçi', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.more_vert, color: AppColors.textSecondary),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Pinned Job Context Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.build, size: 16, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Randevu: ',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                            children: const [
                              TextSpan(text: 'Yarın 14:00 – 16:00', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF1E9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Acil Onarım', style: AppTypography.labelSm.copyWith(color: AppColors.secondary, fontSize: 10)),
                            ),
                            const SizedBox(width: 4),
                            Text('Tesisat', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => context.push('/step/18'),
                  child: Row(
                    children: [
                      Text('İş Detayı', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message Stream
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Date separator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDisabled,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text('Bugün', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                  ),
                ),

                // In-chat Security Notice Card
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC4DEEB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security, size: 18, color: AppColors.primaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Güvenliğiniz için iletişimi BiTadilat üzerinden sürdürün. Telefon numarası veya IBAN paylaşmayın.',
                          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),

                // Render dynamic messages
                ..._messages.map((msg) {
                  final isMe = msg['isMe'] == true;
                  final isImage = msg['isImage'] == true;

                  if (isImage) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 240,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topRight: Radius.circular(4),
                          ),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDisabled,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.water_damage, size: 48, color: AppColors.primaryContainer),
                                  SizedBox(height: 4),
                                  Text('Banyo Vana Hasarı', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.image, size: 14, color: AppColors.primaryContainer),
                                    const SizedBox(width: 4),
                                    Text(msg['imageName'] ?? 'foto.jpg', style: AppTypography.labelSm.copyWith(color: AppColors.onSurface)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(msg['time'] ?? '', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.done_all, size: 14, color: AppColors.emerald),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primaryContainer : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        border: isMe ? null : Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text'] ?? '',
                            style: AppTypography.bodyMd.copyWith(color: isMe ? Colors.white : AppColors.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                msg['time'] ?? '',
                                style: AppTypography.labelSm.copyWith(
                                  color: isMe ? Colors.white70 : AppColors.textSecondary,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all, size: 14, color: Colors.white70),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: AppColors.primaryContainer),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Mesajınızı yazın...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_camera, size: 20, color: AppColors.textSecondary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
