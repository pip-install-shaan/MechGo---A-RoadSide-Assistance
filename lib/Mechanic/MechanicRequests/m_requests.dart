import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_bloc.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_request_event.dart';

import 'package:mech_go/Mechanic/MechanicRequests/mech_requests_repo.dart';
import 'package:mech_go/Mechanic/MechanicRequests/mech_requests_state.dart';
import 'package:mech_go/User/UserRequests/request_model.dart';

class MechanicRequests extends StatefulWidget {
  const MechanicRequests({super.key});

  @override
  State<MechanicRequests> createState() =>
      _MechanicRequestsState();
}

class _MechanicRequestsState
    extends State<MechanicRequests> {
  late final MechRequestsBloc _bloc;

  double? _mechanicLatitude;
  double? _mechanicLongitude;

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  @override
  void initState() {
    super.initState();

    _bloc = MechRequestsBloc(
      repository: MechRequestsRepository(),
    );

    _initializeMechanicLocation();
  }

  Future<void> _initializeMechanicLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please turn on your location service.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is required to find nearby requests.',
        );
        return;
      }

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _mechanicLatitude =
          position.latitude;

      _mechanicLongitude =
          position.longitude;

      if (!mounted) return;

      _bloc.add(
        WatchAllMechanicRequests(
          mechanicLatitude:
              position.latitude,
          mechanicLongitude:
              position.longitude,
          radiusKm: 5,
        ),
      );

      setState(() {});
    } catch (e) {
      _showMessage(
        'Unable to get mechanic location: $e',
      );
    }
  }

  Future<void> _refreshRequests() async {
    if (_mechanicLatitude == null ||
        _mechanicLongitude == null) {
      await _initializeMechanicLocation();
      return;
    }

    _bloc.add(
      WatchAllMechanicRequests(
        mechanicLatitude:
            _mechanicLatitude!,
        mechanicLongitude:
            _mechanicLongitude!,
        radiusKm: 5,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: primaryRed,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'All Requests',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: size.height * 0.03,
          ),
        ),
      ),

        body: BlocListener<
            MechRequestsBloc,
            MechRequestsState>(
          listener: (context, state) {
            if (state.status ==
                MechRequestsStatus.accepted) {
              _showMessage(
                'Request accepted successfully.',
              );
            }

            if (state.status ==
                MechRequestsStatus.cancelled) {
              _showMessage(
                'Request cancelled.',
              );
            }

            if (state.status ==
                    MechRequestsStatus.failure &&
                state.errorMessage != null) {
              _showMessage(
                state.errorMessage!,
              );
            }
          },
          child: BlocBuilder<
              MechRequestsBloc,
              MechRequestsState>(
            builder: (context, state) {
              if (state.status ==
                  MechRequestsStatus.loading) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (state.status ==
                      MechRequestsStatus.failure &&
                  state.allRequests.isEmpty) {
                return Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: Text(
                      state.errorMessage ??
                          'Unable to load requests.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                );
              }

              if (state.allRequests.isEmpty) {
                return RefreshIndicator(
                  onRefresh:
                      _refreshRequests,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          'No service requests available.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final pending =
                  state.allRequests
                      .where(
                        (r) =>
                            r.status ==
                            'pending',
                      )
                      .toList();

              final accepted =
                  state.allRequests
                      .where(
                        (r) =>
                            r.status ==
                            'accepted',
                      )
                      .toList();

              final onTheWay =
                  state.allRequests
                      .where(
                        (r) =>
                            r.status ==
                            'on_the_way',
                      )
                      .toList();

              final cancelled =
                  state.allRequests
                      .where(
                        (r) =>
                            r.status ==
                            'cancelled',
                      )
                      .toList();

              return RefreshIndicator(
                onRefresh:
                    _refreshRequests,
                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.all(12),
                  children: [
                    _buildSection(
                      title:
                          'New Requests',
                      requests:
                          pending,
                      showActions: true,
                    ),

                    _buildSection(
                      title:
                          'Accepted',
                      requests:
                          accepted,
                      showActions: true,
                    ),

                    _buildSection(
                      title:
                          'On The Way',
                      requests:
                          onTheWay,
                      showActions: false,
                    ),

                    _buildSection(
                      title:
                          'Cancelled',
                      requests:
                          cancelled,
                      showActions: false,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<RequestModel> requests,
    required bool showActions,
  }) {
    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        ...requests.map(
          (request) => _RequestCard(
            request: request,
            primaryRed: primaryRed,
            showActions: showActions,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final Color primaryRed;
  final bool showActions;

  const _RequestCard({
    required this.request,
    required this.primaryRed,
    required this.showActions,
  });

  Color _statusColor() {
    switch (request.status) {
      case 'accepted':
        return Colors.green;

      case 'on_the_way':
        return Colors.blue;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  String _statusText() {
    switch (request.status) {
      case 'accepted':
        return 'ACCEPTED';

      case 'on_the_way':
        return 'ON THE WAY';

      case 'cancelled':
        return 'CANCELLED';

      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        _statusColor();

    return Card(
      margin:
          const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        request.vehicleType,
                        style:
                            const TextStyle(
                          color:
                              Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color: statusColor
                        .withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _statusText(),
                    style:
                        TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              request.problemType,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              request.description,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    request.location,
                  ),
                ),
              ],
            ),

            if (request.imageUrls
                .isNotEmpty) ...[
              const SizedBox(height: 12),

              SizedBox(
                height: 80,
                child:
                    ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount: request
                      .imageUrls.length,
                  itemBuilder:
                      (context, index) {
                    return Container(
                      width: 80,
                      margin:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child:
                          ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        child:
                            Image.network(
                          request
                              .imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Center(
                              child: Icon(
                                Icons
                                    .broken_image,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (showActions &&
                request.status ==
                    'pending') ...[
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed: () {
                        context
                            .read<
                                MechRequestsBloc>()
                            .add(
                              AcceptMechanicRequest(
                                request
                                    .requestId,
                              ),
                            );
                      },
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryRed,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Accept',
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed: () {
                        context
                            .read<
                                MechRequestsBloc>()
                            .add(
                              CancelMechanicRequest(
                                request
                                    .requestId,
                              ),
                            );
                      },
                      style:
                          OutlinedButton
                              .styleFrom(
                        foregroundColor:
                            Colors.red,
                        side:
                            const BorderSide(
                          color: Colors.red,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                      ),
                      child:
                          const Text(
                        'Cancel',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (request.status ==
                'accepted') ...[
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 45,
                child:
                    ElevatedButton(
                  onPressed: () {
                    context
                        .read<
                            MechRequestsBloc>()
                        .add(
                          MarkRequestOnTheWay(
                            request
                                .requestId,
                          ),
                        );
                  },
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.blue,
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
                  child:
                      const Text(
                    'Start Journey',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}