/// Available crop types for the image editor.
enum CropType {
  /// Standard rectangular/square crop
  square,

  /// Circular crop with transparent background outside the circle
  circle,

  /// Free-form crop where user draws a custom shape
  freeForm,

  /// Smart crop (coming soon)
  smart,
}
