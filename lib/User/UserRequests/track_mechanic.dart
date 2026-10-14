import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';
import 'package:mech_go/User/Chat/request_chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mech_go/User/UserRequests/request_bloc.dart';
import 'package:mech_go/User/UserRequests/request_event.dart';
import 'package:mech_go/User/UserRequests/request_repo.dart';
import 'package:mech_go/User/UserRequests/request_state.dart';

class RequestTrackMechanic extends StatelessWidget {
  final String requestId;

  const RequestTrackMechanic({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RequestBloc(
        requestRepository: RequestRepository(),
      )..add(
          WatchRequest(requestId),
        ),
      child: _RequestTrackingView(
        requestId: requestId,
      ),
    );
  }
}

class _RequestTrackingView extends StatefulWidget {
  final String requestId;

  const _RequestTrackingView({
    required this.requestId,
  });

  @override
  State<_RequestTrackingView> createState() =>
      _RequestTrackingViewState();
}

class _RequestTrackingViewState
    extends State<_RequestTrackingView> {
  final Color primaryRed =
      const Color.fromARGB(255, 250, 41, 26);

  GoogleMapController? mapController;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      mechanicLocationSubscription;

  LatLng? userLocation;
  LatLng? mechanicLocation;

  String? currentMechanicId;

  Set<Marker> markers = {};

  bool loadingUserLocation = true;

  @override
  void initState() {
    super.initState();

    _getUserLocation();
  }

  // ============================================================
  // USER LIVE LOCATION
  // ============================================================

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        userLocation = LatLng(
          position.latitude,
          position.longitude,
        );

        loadingUserLocation = false;
      });

      _updateMarkers();

      if (mapController != null &&
          userLocation != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            userLocation!,
            14,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingUserLocation = false;
      });
    }
  }

  // ============================================================
  // LISTEN TO MECHANIC LOCATION
  // ============================================================

  void _listenToMechanicLocation(
    String mechanicId,
  ) {
    if (currentMechanicId == mechanicId) {
      return;
    }

    currentMechanicId = mechanicId;

    mechanicLocationSubscription?.cancel();

    mechanicLocationSubscription =
        FirebaseFirestore.instance
            .collection('mechanics')
            .doc(mechanicId)
            .snapshots()
            .listen(
      (snapshot) {
        final data = snapshot.data();

        if (data == null) return;

        final latitude =
            (data['latitude'] as num?)?.toDouble();

        final longitude =
            (data['longitude'] as num?)?.toDouble();

        if (latitude == null ||
            longitude == null) {
          return;
        }

        if (!mounted) return;

        setState(() {
          mechanicLocation = LatLng(
            latitude,
            longitude,
          );
        });

        _updateMarkers();

        _moveCameraToShowBoth();
      },
    );
  }

  // ============================================================
  // MARKERS
  // ============================================================

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    if (userLocation != null) {
      newMarkers.add(
        Marker(
          markerId:
              const MarkerId('user_location'),
          position: userLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Location',
          ),
          icon: BitmapDescriptor
              .defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    if (mechanicLocation != null) {
      newMarkers.add(
        Marker(
          markerId:
              const MarkerId('mechanic_location'),
          position: mechanicLocation!,
          infoWindow: const InfoWindow(
            title: 'Your Mechanic',
          ),
          icon: BitmapDescriptor
              .defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      markers = newMarkers;
    });
  }

  // ============================================================
  // SHOW USER + MECHANIC
  // ============================================================

  Future<void> _moveCameraToShowBoth() async {
    if (mapController == null) return;

    if (userLocation == null ||
        mechanicLocation == null) {
      return;
    }

    final double minLat =
        userLocation!.latitude <
                mechanicLocation!.latitude
            ? userLocation!.latitude
            : mechanicLocation!.latitude;

    final double maxLat =
        userLocation!.latitude >
                mechanicLocation!.latitude
            ? userLocation!.latitude
            : mechanicLocation!.latitude;

    final double minLng =
        userLocation!.longitude <
                mechanicLocation!.longitude
            ? userLocation!.longitude
            : mechanicLocation!.longitude;

    final double maxLng =
        userLocation!.longitude >
                mechanicLocation!.longitude
            ? userLocation!.longitude
            : mechanicLocation!.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(
        minLat,
        minLng,
      ),
      northeast: LatLng(
        maxLat,
        maxLng,
      ),
    );

    try {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          80,
        ),
      );
    } catch (_) {}
  }

  // ============================================================
  // CALL MECHANIC
  // ============================================================

  Future<void> _callMechanic(
    String phone,
  ) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mechanic phone number is not available.',
          ),
        ),
      );

      return;
    }

    final uri = Uri.parse(
      'tel:$phone',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to make phone call.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CHAT
  // ============================================================

  void _openChat(
    String mechanicId,
    String mechanicName,
    String mechanicPhone,
    String mechanicProfilePic,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestChatScreen(
          requestId: widget.requestId,
          mechanicId: mechanicId,
          mechanicName: mechanicName,
          mechanicPhone: mechanicPhone, 
          mechanicProfilePic: mechanicProfilePic,
          // mechanicProfilePic: mechanicProfilePic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    mechanicLocationSubscription?.cancel();
    mapController?.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: BlocBuilder<RequestBloc, RequestState>(
          builder: (context, state) {
            if (state.status ==
                RequestStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ??
                      'Something went wrong.',
                ),
              );
            }

            final request =
                state.selectedRequest;

            // --------------------------------------------------
            // 70% MAP + 30% PANEL
            // --------------------------------------------------

            return Column(
              children: [
                // ==================================================
                // 70% MAP
                // ==================================================

                Expanded(
                  flex: 7,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition:
                            CameraPosition(
                          target: userLocation ??
                              const LatLng(
                                31.5204,
                                74.3587,
                              ),
                          zoom: 14,
                        ),

                        myLocationEnabled:
                            false,

                        myLocationButtonEnabled:
                            false,

                        zoomControlsEnabled:
                            false,

                        compassEnabled: true,

                        markers: markers,

                        onMapCreated:
                            (controller) {
                          mapController =
                              controller;

                          if (userLocation !=
                              null) {
                            controller
                                .animateCamera(
                              CameraUpdate
                                  .newLatLngZoom(
                                userLocation!,
                                14,
                              ),
                            );
                          }
                        },
                      ),

                      // ------------------------------------------------
                      // TOP APP BAR
                      // ------------------------------------------------

                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: [
                            Container(
                              decoration:
                                  const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    30,
                                  ),
                                ),
                                child: const Text(
                                  'Track Your Mechanic',
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------
                      // RECENTER
                      // ------------------------------------------------

                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor:
                              Colors.white,
                          foregroundColor:
                              primaryRed,
                          onPressed:
                              _moveCameraToShowBoth,
                          child: const Icon(
                            Icons.my_location,
                          ),
                        ),
                      ),

                      if (loadingUserLocation)
                        const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),

                // ==================================================
                // 30% BOTTOM PANEL
                // ==================================================

                Expanded(
                  flex: 3,
                  child: _MechanicBottomPanel(
                    request: request,
                    onCall: _callMechanic,
                    onChat: _openChat,
                    onMechanicFound:
                        _listenToMechanicLocation,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MechanicBottomPanel extends StatelessWidget {
  final RequestModel? request;

  final Future<void> Function(String phone) onCall;

  final void Function(
    String mechanicId,
    String mechanicName,
    String mechanicPhone,
    String mechanicProfilePic,
  ) onChat;

  final void Function(String mechanicId)
      onMechanicFound;

  const _MechanicBottomPanel({
    required this.request,
    required this.onCall,
    required this.onChat,
    required this.onMechanicFound,
  });

  @override
  Widget build(BuildContext context) {
    final primaryRed =
        const Color.fromARGB(255, 250, 41, 26);

    if (request == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

final currentRequest=request!;

final status = currentRequest.status;
final mechanicId = currentRequest.mechanicId;
final mechanicName = currentRequest.mechanicName;
final mechanicPhone = currentRequest.mechanicPhone;
final mechanicProfilePic = currentRequest.mechanicProfilePic;

    if (status == 'accepted' &&
        mechanicId.toString().isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        onMechanicFound(
          mechanicId.toString(),
        );
      });
    }

    if (status == 'pending') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),

            const SizedBox(height: 12),

            const Text(
              'Finding a nearby mechanic...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your request has been sent to nearby available mechanics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  context.read<RequestBloc>().add(
                        CancelRequest(
                          currentRequest.requestId,
                        ),
                      );
                },
                child: const Text(
                  'Cancel Request',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'cancelled') {
      return const Center(
        child: Text(
          'Your request has been cancelled.',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (status == 'accepted') {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      primaryRed.withOpacity(0.1),
                  child: Icon(
                    Icons.engineering,
                    color: primaryRed,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        mechanicName.toString(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: primaryRed,
                            size: 16,
                          ),

                          const SizedBox(width: 4),

                          const Text(
                            'Verified Mechanic',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      const Text(
                        'Mechanic is on the way',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // CALL
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onCall(
                          mechanicPhone.toString(),
                        );
                      },
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryRed,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.phone,
                      ),
                      label: const Text(
                        'Call',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // CHAT
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onChat(
                          mechanicId.toString(),
                          mechanicName.toString(),
                          mechanicPhone.toString(),
                          mechanicProfilePic.toString(),
                        );
                      },
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            primaryRed,
                        side: BorderSide(
                          color: primaryRed,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat,
                      ),
                      label: const Text(
                        'Chat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (status == 'completed') {
      return const Center(
        child: Text(
          'Service Completed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Center(
      child: Text(
        'Status: $status',
      ),
    );
  }
}