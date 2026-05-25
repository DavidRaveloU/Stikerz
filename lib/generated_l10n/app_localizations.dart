import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Stikerz'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @videoPicker.
  ///
  /// In en, this message translates to:
  /// **'Pick Video'**
  String get videoPicker;

  /// No description provided for @stickerEditor.
  ///
  /// In en, this message translates to:
  /// **'Sticker Editor'**
  String get stickerEditor;

  /// No description provided for @yourPacks.
  ///
  /// In en, this message translates to:
  /// **'Your Packs'**
  String get yourPacks;

  /// No description provided for @myStickers.
  ///
  /// In en, this message translates to:
  /// **'My Stickers'**
  String get myStickers;

  /// No description provided for @createPack.
  ///
  /// In en, this message translates to:
  /// **'Create Pack'**
  String get createPack;

  /// No description provided for @editPack.
  ///
  /// In en, this message translates to:
  /// **'Edit Pack'**
  String get editPack;

  /// No description provided for @deletePack.
  ///
  /// In en, this message translates to:
  /// **'Delete Pack'**
  String get deletePack;

  /// No description provided for @renamePack.
  ///
  /// In en, this message translates to:
  /// **'Rename Pack'**
  String get renamePack;

  /// No description provided for @noPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'No Sticker Packs Yet'**
  String get noPacksTitle;

  /// No description provided for @noPacksDesc.
  ///
  /// In en, this message translates to:
  /// **'Share a TikTok or Instagram video to create your first pack'**
  String get noPacksDesc;

  /// No description provided for @galleryLimitedAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery Access Limited'**
  String get galleryLimitedAccessTitle;

  /// No description provided for @galleryLimitedAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'This app needs access to all your photos and videos to create sticker packs from your media. Please change your permission settings.'**
  String get galleryLimitedAccessDesc;

  /// No description provided for @grantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Full Access'**
  String get grantAccess;

  /// No description provided for @selectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get selectVideo;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @confirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get confirming;

  /// No description provided for @copying.
  ///
  /// In en, this message translates to:
  /// **'Copying...'**
  String get copying;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @packName.
  ///
  /// In en, this message translates to:
  /// **'Pack Name'**
  String get packName;

  /// No description provided for @packNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter pack name'**
  String get packNameHint;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @authorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter author name'**
  String get authorHint;

  /// No description provided for @emptyFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get emptyFieldError;

  /// No description provided for @tooLongError.
  ///
  /// In en, this message translates to:
  /// **'Text is too long'**
  String get tooLongError;

  /// No description provided for @renamingPack.
  ///
  /// In en, this message translates to:
  /// **'Renaming pack...'**
  String get renamingPack;

  /// No description provided for @deletingPack.
  ///
  /// In en, this message translates to:
  /// **'Deleting pack...'**
  String get deletingPack;

  /// No description provided for @addedToPack.
  ///
  /// In en, this message translates to:
  /// **'Added to pack'**
  String get addedToPack;

  /// No description provided for @failedToAdd.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to pack'**
  String get failedToAdd;

  /// No description provided for @videoNotSupported.
  ///
  /// In en, this message translates to:
  /// **'This type of media is not supported'**
  String get videoNotSupported;

  /// No description provided for @selectValidVideo.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid video'**
  String get selectValidVideo;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @shareDirectly.
  ///
  /// In en, this message translates to:
  /// **'Share directly from TikTok or Instagram'**
  String get shareDirectly;

  /// No description provided for @orSelectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'or select a video from your gallery'**
  String get orSelectFromGallery;

  /// No description provided for @myCollections.
  ///
  /// In en, this message translates to:
  /// **'MY COLLECTIONS'**
  String get myCollections;

  /// No description provided for @searchPackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search pack...'**
  String get searchPackPlaceholder;

  /// No description provided for @deletePackTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete pack'**
  String get deletePackTitle;

  /// No description provided for @deletePackMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{packName}\"? This action cannot be undone.'**
  String deletePackMessage(Object packName);

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @preparingVideo.
  ///
  /// In en, this message translates to:
  /// **'Preparing your video'**
  String get preparingVideo;

  /// No description provided for @convertingLink.
  ///
  /// In en, this message translates to:
  /// **'We\'re converting the link so you can add it without extra steps.'**
  String get convertingLink;

  /// No description provided for @createPackFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a pack first'**
  String get createPackFirst;

  /// No description provided for @createPackHint.
  ///
  /// In en, this message translates to:
  /// **'After creating your first pack, you\'ll be able to add this shared video.'**
  String get createPackHint;

  /// No description provided for @selectPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Select the pack'**
  String get selectPackTitle;

  /// No description provided for @selectPackDesc.
  ///
  /// In en, this message translates to:
  /// **'The link is ready. Choose the pack where you want to add it.'**
  String get selectPackDesc;

  /// No description provided for @preparingVideoHint.
  ///
  /// In en, this message translates to:
  /// **'We\'re preparing the shared video. Please wait a moment.'**
  String get preparingVideoHint;

  /// No description provided for @createPackHint2.
  ///
  /// In en, this message translates to:
  /// **'Create a pack first to add this video.'**
  String get createPackHint2;

  /// No description provided for @selectPackHint.
  ///
  /// In en, this message translates to:
  /// **'Select the pack where you want to add this video.'**
  String get selectPackHint;

  /// No description provided for @stickersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} sticker} other{{count} stickers}}'**
  String stickersCount(num count);

  /// No description provided for @packCountByAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String packCountByAuthor(Object author);

  /// No description provided for @stickerCountStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} / 30 — Ready for WhatsApp!'**
  String stickerCountStatus(Object count);

  /// No description provided for @stickerCountSimple.
  ///
  /// In en, this message translates to:
  /// **'{count} / 30 stickers'**
  String stickerCountSimple(Object count);

  /// No description provided for @newPack.
  ///
  /// In en, this message translates to:
  /// **'New pack'**
  String get newPack;

  /// No description provided for @packNameExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: My best moments'**
  String get packNameExample;

  /// No description provided for @authorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'AUTHOR NAME'**
  String get authorNameLabel;

  /// No description provided for @authorNameExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: Carlos R.'**
  String get authorNameExample;

  /// No description provided for @createPackButton.
  ///
  /// In en, this message translates to:
  /// **'Create pack →'**
  String get createPackButton;

  /// No description provided for @packNameLabel.
  ///
  /// In en, this message translates to:
  /// **'PACK NAME'**
  String get packNameLabel;

  /// No description provided for @noGalleryAccess.
  ///
  /// In en, this message translates to:
  /// **'No gallery access'**
  String get noGalleryAccess;

  /// No description provided for @galleryAccessNeeded.
  ///
  /// In en, this message translates to:
  /// **'We need access to your videos to create stickers.'**
  String get galleryAccessNeeded;

  /// No description provided for @giveAccess.
  ///
  /// In en, this message translates to:
  /// **'Give access'**
  String get giveAccess;

  /// No description provided for @limitedGalleryAccess.
  ///
  /// In en, this message translates to:
  /// **'Limited gallery access'**
  String get limitedGalleryAccess;

  /// No description provided for @addMoreVideos.
  ///
  /// In en, this message translates to:
  /// **'Tap to add more videos'**
  String get addMoreVideos;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// No description provided for @selectedVideoLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a video'**
  String get selectedVideoLabel;

  /// No description provided for @selectVideoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a video to select it'**
  String get selectVideoHint;

  /// No description provided for @useThisVideo.
  ///
  /// In en, this message translates to:
  /// **'Use this video'**
  String get useThisVideo;

  /// No description provided for @packsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} result of {total}} other{{count} results of {total}}}'**
  String packsFound(num count, Object total);

  /// No description provided for @packsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} pack} other{{count} packs}}'**
  String packsCount(num count);

  /// No description provided for @loadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Loading video...'**
  String get loadingVideo;

  /// No description provided for @instagramLoadingNote.
  ///
  /// In en, this message translates to:
  /// **'This may take a few seconds with Instagram'**
  String get instagramLoadingNote;

  /// No description provided for @videoOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open video: {error}'**
  String videoOpenError(Object error);

  /// No description provided for @stickerEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Sticker Editor'**
  String get stickerEditorTitle;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'⏱ {time}'**
  String startTime(Object time);

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'{time} total'**
  String totalDuration(Object time);

  /// No description provided for @startPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Start point'**
  String get startPointLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @durationValue.
  ///
  /// In en, this message translates to:
  /// **'{value}s'**
  String durationValue(Object value);

  /// No description provided for @creatingSticker.
  ///
  /// In en, this message translates to:
  /// **'Creating sticker...'**
  String get creatingSticker;

  /// No description provided for @generateAnimatedSticker.
  ///
  /// In en, this message translates to:
  /// **'Generate Animated Sticker'**
  String get generateAnimatedSticker;

  /// No description provided for @stickerLimits.
  ///
  /// In en, this message translates to:
  /// **'Max. 5s · 500KB · animated WebP format'**
  String get stickerLimits;

  /// No description provided for @generateStickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate sticker'**
  String get generateStickerTitle;

  /// No description provided for @aspectLabel.
  ///
  /// In en, this message translates to:
  /// **'Aspect'**
  String get aspectLabel;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @durationShort.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationShort;

  /// No description provided for @generateButton.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generateButton;

  /// No description provided for @couldNotCreateSticker.
  ///
  /// In en, this message translates to:
  /// **'Could not create sticker'**
  String get couldNotCreateSticker;

  /// No description provided for @videoTooComplex.
  ///
  /// In en, this message translates to:
  /// **'The video has too many details and exceeds the size limit.'**
  String get videoTooComplex;

  /// No description provided for @reduceSelectionArea.
  ///
  /// In en, this message translates to:
  /// **'Reduce the selection area'**
  String get reduceSelectionArea;

  /// No description provided for @shortenClipDuration.
  ///
  /// In en, this message translates to:
  /// **'Shorten the clip duration'**
  String get shortenClipDuration;

  /// No description provided for @blurReduceFps.
  ///
  /// In en, this message translates to:
  /// **'Blur + reduce FPS (Recommended)'**
  String get blurReduceFps;

  /// No description provided for @blurMildTenFps.
  ///
  /// In en, this message translates to:
  /// **'Mild blur + 10 FPS'**
  String get blurMildTenFps;

  /// No description provided for @smoothDetails.
  ///
  /// In en, this message translates to:
  /// **'Smooth details'**
  String get smoothDetails;

  /// No description provided for @applyMildBlur.
  ///
  /// In en, this message translates to:
  /// **'Applies mild blur'**
  String get applyMildBlur;

  /// No description provided for @reduceFpsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reduce FPS'**
  String get reduceFpsLabel;

  /// No description provided for @reduceTo10Fps.
  ///
  /// In en, this message translates to:
  /// **'Lower to 10 FPS'**
  String get reduceTo10Fps;

  /// No description provided for @moreTransparency.
  ///
  /// In en, this message translates to:
  /// **'More transparency'**
  String get moreTransparency;

  /// No description provided for @reduceVisibleArea.
  ///
  /// In en, this message translates to:
  /// **'Reduces visible area'**
  String get reduceVisibleArea;

  /// No description provided for @tryAnotherStrategy.
  ///
  /// In en, this message translates to:
  /// **'Try another strategy'**
  String get tryAnotherStrategy;

  /// No description provided for @importFromTikTok.
  ///
  /// In en, this message translates to:
  /// **'Import from TikTok'**
  String get importFromTikTok;

  /// No description provided for @stickerTooHeavy.
  ///
  /// In en, this message translates to:
  /// **'Sticker is too heavy'**
  String get stickerTooHeavy;

  /// No description provided for @needToReduce.
  ///
  /// In en, this message translates to:
  /// **'Need to reduce {amount}KB more to meet the 500KB limit'**
  String needToReduce(int amount);

  /// No description provided for @pasteVideoLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a video link'**
  String get pasteVideoLink;

  /// No description provided for @pasteValidTikTokLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a valid TikTok link'**
  String get pasteValidTikTokLink;

  /// No description provided for @importFromInstagram.
  ///
  /// In en, this message translates to:
  /// **'Import from Instagram'**
  String get importFromInstagram;

  /// No description provided for @pasteReelLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a Reel link'**
  String get pasteReelLink;

  /// No description provided for @pasteValidInstagramLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a valid Instagram link'**
  String get pasteValidInstagramLink;

  /// No description provided for @localVideo.
  ///
  /// In en, this message translates to:
  /// **'Local video'**
  String get localVideo;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From your gallery'**
  String get fromGallery;

  /// No description provided for @videoLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'VIDEO LINK'**
  String get videoLinkLabel;

  /// No description provided for @couldNotSendToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not send the pack to WhatsApp.'**
  String get couldNotSendToWhatsApp;

  /// No description provided for @sendingToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Sending to WhatsApp...'**
  String get sendingToWhatsApp;

  /// No description provided for @addCoverFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a cover first'**
  String get addCoverFirst;

  /// No description provided for @needAtLeastThreeStickers.
  ///
  /// In en, this message translates to:
  /// **'You need at least 3 stickers'**
  String get needAtLeastThreeStickers;

  /// No description provided for @addToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Add to WhatsApp'**
  String get addToWhatsApp;

  /// No description provided for @deleteSticker.
  ///
  /// In en, this message translates to:
  /// **'Delete sticker'**
  String get deleteSticker;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'loop'**
  String get loop;

  /// No description provided for @packInfoName.
  ///
  /// In en, this message translates to:
  /// **'Pack name'**
  String get packInfoName;

  /// No description provided for @packInfoAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get packInfoAuthor;

  /// No description provided for @packInfoStickersAdded.
  ///
  /// In en, this message translates to:
  /// **'Stickers added'**
  String get packInfoStickersAdded;

  /// No description provided for @packInfoCover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get packInfoCover;

  /// No description provided for @packInfoStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get packInfoStatus;

  /// No description provided for @packInfoCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get packInfoCreated;

  /// No description provided for @renamePackTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename pack'**
  String get renamePackTitle;

  /// No description provided for @packNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ex: My best moments'**
  String get packNamePlaceholder;

  /// No description provided for @authorNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ex: Carlos R.'**
  String get authorNamePlaceholder;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes →'**
  String get saveChangesButton;

  /// No description provided for @newSticker.
  ///
  /// In en, this message translates to:
  /// **'New sticker'**
  String get newSticker;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go →'**
  String get go;

  /// No description provided for @freeSlots.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get freeSlots;

  /// No description provided for @stickersTab.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get stickersTab;

  /// No description provided for @packInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Pack info'**
  String get packInfoTab;

  /// No description provided for @coverConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured ✓'**
  String get coverConfigured;

  /// No description provided for @noCover.
  ///
  /// In en, this message translates to:
  /// **'No cover'**
  String get noCover;

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete ✓'**
  String get statusComplete;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @processCoverError.
  ///
  /// In en, this message translates to:
  /// **'Could not process the cover.'**
  String get processCoverError;

  /// No description provided for @fullPackWarning.
  ///
  /// In en, this message translates to:
  /// **'This pack is already full. Choose another pack or create a new one.'**
  String get fullPackWarning;

  /// No description provided for @resolvingSharedVideo.
  ///
  /// In en, this message translates to:
  /// **'Resolving shared video...'**
  String get resolvingSharedVideo;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Stikerz!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your own sticker packs from TikTok and Instagram videos, and share them with your friends on WhatsApp.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingAddVideosTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Your Videos'**
  String get onboardingAddVideosTitle;

  /// No description provided for @onboardingAddVideosMethodLink.
  ///
  /// In en, this message translates to:
  /// **'🔗 Paste TikTok or Instagram links directly in the app'**
  String get onboardingAddVideosMethodLink;

  /// No description provided for @onboardingAddVideosMethodGallery.
  ///
  /// In en, this message translates to:
  /// **'📱 Or select videos from your device gallery'**
  String get onboardingAddVideosMethodGallery;

  /// No description provided for @onboardingShareDirectTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Directly from Apps'**
  String get onboardingShareDirectTitle;

  /// No description provided for @onboardingShareDirectDesc.
  ///
  /// In en, this message translates to:
  /// **'The easiest way to extract stickers from your favorite videos'**
  String get onboardingShareDirectDesc;

  /// No description provided for @onboardingShareDirectSteps.
  ///
  /// In en, this message translates to:
  /// **'How to do it:'**
  String get onboardingShareDirectSteps;

  /// No description provided for @onboardingShareDirectStep1.
  ///
  /// In en, this message translates to:
  /// **'Open TikTok or Instagram and find a video you love'**
  String get onboardingShareDirectStep1;

  /// No description provided for @onboardingShareDirectStep2.
  ///
  /// In en, this message translates to:
  /// **'Use the share button and select \"Stikerz\" from the options'**
  String get onboardingShareDirectStep2;

  /// No description provided for @onboardingAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using Stikerz!'**
  String get onboardingAdsTitle;

  /// No description provided for @onboardingAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re grateful for your support! This app is free to use thanks to ads that help us maintain and improve it. Your understanding and patience mean everything to us. Enjoy creating and sharing your stickers! 🎨'**
  String get onboardingAdsDescription;

  /// No description provided for @onboardingFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinishButton;

  /// No description provided for @onboardingNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get onboardingNextButton;

  /// No description provided for @onboardingBackButton.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get onboardingBackButton;

  /// No description provided for @onboardingWelcomeSmallLabel.
  ///
  /// In en, this message translates to:
  /// **'WELCOME TO THE FUTURE'**
  String get onboardingWelcomeSmallLabel;

  /// No description provided for @onboardingWelcomeTitlePrimary.
  ///
  /// In en, this message translates to:
  /// **'Animate'**
  String get onboardingWelcomeTitlePrimary;

  /// No description provided for @onboardingWelcomeTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'Anything'**
  String get onboardingWelcomeTitleAccent;

  /// No description provided for @onboardingContentLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR CONTENT, ANIMATED'**
  String get onboardingContentLabel;

  /// No description provided for @onboardingFromSocialTitlePrimary.
  ///
  /// In en, this message translates to:
  /// **'From Social'**
  String get onboardingFromSocialTitlePrimary;

  /// No description provided for @onboardingFromSocialTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'to Stickers'**
  String get onboardingFromSocialTitleAccent;

  /// No description provided for @onboardingFromSocialDesc.
  ///
  /// In en, this message translates to:
  /// **'Transform your favorite TikTok videos and Instagram Reels into animated WhatsApp stickers in seconds.'**
  String get onboardingFromSocialDesc;

  /// No description provided for @onboardingShareLabel.
  ///
  /// In en, this message translates to:
  /// **'SHARE DIRECTLY'**
  String get onboardingShareLabel;

  /// No description provided for @onboardingShareTitlePrimary.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get onboardingShareTitlePrimary;

  /// No description provided for @onboardingShareTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get onboardingShareTitleAccent;

  /// No description provided for @onboardingShareDescExtended.
  ///
  /// In en, this message translates to:
  /// **'Just hit share on TikTok or IG and send it straight to our app. It takes only a couple taps — fast, preserves quality, and converts clips into animated stickers instantly.'**
  String get onboardingShareDescExtended;

  /// No description provided for @onboardingLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get onboardingLegalPrefix;

  /// No description provided for @onboardingLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get onboardingLegalAnd;

  /// No description provided for @onboardingLegalSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get onboardingLegalSuffix;

  /// No description provided for @permissionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery access required'**
  String get permissionRequiredTitle;

  /// No description provided for @permissionRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'You previously denied access to your videos. To import videos from your gallery, you need to enable permission manually.'**
  String get permissionRequiredDesc;

  /// No description provided for @openSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsButton;

  /// No description provided for @permissionStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Open settings\' below'**
  String get permissionStep1;

  /// No description provided for @permissionStep2.
  ///
  /// In en, this message translates to:
  /// **'Find \'Permissions\' and tap \'Photos & videos\' or \'Media\''**
  String get permissionStep2;

  /// No description provided for @permissionStep3.
  ///
  /// In en, this message translates to:
  /// **'Select \'Allow\' or \'Allow all\''**
  String get permissionStep3;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate app'**
  String get rateApp;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report bug'**
  String get reportBug;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutRole.
  ///
  /// In en, this message translates to:
  /// **'Lead Developer & Designer'**
  String get aboutRole;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Creating fluid and beautiful digital experiences for the world.'**
  String get aboutDescription;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInfo;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeProblem;

  /// No description provided for @describeProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem or provide feedback'**
  String get describeProblemHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'yourname@example.com'**
  String get emailHint;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @alternatively.
  ///
  /// In en, this message translates to:
  /// **'Alternatively'**
  String get alternatively;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your feedback has been sent.'**
  String get feedbackSent;

  /// No description provided for @externalServiceDown.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the external service. It may be temporarily down; please try again later.'**
  String get externalServiceDown;

  /// No description provided for @externalServiceTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again shortly.'**
  String get externalServiceTimeout;

  /// No description provided for @externalServiceInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from external service.'**
  String get externalServiceInvalidResponse;

  /// No description provided for @externalServiceNotVideo.
  ///
  /// In en, this message translates to:
  /// **'The link is not a video. Please choose a valid video.'**
  String get externalServiceNotVideo;

  /// No description provided for @externalServiceVideoNotPublic.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve the video. Please ensure it is public.'**
  String get externalServiceVideoNotPublic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
