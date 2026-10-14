import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mech_go/User/UserRequests/request_bloc.dart';
import 'package:mech_go/User/UserRequests/request_event.dart';
import 'package:mech_go/User/UserRequests/request_repo.dart';
import 'package:mech_go/User/UserRequests/request_state.dart';
import 'package:mech_go/User/UserRequests/track_mechanic.dart';

class RequestDetail extends StatefulWidget {
  final String vehicleType;
  final String problemType;

  const RequestDetail({
    required this.vehicleType,
    required this.problemType,
    super.key,
  });

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  final TextEditingController descriptionController =
      TextEditingController();


      
  final Geocoding geocoding=Geocoding();

  final ImagePicker picker = ImagePicker();

  final List<XFile> selectedImages = [];

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  int characterCount = 0;

  Position? currentPosition;

  bool isGettingLocation = false;
  bool isSendingRequest = false;

  String locationText = 'Getting your location...';

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  // ============================================================
  // GET LIVE USER LOCATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
  if (!mounted) return;

  setState(() {
    isGettingLocation = true;
    locationText = 'Getting your location...';
  });

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      setState(() {
        isGettingLocation = false;
        locationText = 'Location service is disabled';
      });

      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;

      setState(() {
        isGettingLocation = false;
        locationText = 'Location permission denied';
      });

      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      setState(() {
        isGettingLocation = false;
        locationText = 'Location permission permanently denied';
      });

      await Geolocator.openAppSettings();
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    if (!mounted) return;

    // ============================================================
    // REVERSE GEOCODING: Convert Coordinates to Human Address
    // ============================================================
    String formattedAddress =
    '${position.latitude.toStringAsFixed(6)}, '
    '${position.longitude.toStringAsFixed(6)}';

try {
  final List<Placemark> placemarks =
      await geocoding.placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  if (placemarks.isNotEmpty) {
    final Placemark place = placemarks.first;

    formattedAddress =
        '${place.locality ?? ''}, '
        '${place.administrativeArea ?? ''}, '
        '${place.country ?? ''}';

    formattedAddress = formattedAddress
        .replaceAll(', ,', ',')
        .replaceAll(RegExp(r',\s*$'), '');
  }
} catch (e) {
  debugPrint('Geocoding error: $e');
}

    if (!mounted) return;

