// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stikerz';

  @override
  String get home => 'Home';

  @override
  String get videoPicker => 'Pick Video';

  @override
  String get stickerEditor => 'Sticker Editor';

  @override
  String get yourPacks => 'Your Packs';

  @override
  String get myStickers => 'My Stickers';

  @override
  String get createPack => 'Create Pack';

  @override
  String get editPack => 'Edit Pack';

  @override
  String get deletePack => 'Delete Pack';

  @override
  String get renamePack => 'Rename Pack';

  @override
  String get noPacksTitle => 'No Sticker Packs Yet';

  @override
  String get noPacksDesc =>
      'Share a TikTok or Instagram video to create your first pack';

  @override
  String get galleryLimitedAccessTitle => 'Gallery Access Limited';

  @override
  String get galleryLimitedAccessDesc =>
      'This app needs access to all your photos and videos to create sticker packs from your media. Please change your permission settings.';

  @override
  String get grantAccess => 'Grant Full Access';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get uploadVideo => 'Upload Video';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get confirming => 'Confirming...';

  @override
  String get copying => 'Copying...';

  @override
  String get generating => 'Generating...';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get packName => 'Pack Name';

  @override
  String get packNameHint => 'Enter pack name';

  @override
  String get author => 'Author';

  @override
  String get authorHint => 'Enter author name';

  @override
  String get emptyFieldError => 'This field cannot be empty';

  @override
  String get tooLongError => 'Text is too long';

  @override
  String get renamingPack => 'Renaming pack...';

  @override
  String get deletingPack => 'Deleting pack...';

  @override
  String get addedToPack => 'Added to pack';

  @override
  String get failedToAdd => 'Failed to add to pack';

  @override
  String get videoNotSupported => 'This type of media is not supported';

  @override
  String get selectValidVideo => 'Please select a valid video';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get shareDirectly => 'Share directly from TikTok or Instagram';

  @override
  String get orSelectFromGallery => 'or select a video from your gallery';

  @override
  String get myCollections => 'MY COLLECTIONS';

  @override
  String get searchPackPlaceholder => 'Search pack...';

  @override
  String get deletePackTitle => 'Delete pack';

  @override
  String deletePackMessage(Object packName) {
    return 'Delete \"$packName\"? This action cannot be undone.';
  }

  @override
  String get discard => 'Discard';

  @override
  String get preparingVideo => 'Preparing your video';

  @override
  String get convertingLink =>
      'We\'re converting the link so you can add it without extra steps.';

  @override
  String get createPackFirst => 'Create a pack first';

  @override
  String get createPackHint =>
      'After creating your first pack, you\'ll be able to add this shared video.';

  @override
  String get selectPackTitle => 'Select the pack';

  @override
  String get selectPackDesc =>
      'The link is ready. Choose the pack where you want to add it.';

  @override
  String get preparingVideoHint =>
      'We\'re preparing the shared video. Please wait a moment.';

  @override
  String get createPackHint2 => 'Create a pack first to add this video.';

  @override
  String get selectPackHint =>
      'Select the pack where you want to add this video.';

  @override
  String stickersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stickers',
      one: '$count sticker',
    );
    return '$_temp0';
  }

  @override
  String packCountByAuthor(Object author) {
    return 'by $author';
  }

  @override
  String stickerCountStatus(Object count) {
    return '$count / 30 — Ready for WhatsApp!';
  }

  @override
  String stickerCountSimple(Object count) {
    return '$count / 30 stickers';
  }

  @override
  String get newPack => 'New pack';

  @override
  String get packNameExample => 'Ex: My best moments';

  @override
  String get authorNameLabel => 'AUTHOR NAME';

  @override
  String get authorNameExample => 'Ex: Carlos R.';

  @override
  String get createPackButton => 'Create pack →';

  @override
  String get packNameLabel => 'PACK NAME';

  @override
  String get noGalleryAccess => 'No gallery access';

  @override
  String get galleryAccessNeeded =>
      'We need access to your videos to create stickers.';

  @override
  String get giveAccess => 'Give access';

  @override
  String get limitedGalleryAccess => 'Limited gallery access';

  @override
  String get addMoreVideos => 'Tap to add more videos';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get selectedVideoLabel => 'Select a video';

  @override
  String get selectVideoHint => 'Tap a video to select it';

  @override
  String get useThisVideo => 'Use this video';

  @override
  String packsFound(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results of $total',
      one: '$count result of $total',
    );
    return '$_temp0';
  }

  @override
  String packsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs',
      one: '$count pack',
    );
    return '$_temp0';
  }

  @override
  String get loadingVideo => 'Loading video...';

  @override
  String get instagramLoadingNote =>
      'This may take a few seconds with Instagram';

  @override
  String videoOpenError(Object error) {
    return 'Could not open video: $error';
  }

  @override
  String get stickerEditorTitle => 'Sticker Editor';

  @override
  String startTime(Object time) {
    return '⏱ $time';
  }

  @override
  String totalDuration(Object time) {
    return '$time total';
  }

  @override
  String get startPointLabel => 'Start point';

  @override
  String get durationLabel => 'Duration';

  @override
  String durationValue(Object value) {
    return '${value}s';
  }

  @override
  String get creatingSticker => 'Creating sticker...';

  @override
  String get generateAnimatedSticker => 'Generate Animated Sticker';

  @override
  String get stickerLimits => 'Max. 5s · 500KB · animated WebP format';

  @override
  String get generateStickerTitle => 'Generate sticker';

  @override
  String get aspectLabel => 'Aspect';

  @override
  String get startLabel => 'Start';

  @override
  String get durationShort => 'Duration';

  @override
  String get generateButton => 'Generate';

  @override
  String get couldNotCreateSticker => 'Could not create sticker';

  @override
  String get videoTooComplex =>
      'The video has too many details and exceeds the size limit.';

  @override
  String get reduceSelectionArea => 'Reduce the selection area';

  @override
  String get shortenClipDuration => 'Shorten the clip duration';

  @override
  String get blurReduceFps => 'Blur + reduce FPS (Recommended)';

  @override
  String get blurMildTenFps => 'Mild blur + 10 FPS';

  @override
  String get smoothDetails => 'Smooth details';

  @override
  String get applyMildBlur => 'Applies mild blur';

  @override
  String get reduceFpsLabel => 'Reduce FPS';

  @override
  String get reduceTo10Fps => 'Lower to 10 FPS';

  @override
  String get moreTransparency => 'More transparency';

  @override
  String get reduceVisibleArea => 'Reduces visible area';

  @override
  String get tryAnotherStrategy => 'Try another strategy';

  @override
  String get importFromTikTok => 'Import from TikTok';

  @override
  String get stickerTooHeavy => 'Sticker is too heavy';

  @override
  String needToReduce(int amount) {
    return 'Need to reduce ${amount}KB more to meet the 500KB limit';
  }

  @override
  String get pasteVideoLink => 'Paste a video link';

  @override
  String get pasteValidTikTokLink => 'Paste a valid TikTok link';

  @override
  String get importFromInstagram => 'Import from Instagram';

  @override
  String get pasteReelLink => 'Paste a Reel link';

  @override
  String get pasteValidInstagramLink => 'Paste a valid Instagram link';

  @override
  String get localVideo => 'Local video';

  @override
  String get fromGallery => 'From your gallery';

  @override
  String get videoLinkLabel => 'VIDEO LINK';

  @override
  String get couldNotSendToWhatsApp => 'Could not send the pack to WhatsApp.';

  @override
  String get sendingToWhatsApp => 'Sending to WhatsApp...';

  @override
  String get addCoverFirst => 'Add a cover first';

  @override
  String get needAtLeastThreeStickers => 'You need at least 3 stickers';

  @override
  String get addToWhatsApp => 'Add to WhatsApp';

  @override
  String get deleteSticker => 'Delete sticker';

  @override
  String get loop => 'loop';

  @override
  String get packInfoName => 'Pack name';

  @override
  String get packInfoAuthor => 'Author';

  @override
  String get packInfoStickersAdded => 'Stickers added';

  @override
  String get packInfoCover => 'Cover';

  @override
  String get packInfoStatus => 'Status';

  @override
  String get packInfoCreated => 'Created';

  @override
  String get renamePackTitle => 'Rename pack';

  @override
  String get packNamePlaceholder => 'Ex: My best moments';

  @override
  String get authorNamePlaceholder => 'Ex: Carlos R.';

  @override
  String get saveChangesButton => 'Save changes →';

  @override
  String get newSticker => 'New sticker';

  @override
  String get paste => 'Paste';

  @override
  String get go => 'Go →';

  @override
  String get freeSlots => 'free';

  @override
  String get stickersTab => 'Stickers';

  @override
  String get packInfoTab => 'Pack info';

  @override
  String get coverConfigured => 'Configured ✓';

  @override
  String get noCover => 'No cover';

  @override
  String get statusComplete => 'Complete ✓';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get processCoverError => 'Could not process the cover.';

  @override
  String get fullPackWarning =>
      'This pack is already full. Choose another pack or create a new one.';

  @override
  String get resolvingSharedVideo => 'Resolving shared video...';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Stikerz!';

  @override
  String get onboardingWelcomeDesc =>
      'Create your own sticker packs from TikTok and Instagram videos, and share them with your friends on WhatsApp.';

  @override
  String get onboardingAddVideosTitle => 'Add Your Videos';

  @override
  String get onboardingAddVideosMethodLink =>
      '🔗 Paste TikTok or Instagram links directly in the app';

  @override
  String get onboardingAddVideosMethodGallery =>
      '📱 Or select videos from your device gallery';

  @override
  String get onboardingShareDirectTitle => 'Share Directly from Apps';

  @override
  String get onboardingShareDirectDesc =>
      'The easiest way to extract stickers from your favorite videos';

  @override
  String get onboardingShareDirectSteps => 'How to do it:';

  @override
  String get onboardingShareDirectStep1 =>
      'Open TikTok or Instagram and find a video you love';

  @override
  String get onboardingShareDirectStep2 =>
      'Use the share button and select \"Stikerz\" from the options';

  @override
  String get onboardingAdsTitle => 'Thank you for using Stikerz!';

  @override
  String get onboardingAdsDescription =>
      'We\'re grateful for your support! This app is free to use thanks to ads that help us maintain and improve it. Your understanding and patience mean everything to us. Enjoy creating and sharing your stickers! 🎨';

  @override
  String get onboardingFinishButton => 'Finish';

  @override
  String get onboardingNextButton => 'Next →';

  @override
  String get onboardingBackButton => '← Back';

  @override
  String get onboardingWelcomeSmallLabel => 'WELCOME TO THE FUTURE';

  @override
  String get onboardingWelcomeTitlePrimary => 'Animate';

  @override
  String get onboardingWelcomeTitleAccent => 'Anything';

  @override
  String get onboardingContentLabel => 'YOUR CONTENT, ANIMATED';

  @override
  String get onboardingFromSocialTitlePrimary => 'From Social';

  @override
  String get onboardingFromSocialTitleAccent => 'to Stickers';

  @override
  String get onboardingFromSocialDesc =>
      'Transform your favorite TikTok videos and Instagram Reels into animated WhatsApp stickers in seconds.';

  @override
  String get onboardingShareLabel => 'SHARE DIRECTLY';

  @override
  String get onboardingShareTitlePrimary => 'Direct';

  @override
  String get onboardingShareTitleAccent => 'Share';

  @override
  String get onboardingShareDescExtended =>
      'Just hit share on TikTok or IG and send it straight to our app. It takes only a couple taps — fast, preserves quality, and converts clips into animated stickers instantly.';

  @override
  String get onboardingLegalPrefix => 'By continuing, you agree to our ';

  @override
  String get onboardingLegalAnd => ' and ';

  @override
  String get onboardingLegalSuffix => '.';

  @override
  String get permissionRequiredTitle => 'Gallery access required';

  @override
  String get permissionRequiredDesc =>
      'You previously denied access to your videos. To import videos from your gallery, you need to enable permission manually.';

  @override
  String get openSettingsButton => 'Open settings';

  @override
  String get permissionStep1 => 'Tap \'Open settings\' below';

  @override
  String get permissionStep2 =>
      'Find \'Permissions\' and tap \'Photos & videos\' or \'Media\'';

  @override
  String get permissionStep3 => 'Select \'Allow\' or \'Allow all\'';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get useDeviceLanguage => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rateApp => 'Rate app';

  @override
  String get reportBug => 'Report bug';

  @override
  String get aboutDeveloper => 'About Developer';

  @override
  String get aboutRole => 'Lead Developer & Designer';

  @override
  String get aboutDescription =>
      'Creating fluid and beautiful digital experiences for the world.';

  @override
  String get versionLabel => 'Version';

  @override
  String get bugReport => 'Bug Report';

  @override
  String get deviceInfo => 'Device Information';

  @override
  String get describeProblem => 'Describe the problem';

  @override
  String get describeProblemHint => 'Describe your problem or provide feedback';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'yourname@example.com';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get alternatively => 'Alternatively';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get feedbackSent => 'Thank you! Your feedback has been sent.';

  @override
  String get externalServiceDown =>
      'Could not connect to the external service. It may be temporarily down; please try again later.';

  @override
  String get externalServiceTimeout =>
      'Request timed out. Please try again shortly.';

  @override
  String get externalServiceInvalidResponse =>
      'Invalid response from external service.';

  @override
  String get externalServiceNotVideo =>
      'The link is not a video. Please choose a valid video.';

  @override
  String get externalServiceVideoNotPublic =>
      'Could not retrieve the video. Please ensure it is public.';
}
