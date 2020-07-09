class YoutubeHtmlEmbedExtractor {
  static String extract(String embedString) {
    for (var exp in [
      RegExp(r"^<iframe.+?(https:\/\/(?:www\.)?youtube\.com\/embed\/[_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match match = exp.firstMatch(embedString);
      if(match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }
}