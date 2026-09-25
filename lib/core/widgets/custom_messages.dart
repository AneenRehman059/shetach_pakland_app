class DownloadMessages {
  DownloadMessages._(); // prevent instantiation

  // ── Permission ───────────────────────────────────────────────────────
  static const String permissionDeniedTitle    = 'Permission Denied';
  static const String permissionDeniedMessage  = 'Storage permission is required to save images.';
  static const String permissionSettingsTitle  = 'Permission Required';
  static const String permissionSettingsMessage =
      'Storage permission was permanently denied.\n\n'
      'Please enable it manually:\n'
      'Settings → App → Permissions → Storage/Photos → Allow';

  // ── Download Progress ────────────────────────────────────────────────
  static const String downloadingLabel = 'Downloading…';

  // ── Success ──────────────────────────────────────────────────────────
  static const String downloadSuccessTitle   = 'Download Complete';
  static const String downloadSuccessMessage = 'Your file has been downloaded successfully.';

  // ── Failure ──────────────────────────────────────────────────────────
  static const String downloadFailedTitle   = 'Download Failed';
  static const String downloadFailedMessage = 'This file type is not supported on your device.';

  // ── Dialog Buttons ───────────────────────────────────────────────────
  static const String cancel       = 'Cancel';
  static const String openSettings = 'Open Settings';

  // ── Storage ──────────────────────────────────────────────────────────
  static const String insufficientStorageTitle   = 'Storage Full';
  static const String insufficientStorageMessage = 'Not enough storage space to download this file. Please free up some space and try again.';
  static const String storageCheckFailedMessage  = 'Unable to check device storage. Please ensure you have enough space and try again.';

// ── PDF Viewer ───────────────────────────────────────────────────────
  static const String pdfLoadFailedMessage = 'Failed to load PDF';
  static const String errorLabel           = 'Error:';
  static const String retryLabel           = 'Retry';
  static const String loadingLabel         = 'Loading';
  static const String downloadTooltip      = 'Download PDF';

// ── Duplicate File ───────────────────────────────────────────────────
  static const String duplicateFileMessage = 'File already existed, downloaded as:';
  static const String savedPathLabel       = 'Path:';
}