import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicines_for_children_flutter/core/domain/active_child_provider.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/core/platform/image_provider.dart';

class MedicineDetailPage extends ConsumerWidget {
  const MedicineDetailPage({super.key, required this.medicineId});

  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medicine')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No child profile available.'),
        ),
      );
    }

    if (child.medicines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medicine')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No medicines have been added yet.'),
        ),
      );
    }

    final medicine = child.medicines.firstWhere(
      (item) => item.id == medicineId,
      orElse: () => child.medicines.first,
    );

    final photos = _resolvePhotos(medicine);

    return Scaffold(
      appBar: AppBar(title: Text(medicine.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MedicinePhotoGallery(photos: photos),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Overview',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.alias.isNotEmpty ? medicine.alias : 'No alias provided',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: _typeLabel(medicine.type)),
                      _InfoChip(label: medicine.route),
                      _InfoChip(label: medicine.frequency),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Dose',
              child: Text('${medicine.dose} ${medicine.doseUnit}'),
            ),
            if (medicine.notes != null && medicine.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Notes',
                child: Text(medicine.notes!),
              ),
            ],
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Last updated',
              child: Text(DateFormat.yMMMd().format(DateTime.now())),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolvePhotos(Medicine medicine) {
    if (medicine.photoUrls.isNotEmpty) {
      return medicine.photoUrls;
    }
    if (medicine.photoUrl != null && medicine.photoUrl!.trim().isNotEmpty) {
      return [medicine.photoUrl!];
    }
    return const [];
  }

  String _typeLabel(MedicineType type) {
    switch (type) {
      case MedicineType.everyday:
        return 'Everyday medicine';
      case MedicineType.asNeeded:
        return 'As-needed medicine';
      case MedicineType.both:
        return 'Everyday + as-needed';
    }
  }
}

class MedicinePhotoGallery extends StatefulWidget {
  const MedicinePhotoGallery({super.key, required this.photos});

  final List<String> photos;

  @override
  State<MedicinePhotoGallery> createState() => _MedicinePhotoGalleryState();
}

class _MedicinePhotoGalleryState extends State<MedicinePhotoGallery> {
  late final PageController _controller;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return _EmptyPhotoCard();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() {
                _activeIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              final provider = createImageProvider(photo);
              return Card(
                clipBehavior: Clip.antiAlias,
                child: provider == null
                    ? _EmptyPhotoCard()
                    : Image(
                        image: provider,
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.photos.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _activeIndex == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _activeIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPhotoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Icon(
            Icons.photo_camera_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
