import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';

const kGoogleApiKey = "AIzaSyDyZI3Yt7wS-hxvBN2LPB33u-TH_binkX4";

class LocationPicker {
  static Future<Map<String, dynamic>?> pick(BuildContext context) async {
    final places = FlutterGooglePlacesSdk(kGoogleApiKey);

    print("CLICK LOCATION PICKER"); // 👈 ใส่ตรงนี้

    final result = await showSearch(
      context: context,
      delegate: _PlacesSearchDelegate(places),
    );

    print("RESULT = $result"); // 👈 ใส่เพิ่มได้

    return result;
  }
}

class _PlacesSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final FlutterGooglePlacesSdk places;

  _PlacesSearchDelegate(this.places);

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Container();

    return FutureBuilder(
      future: places.findAutocompletePredictions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final results = snapshot.data!.predictions;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];

            return ListTile(
              title: Text(item.fullText ?? ""),
              onTap: () async {
                final detail = await places.fetchPlace(
                  item.placeId,
                  fields: [PlaceField.Location, PlaceField.Name],
                );

                final lat = detail.place?.latLng?.lat;
                final lng = detail.place?.latLng?.lng;

                Navigator.pop(context, {
                  "name": item.fullText,
                  "lat": lat,
                  "lng": lng,
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  );
}
