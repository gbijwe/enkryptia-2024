import 'package:enkryptia/data/salesman_trip_database_helper.dart';
import 'package:flutter/material.dart';

class TripHistoryPage extends StatefulWidget {
  @override
  _TripHistoryPageState createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  late Future<List<Map<String, dynamic>>> _tripHistory;

  @override
  void initState() {
    super.initState();
    _tripHistory = SalesmanTripDatabaseHelper().getSalesmanTripDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tripHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trip history found.'));
          } else {
            final tripHistory = snapshot.data!;
            return ListView.builder(
              itemCount: tripHistory.length,
              itemBuilder: (context, index) {
                final trip = tripHistory[index];
                return ListTile(
                  title: Text('Trip ID: ${trip['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Time: ${trip['start_datetime']}'),
                      Text('End Time: ${trip['end_datetime'] ?? 'Ongoing'}'),
                      Text('Total Time Spent: ${trip['total_time_spent'] ?? 'N/A'}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}