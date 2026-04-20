class TitleCase {
  static toTitleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+')) // handles multiple spaces/tabs
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
