import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat.dart';

import 'package:mech_go/Mechanic/MechanicNotification/mech_notification.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_bloc.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_event.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_requests_repo.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_requests_state.dart';
import 'package:mech_go/Mechanic/MechanicRequests/m_requests.dart';
import 'package:mech_go/Services/geo_locator.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';

class MechanicHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllRequests;

  const MechanicHomeScreen({super.key,
  this.onViewAllRequests});

  @override
  State<MechanicHomeScreen> createState() =>
      _MechanicHomeScreenState();
}

class _MechanicHomeScreenState
    extends State<MechanicHomeScreen> {


  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  GoogleMapController? mapController;

  LatLng? currentLocation;

  bool loadingLocation = true;

  late final MechRequestsBloc _mechRequestsBloc;
  RequestModel? acceptedRequest;

  @override
  void initState() {
    super.initState();

    _mechRequestsBloc = MechRequestsBloc(
      repository: MechRequestsRepository(),
    );

    getLocation();
  }

  Future<void> getLocation() async {
    if (!mounted) return;

    setState(() {
      loadingLocation = true;
    });

    try {
      final Position? position =
          await LocationService.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;

        setState(() {
          loadingLocation = false;
        });

        showLocationError();
        return;
      }

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentLocation = location;
        loadingLocation = false;
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            location,
            16,
          ),
        );
      }

      /// Start real-time nearby request listener.
      _mechRequestsBloc.add(
        WatchNearbyRequests(
          mechanicLatitude: position.latitude,
          mechanicLongitude: position.longitude,

          /// IMPORTANT:
          /// Home only displays requests within 5 KM.
          radiusKm: 5,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to get location: $e',
          ),
        ),
      );
    }
  }

  void showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please enable location to use MechGo.',
        ),
      ),
    );
  }

  Widget buildMap() {
    if (loadingLocation) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentLocation == null) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off,
                size: 45,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              const Text(
                'Location unavailable',
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: getLocation,
                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: currentLocation!,
        zoom: 16,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (controller) {
        mapController = controller;
      },
      markers: {
        Marker(
          markerId: const MarkerId('mechanic'),
          position: currentLocation!,
          infoWindow: const InfoWindow(
            title: 'You are here',
          ),
        ),
      },
    );
  }

  /// ------------------------------------------------------------
  /// HOME REQUESTS
  /// ------------------------------------------------------------

  Widget buildRequests() {
    return BlocBuilder<
        MechRequestsBloc,
        MechRequestsState>(
      bloc: _mechRequestsBloc,
      builder: (context, state) {
        final requests = state.nearbyRequests;

        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearby Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MechanicRequests(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              const SizedBox(height: 5),

              const Text(
                'Requests within 5 KM of your location',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 12),

              if (state.status ==
                  MechRequestsStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (state.status ==
                      MechRequestsStatus.failure &&
                  requests.isEmpty)
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Text(
                      state.errorMessage ??
                          'Unable to load requests.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (requests.isEmpty)
                const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No requests within 5 KM.',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: requests
                      .take(3)
                      .map(
                        (request) =>
                            _HomeRequestCard(
                          request: request,
                          primaryRed:
                              primaryRed,
                          onAccept: () {
                            setState(() {
                              acceptedRequest=request;
                            });
                            _mechRequestsBloc.add(
                              AcceptMechanicRequest(
                                request.requestId,
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mechRequestsBloc.close();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    return BlocListener<
        MechRequestsBloc,
        MechRequestsState>(
      bloc: _mechRequestsBloc,
      listener: (context, state) {
        if (state.status ==
            MechRequestsStatus.accepted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Request accepted successfully.',
              ),
            ),
          );
        }

        if (state.status ==
                MechRequestsStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryRed,
          iconTheme:
              const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            'MechGo',
            style: GoogleFonts.caveat(
              color: Colors.white,
              fontSize: size.height * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
  onPressed: () {
    if (acceptedRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept a request before opening chat.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MechanicChatScreen(
          requestId: acceptedRequest!.requestId,
          userId: acceptedRequest!.userId,
          userName: acceptedRequest!.userName,
          userPhone: acceptedRequest!.userPhone,
        ),
      ),
    );
  },
  icon: const Icon(
    Icons.chat,
    size: 30,
    color: Colors.white,
  ),
),
            SizedBox(
              width: size.width*0.03,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MechanicNotifications(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.44,
                width: double.infinity,
                child: buildMap(),
              ),

              const SizedBox(height: 15),

              buildRequests(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// HOME REQUEST CARD
/// ============================================================

class _HomeRequestCard extends StatelessWidget {
  final RequestModel request;
  final Color primaryRed;
  final VoidCallback onAccept;

  const _HomeRequestCard({
    required this.request,
    required this.primaryRed,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      primaryRed.withOpacity(
                    0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.car_repair,
                  color: primaryRed,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.problemType,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${request.vehicleType} • ${request.userName}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color:
                              Colors.black54,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            request.location,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onAccept,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryRed,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Accept Request',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}