    setState(() {
      currentPosition = position;
      isGettingLocation = false;
      locationText = formattedAddress; // Updated with address string!
    });

  } catch (e) {
    if (!mounted) return;

    setState(() {
      isGettingLocation = false;
      locationText = 'Unable to get current location';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not get your location: $e',
        ),
      ),
    );
  }
}

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> pickImageFromGallery() async {
    final List<XFile> images =
        await picker.pickMultiImage();

    if (images.isNotEmpty && mounted) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null && mounted) {
      setState(() {
        selectedImages.add(image);
      });
    }
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: primaryRed,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromCamera();
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: primaryRed,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // ============================================================
  // SEND REQUEST
  // ============================================================

  void _sendRequest(BuildContext context) {
    final description =
        descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your problem.',
          ),
        ),
      );

      return;
    }

    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please wait until your current location is detected.',
          ),
        ),
      );

      _getCurrentLocation();
      return;
    }

    final position = currentPosition!;

    setState(() {
      isSendingRequest = true;
    });

    context.read<RequestBloc>().add(
          CreateRequest(
            vehicleType: widget.vehicleType,
            problemType: widget.problemType,
            description: description,

            // Human-readable location.
            // Coordinates are the REAL source of location.
            location: locationText,

            imagePaths: selectedImages
                .map((image) => image.path)
                .toList(),

            // REAL GPS
            latitude: position.latitude,
            longitude: position.longitude,

            amount: 0,
          ),
        );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => RequestBloc(
        requestRepository: RequestRepository(),
      ),
      child: BlocListener<RequestBloc, RequestState>(
        listener: (context, state) {
          if (state.status == RequestStatus.created) {
            if (!mounted) return;

            setState(() {
              isSendingRequest = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Service request created successfully.',
                ),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RequestTrackMechanic(
                  requestId: state.requestId!,
                ),
              ),
            );
          }

          if (state.status == RequestStatus.failure) {
            if (!mounted) return;

            setState(() {
              isSendingRequest = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'Failed to create request.',
                ),
              ),
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: primaryRed,
            title: Text(
              'Describe your Issue',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Times New Roman',
                fontSize: size.height * 0.02,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                      20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * 0.01,
                ),

                const Center(
                  child: Text(
                    'Help us find the right Mechanic',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  height: size.height * 0.03,
                ),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.02,
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    height: size.height * 0.18,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 8,
                            bottom: 25,
                          ),
                          child: TextField(
                            controller:
                                descriptionController,
                            maxLength: 250,
                            maxLines: null,
                            expands: true,
                            textAlignVertical:
                                TextAlignVertical.top,
                            onChanged: (value) {
                              setState(() {
                                characterCount =
                                    value.length;
                              });
                            },
                            decoration:
                                const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              hintText:
                                  'My Bike is not starting due to engine issue.....',
                              hintStyle: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          right: 12,
                          bottom: 8,
                          child: Text(
                            '$characterCount/250',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: size.height * 0.035,
                ),

                // ==================================================
                // PHOTOS
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.only(left: 10),
                  child: Text(
                    'Add Photos (Optional)',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.02,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Padding(
                  padding:
                      EdgeInsets.only(left: 10),
                  child: Text(
                    'Add photos of the problem for better assistance',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: size.height * 0.14,
                  child: ListView(
                    scrollDirection:
                        Axis.horizontal,
                    padding:
                        const EdgeInsets.only(left: 10),
                    children: [
                      ...List.generate(
                        selectedImages.length,
                        (index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              right: 12,
                            ),
                            child: Stack(
                              clipBehavior:
                                  Clip.none,
                              children: [
                                Container(
                                  width:
                                      size.width * 0.25,
                                  height:
                                      size.width * 0.25,
                                  decoration:
                                      BoxDecoration(
                                    borderRadius:
                                        BorderRadius
                                            .circular(12),
                                    image:
                                        DecorationImage(
                                      image: FileImage(
                                        File(
                                          selectedImages[
                                                  index]
                                              .path,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  top: -7,
                                  right: -7,
                                  child:
                                      GestureDetector(
                                    onTap: () =>
                                        removeImage(
                                      index,
                                    ),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration:
                                          const BoxDecoration(
                                        color:
                                            Colors.black87,
                                        shape:
                                            BoxShape.circle,
                                      ),
                                      child:
                                          const Icon(
                                        Icons.close,
                                        color:
                                            Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      GestureDetector(
                        onTap:
                            showImagePickerOptions,
                        child: Container(
                          width:
                              size.width * 0.25,
                          height:
                              size.width * 0.25,
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: primaryRed,
                                size: 32,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: primaryRed,
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.04,
                ),

                // ==================================================
                // LIVE LOCATION
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.all(10),
                  child: Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: size.height * 0.02,
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: primaryRed,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            locationText,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed:
                              isGettingLocation
                                  ? null
                                  : _getCurrentLocation,
                          icon: isGettingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  color: primaryRed,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 12,
                    top: 8,
                  ),
                  child: TextButton.icon(
                    onPressed:
                        isGettingLocation
                            ? null
                            : _getCurrentLocation,
                    icon: Icon(
                      Icons.my_location,
                      color: primaryRed,
                    ),
                    label: Text(
                      'Use Current Location',
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: size.height * 0.04,
                ),

                // ==================================================
                // FIND MECHANICS
                // ==================================================

                GestureDetector(
                  onTap: isSendingRequest
                      ? null
                      : () => _sendRequest(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      height: size.height * 0.06,
                      decoration: BoxDecoration(
                        color: isSendingRequest
                            ? Colors.grey
                            : primaryRed,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isSendingRequest
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Find Mechanics',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}