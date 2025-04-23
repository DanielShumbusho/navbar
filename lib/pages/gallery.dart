import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        setState(() {
          _error = "Gallery access denied";
          _isLoading = false;
        });
        return;
      }

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load albums";
        _isLoading = false;
      });
    }
  }

  void _openAlbum(AssetPathEntity album) async {
    try {
      List<AssetEntity> images = await album.getAssetListPaged(page: 0, size: 100);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AlbumScreen(album.name, images)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load album")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gallery")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _albums.isEmpty
          ? Center(child: Text("No albums found"))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: _albums[index]
                .getAssetListRange(start: 0, end: 1)
                .then((assets) => assets.isNotEmpty
                ? assets.first.thumbnailDataWithSize(
                const ThumbnailSize(200, 200))
                : null)
                .catchError((_) => null),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () => _openAlbum(_albums[index]),
                child: Container(
                  decoration: BoxDecoration(
                    image: snapshot.hasData
                        ? DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.all(4),
                    child: Text(
                      _albums[index].name,
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AlbumScreen extends StatelessWidget {
  final String albumName;
  final List<AssetEntity> images;

  AlbumScreen(this.albumName, this.images);

  void _openImage(BuildContext context, AssetEntity image) async {
    try {
      Uint8List? data = await image.originBytes;
      if (data != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(data),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(albumName)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Uint8List?>(
            future: images[index]
                .thumbnailDataWithSize(const ThumbnailSize(200, 200))
                .catchError((_) => null),
            builder: (context, snapshot) {
              return GestureDetector(
                onTap: () => _openImage(context, images[index]),
                child: snapshot.hasData
                    ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List imageData;

  FullScreenImage(this.imageData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.memory(imageData, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}