import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EpisodeList extends StatelessWidget {
  final List<dynamic>? filteredEpisodes;
  final dynamic episodeId;
  final Function? handleEpisode;
  final Function()? fetchEpisodeUrl;
  final String? url;

  const EpisodeList({
    super.key,
    this.filteredEpisodes,
    this.episodeId,
    this.handleEpisode,
    this.fetchEpisodeUrl,
    this.url
  });

  

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 440,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredEpisodes?.length ?? 0,
          itemBuilder: (context, index) {
            final item = filteredEpisodes![index];
            final title = item['title'];
            final episodeNumber = item['number'];
            return GestureDetector(
              // onTap: () => handleEpisode!(episodeNumber),
              onTap: () { 
                displayBottomSheet(context, episodeNumber);
                },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(
                      width: 5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  color: episodeNumber == episodeId
                      ? Theme.of(context).colorScheme.inversePrimary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text(
                          title.length > 25
                              ? '${title.substring(0, 25)}...'
                              : title,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .inverseSurface,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                      ),
                      episodeNumber == episodeId
                          ? Icon(
                              Ionicons.play,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inverseSurface,
                            )
                          : Text(
                              'Ep- $episodeNumber',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Future<void> displayBottomSheet(BuildContext context,int number) async{
    return showModalBottomSheet(context: context, 
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    backgroundColor: Theme.of(context).colorScheme.primary,
    barrierColor: Colors.black87.withOpacity(0.5),
    builder: (context) =>  Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            server(context, "HD - 1",number,"vidstreaming"),
            const SizedBox(height: 10,),
            server(context, "HD - 2",number,"megacloud"),
            const SizedBox(height: 10,),
            server(context, "Vidstream",number,"streamsb"),
          ],
        ),
      ),
    ) );
  }

  GestureDetector server(BuildContext context, name,int number,String serverType) {
    return GestureDetector(
      onTap: () {
        handleEpisode!(number,serverType);
        Navigator.pushNamed(
          context,
          '/stream',
          arguments: {
            'episodeSrc': url,
            'episodeData': number,       // Modify as necessary
            'currentEpisode': number,
            'episodeTitle': number.toString(), // Modify as necessary
            'subtitleTracks': [], // Add actual subtitle tracks if available
            'animeTitle': 'Your Anime Title', // Modify as necessary
            'activeServer': serverType,
            'isDub': false, // Set true/false based on your logic
          },
        );
      } ,
      child: Container(
            height: 60,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(name, style: const TextStyle(fontSize: 18, fontFamily: "Poppins-Bold" ),),),
          ),
    );
  }
}

