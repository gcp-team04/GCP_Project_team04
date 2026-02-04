import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gcp_project_team_04/providers/estimate_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gcp_project_team_04/utils/consumer_design.dart';

class ChatListItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> room;
  final Estimate? estimate;
  final String title;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.room,
    this.estimate,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = room['lastMessage'] as String? ?? '';
    final imageUrl = estimate?.imageUrl;
    final damage = estimate?.damage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ConsumerColor.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (imageUrl != null)
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: ConsumerColor.slate100,
                        child: const Icon(
                          LucideIcons.image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(right: 16),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: ConsumerColor.slate100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.image,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ConsumerTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ConsumerColor.slate800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (damage != null)
                    Text(
                      damage,
                      style: ConsumerTypography.bodySmall.copyWith(
                        color: ConsumerColor.brand600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    lastMessage,
                    style: ConsumerTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
