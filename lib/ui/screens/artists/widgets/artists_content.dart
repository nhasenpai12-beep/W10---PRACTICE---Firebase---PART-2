import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
import '../../../../model/artist/artist.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../../../widgets/song/artist_tile.dart';
import '../../artist_detail/artist_detail_screen.dart';
import '../view_model/artists_view_model.dart';

class ArtistsContent extends StatelessWidget {
  const ArtistsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 1- Read the globbal song repository
    ArtistsViewModel mv = context.watch<ArtistsViewModel>();

    AsyncValue<List<Artist>> asyncValue = mv.artistsValue;

    Widget content;
    switch (asyncValue.state) {
      case AsyncValueState.loading:
        content = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: CircularProgressIndicator()),
          ],
        );
        break;
      case AsyncValueState.error:
        content = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                'error = ${asyncValue.error!}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
        break;

      case AsyncValueState.success:
        List<Artist> artists = asyncValue.data!;
        content = ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: artists.length,
          itemBuilder: (context, index) => ArtistTile(
            artist: artists[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ArtistDetailScreen(artist: artists[index]),
                ),
              );
            },
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text("Library", style: AppTextStyles.heading),
          SizedBox(height: 50),

          Expanded(
            child: RefreshIndicator(
              onRefresh: mv.refresh,
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
