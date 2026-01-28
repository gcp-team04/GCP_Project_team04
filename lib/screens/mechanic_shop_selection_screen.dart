import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/service_center_service.dart';
import '../models/service_center.dart';
import '../models/app_user.dart';
import '../widgets/custom_search_bar.dart';

class MechanicShopSelectionScreen extends StatefulWidget {
  const MechanicShopSelectionScreen({super.key});

  @override
  State<MechanicShopSelectionScreen> createState() =>
      _MechanicShopSelectionScreenState();
}

class _MechanicShopSelectionScreenState
    extends State<MechanicShopSelectionScreen> {
  List<ServiceCenter> _searchResults = [];
  bool _isSearching = false;
  String? _selectedShopId;

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final service = Provider.of<ServiceCenterService>(context, listen: false);
      final docs = await service.searchServiceCenters(query);

      setState(() {
        _searchResults = docs
            .map(
              (doc) => ServiceCenter.fromGeoDocument(
                doc as DocumentSnapshot<Map<String, dynamic>>,
                0.0,
              ),
            )
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedShopId == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user != null) {
      await authService.updateUserRole(
        user.uid,
        UserRole.mechanic,
        serviceCenterId: _selectedShopId,
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '정비소 선택',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '소속된 정비소를 검색하여 선택해주세요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomSearchBar(onSubmitted: _handleSearch),
            const SizedBox(height: 20),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.search,
                            size: 48,
                            color: theme.dividerColor,
                          ),
                          const SizedBox(height: 16),
                          const Text('정비소를 검색해보세요.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final shop = _searchResults[index];
                        final isSelected = _selectedShopId == shop.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blueAccent
                                  : theme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected
                                ? Colors.blueAccent.withOpacity(0.05)
                                : theme.cardColor,
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                _selectedShopId = shop.id;
                              });
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.home,
                                color: Colors.blueAccent,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              shop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(shop.address),
                            trailing: isSelected
                                ? const Icon(
                                    LucideIcons.checkCircle,
                                    color: Colors.blueAccent,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedShopId != null ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: theme.dividerColor,
              ),
              child: const Text(
                '선택 완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
