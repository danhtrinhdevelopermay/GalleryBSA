import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import '../models/vehicle.dart';
import '../services/database_service.dart';
import 'edit_vehicle_screen.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Vehicle _vehicle;
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'in-use':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      case 'sold':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'in-use':
        return 'In Use';
      case 'maintenance':
        return 'Maintenance';
      case 'sold':
        return 'Sold';
      default:
        return status;
    }
  }

  void _showMediaGallery(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaGalleryScreen(
          mediaFiles: _vehicle.mediaFiles,
          initialIndex: initialIndex,
          vehicleName: _vehicle.displayName,
        ),
      ),
    );
  }

  void _editVehicle() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EditVehicleScreen(vehicle: _vehicle),
      ),
    ).then((updatedVehicle) {
      if (updatedVehicle != null) {
        setState(() {
          _vehicle = updatedVehicle;
        });
      }
    });
  }

  void _deleteVehicle() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${_vehicle.displayName}?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await _databaseService.deleteVehicle(_vehicle.id!);
                if (mounted) {
                  Navigator.pop(context); // Go back to previous screen
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting vehicle: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Media Gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            leading: CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                onPressed: _editVehicle,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _vehicle.hasMedia
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemCount: _vehicle.mediaFiles.length,
                          itemBuilder: (context, index) {
                            final mediaFile = _vehicle.mediaFiles[index];
                            final isVideo = _vehicle.videoFiles.contains(mediaFile);
                            
                            return GestureDetector(
                              onTap: () => _showMediaGallery(index),
                              child: isVideo
                                  ? VideoThumbnail(videoUrl: mediaFile)
                                  : CachedNetworkImage(
                                      imageUrl: mediaFile,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: CupertinoActivityIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: Icon(
                                            CupertinoIcons.photo,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                        
                        // Media indicators
                        if (_vehicle.mediaFiles.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _vehicle.mediaFiles.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.car_detailed,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          // Vehicle Information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vehicle.displayName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_vehicle.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getStatusDisplayName(_vehicle.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_vehicle.price != null)
                        Text(
                          '\$${_vehicle.price!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Vehicle Details
                  _buildDetailSection('Vehicle Information', [
                    _buildDetailRow('License Plate', _vehicle.licensePlate),
                    if (_vehicle.vin != null)
                      _buildDetailRow('VIN', _vehicle.vin!),
                    if (_vehicle.mileage != null)
                      _buildDetailRow('Mileage', '${_vehicle.mileage!.toStringAsFixed(0)} miles'),
                    _buildDetailRow('Year', _vehicle.year.toString()),
                    _buildDetailRow('Make', _vehicle.make),
                    _buildDetailRow('Model', _vehicle.model),
                  ]),

                  const SizedBox(height: 32),

                  // Media Information
                  if (_vehicle.hasMedia)
                    _buildDetailSection('Media', [
                      _buildDetailRow('Total Files', _vehicle.mediaFiles.length.toString()),
                      _buildDetailRow('Images', _vehicle.imageFiles.length.toString()),
                      _buildDetailRow('Videos', _vehicle.videoFiles.length.toString()),
                    ]),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton.filled(
                          onPressed: _editVehicle,
                          child: const Text('Edit Vehicle'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CupertinoButton(
                        color: Colors.red,
                        onPressed: _deleteVehicle,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnail({super.key, required this.videoUrl});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_controller != null && _controller!.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          )
        else
          Container(
            color: Colors.grey[800],
            child: const Center(
              child: CupertinoActivityIndicator(color: Colors.white),
            ),
          ),
        
        const Center(
          child: Icon(
            CupertinoIcons.play_circle_fill,
            size: 50,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class MediaGalleryScreen extends StatelessWidget {
  final List<String> mediaFiles;
  final int initialIndex;
  final String vehicleName;

  const MediaGalleryScreen({
    super.key,
    required this.mediaFiles,
    required this.initialIndex,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.xmark,
            color: Colors.white,
          ),
        ),
        title: Text(
          vehicleName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final mediaFile = mediaFiles[index];
          final isVideo = mediaFile.toLowerCase().contains('.mp4') ||
                          mediaFile.toLowerCase().contains('.mov');

          if (isVideo) {
            return PhotoViewGalleryPageOptions.customChild(
              child: VideoGalleryItem(videoUrl: mediaFile),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else {
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(mediaFile),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }
        },
        itemCount: mediaFiles.length,
        loadingBuilder: (context, event) => const Center(
          child: CupertinoActivityIndicator(color: Colors.white),
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}

class VideoGalleryItem extends StatefulWidget {
  final String videoUrl;

  const VideoGalleryItem({super.key, required this.videoUrl});

  @override
  State<VideoGalleryItem> createState() => _VideoGalleryItemState();
}

class _VideoGalleryItemState extends State<VideoGalleryItem> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller != null && _controller!.value.isInitialized
          ? GestureDetector(
              onTap: _togglePlayPause,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  if (!_isPlaying)
                    const Icon(
                      CupertinoIcons.play_circle_fill,
                      size: 80,
                      color: Colors.white70,
                    ),
                ],
              ),
            )
          : const CupertinoActivityIndicator(color: Colors.white),
    );
  }
}