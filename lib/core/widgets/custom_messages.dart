class DownloadMessages {
  DownloadMessages._();

  static const String permissionDeniedTitle    = 'Permission Denied';
  static const String permissionDeniedMessage  = 'Storage permission is required to save images.';
  static const String permissionSettingsTitle  = 'Permission Required';
  static const String permissionSettingsMessage =
      'Storage permission was permanently denied.\n\n'
      'Please enable it manually:\n'
      'Settings → App → Permissions → Storage/Photos → Allow';

  static const String downloadingLabel = 'Downloading…';

  static const String downloadSuccessTitle   = 'Download Complete';
  static const String downloadSuccessMessage = 'Your file has been downloaded successfully.';

  static const String downloadFailedTitle   = 'Download Failed';
  static const String downloadFailedMessage = 'This file type is not supported on your device.';

  static const String cancel       = 'Cancel';
  static const String openSettings = 'Open Settings';

  static const String insufficientStorageTitle   = 'Storage Full';
  static const String insufficientStorageMessage = 'Not enough storage space to download this file. Please free up some space and try again.';
  static const String storageCheckFailedMessage  = 'Unable to check device storage. Please ensure you have enough space and try again.';

  static const String pdfLoadFailedMessage = 'Failed to load PDF';
  static const String errorLabel           = 'Error:';
  static const String retryLabel           = 'Retry';
  static const String loadingLabel         = 'Loading';
  static const String downloadTooltip      = 'Download PDF';

  static const String duplicateFileMessage = 'File already existed, downloaded as:';
  static const String savedPathLabel       = 'Path:';
}