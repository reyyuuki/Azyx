import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EpisodeList extends StatelessWidget {
  final List<dynamic>? filteredEpisodes;
  final dynamic episodeId;
  final Function(int)? handleEpisode;

  const EpisodeList({
    super.key,
    this.filteredEpisodes,
    this.episodeId,
    this.handleEpisode,
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
              onTap: () => handleEpisode!(episodeNumber),
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
}
