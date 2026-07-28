import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../providers/rep_provider.dart';
import '../../models/user_model.dart';
import '../../models/rep_location_model.dart';

class AdminRepLocationScreen extends StatefulWidget {
  const AdminRepLocationScreen({super.key});

  @override
  State<AdminRepLocationScreen> createState() => _AdminRepLocationScreenState();
}

class _AdminRepLocationScreenState extends State<AdminRepLocationScreen> {
  final MapController _mapController = MapController();
  static const Color primaryDeepRed = Color(0xFFC62828);
  static const Color backgroundWhite = Colors.white;
  static const Color accentBlack = Colors.black;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepProvider>().fetchAllReps();
    });
  }

  void _moveToLocation(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    final repProvider = context.watch<RepProvider>();
    final List<UserModel> allReps = repProvider.reps;

    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        title: const Text('Sales Representative Locations'),
        backgroundColor: backgroundWhite,
        foregroundColor: accentBlack,
        elevation: 1,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "View current locations of active sales representatives.",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RepLocationModel>>(
              stream: repProvider.getRepLocationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryDeepRed));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: primaryDeepRed)));
                }

                final List<RepLocationModel> locations = snapshot.data ?? [];
                
                // Filter reps that have location data
                final List<Map<String, dynamic>> repsWithLocations = [];
                for (var loc in locations) {
                  final repModel = allReps.where((r) => r.uid == loc.repId).firstOrNull;
                  if (repModel != null) {
                    repsWithLocations.add({
                      'location': loc,
                      'user': repModel,
                    });
                  }
                }

                if (repsWithLocations.isEmpty) {
                  return const Center(child: Text("No representative locations found.", style: TextStyle(color: accentBlack)));
                }

                return Column(
                  children: [
                    // Map View
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              (repsWithLocations.first['location'] as RepLocationModel).latitude,
                              (repsWithLocations.first['location'] as RepLocationModel).longitude,
                            ),
                            initialZoom: 12.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.salepro',
                            ),
                            MarkerLayer(
                              markers: repsWithLocations.map((data) {
                                final loc = data['location'] as RepLocationModel;
                                final user = data['user'] as UserModel;
                                final isOnline = loc.status == 'online';
                                
                                return Marker(
                                  point: LatLng(loc.latitude, loc.longitude),
                                  width: 80,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: backgroundWhite,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: isOnline ? Colors.green : primaryDeepRed),
                                        ),
                                        child: Text(
                                          user.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: accentBlack,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.location_on,
                                        color: isOnline ? Colors.green : primaryDeepRed,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List View
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: repsWithLocations.length,
                        itemBuilder: (context, index) {
                          final data = repsWithLocations[index];
                          final loc = data['location'] as RepLocationModel;
                          final user = data['user'] as UserModel;
                          final isOnline = loc.status == 'online';
                          
                          // Shorten UID for Employee ID
                          final employeeId = user.uid.length > 8 ? user.uid.substring(0, 8) : user.uid;
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: backgroundWhite,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Image / Avatar
                                  CircleAvatar(
                                    backgroundColor: primaryDeepRed.withOpacity(0.1),
                                    radius: 24,
                                    child: Text(
                                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'R',
                                      style: const TextStyle(
                                        color: primaryDeepRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: accentBlack,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Status Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isOnline ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: 8,
                                                    color: isOnline ? Colors.green : Colors.red,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    isOnline ? 'Online' : 'Offline',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: isOnline ? Colors.green : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Employee ID: #$employeeId',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        Text(
                                          'Route: ${user.routeId.isEmpty ? "Unassigned" : user.routeId}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Location: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                                          style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                                        ),
                                        Text(
                                          'Updated: ${DateFormat('MMM d, hh:mm a').format(loc.lastUpdated)}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        const SizedBox(height: 12),
                                        // Action Button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _moveToLocation(loc.latitude, loc.longitude);
                                            },
                                            icon: const Icon(Icons.map, size: 16),
                                            label: const Text('View Location'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryDeepRed,
                                              foregroundColor: backgroundWhite,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
