// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stikerz';

  @override
  String get home => 'Inicio';

  @override
  String get videoPicker => 'Seleccionar Video';

  @override
  String get stickerEditor => 'Editor de Stickers';

  @override
  String get yourPacks => 'Tus Paquetes';

  @override
  String get myStickers => 'Mis Stickers';

  @override
  String get createPack => 'Crear Paquete';

  @override
  String get editPack => 'Editar Paquete';

  @override
  String get deletePack => 'Eliminar Paquete';

  @override
  String get renamePack => 'Renombrar Paquete';

  @override
  String get noPacksTitle => 'Sin Paquetes de Stickers';

  @override
  String get noPacksDesc =>
      'Comparte un video de TikTok o Instagram para crear tu primer paquete';

  @override
  String get galleryLimitedAccessTitle => 'Acceso a Galería Limitado';

  @override
  String get galleryLimitedAccessDesc =>
      'Esta aplicación necesita acceso a todas tus fotos y videos para crear paquetes de stickers desde tu contenido. Por favor, cambia tus configuraciones de permisos.';

  @override
  String get grantAccess => 'Otorgar Acceso Completo';

  @override
  String get selectVideo => 'Seleccionar Video';

  @override
  String get uploadVideo => 'Subir Video';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Listo';

  @override
  String get close => 'Cerrar';

  @override
  String get search => 'Buscar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get warning => 'Advertencia';

  @override
  String get confirming => 'Confirmando...';

  @override
  String get copying => 'Copiando...';

  @override
  String get generating => 'Generando...';

  @override
  String get invalidUrl => 'URL Inválida';

  @override
  String get noInternet => 'Sin conexión a internet';

  @override
  String get permissionDenied => 'Permiso Denegado';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get packName => 'Nombre del Paquete';

  @override
  String get packNameHint => 'Ingresa el nombre del paquete';

  @override
  String get author => 'Autor';

  @override
  String get authorHint => 'Ingresa el nombre del autor';

  @override
  String get emptyFieldError => 'Este campo no puede estar vacío';

  @override
  String get tooLongError => 'El texto es demasiado largo';

  @override
  String get renamingPack => 'Renombrando paquete...';

  @override
  String get deletingPack => 'Eliminando paquete...';

  @override
  String get addedToPack => 'Añadido al paquete';

  @override
  String get failedToAdd => 'Error al añadir al paquete';

  @override
  String get videoNotSupported => 'Este tipo de contenido no es soportado';

  @override
  String get selectValidVideo => 'Por favor selecciona un video válido';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get shareDirectly => 'Comparte directamente desde TikTok o Instagram';

  @override
  String get orSelectFromGallery => 'o selecciona un video de tu galería';

  @override
  String get myCollections => 'MIS COLECCIONES';

  @override
  String get searchPackPlaceholder => 'Buscar paquete...';

  @override
  String get deletePackTitle => 'Eliminar paquete';

  @override
  String deletePackMessage(Object packName) {
    return '¿Eliminar \"$packName\"? Esta acción no se puede deshacer.';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get preparingVideo => 'Preparando tu video';

  @override
  String get convertingLink =>
      'Estamos convirtiendo el enlace para que puedas agregarlo sin pasos extra.';

  @override
  String get createPackFirst => 'Crea primero un paquete';

  @override
  String get createPackHint =>
      'Después de crear tu primer paquete, podrás agregar este video compartido.';

  @override
  String get selectPackTitle => 'Selecciona el paquete';

  @override
  String get selectPackDesc =>
      'El enlace ya está listo. Elige el paquete donde quieres agregarlo.';

  @override
  String get preparingVideoHint =>
      'Estamos preparando el video compartido. Espera un momento.';

  @override
  String get createPackHint2 =>
      'Crea primero un paquete para agregar este video.';

  @override
  String get selectPackHint =>
      'Selecciona el paquete donde quieres agregar este video.';

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
    return 'por $author';
  }

  @override
  String stickerCountStatus(Object count) {
    return '$count / 30 — ¡Listo para WhatsApp!';
  }

  @override
  String stickerCountSimple(Object count) {
    return '$count / 30 stickers';
  }

  @override
  String get newPack => 'Nuevo paquete';

  @override
  String get packNameExample => 'Ej: Mis mejores momentos';

  @override
  String get authorNameLabel => 'NOMBRE DEL AUTOR';

  @override
  String get authorNameExample => 'Ej: Carlos R.';

  @override
  String get createPackButton => 'Crear paquete →';

  @override
  String get packNameLabel => 'NOMBRE DEL PAQUETE';

  @override
  String get noGalleryAccess => 'Sin acceso a la galería';

  @override
  String get galleryAccessNeeded =>
      'Necesitamos acceso a tus videos para crear stickers.';

  @override
  String get giveAccess => 'Dar acceso';

  @override
  String get limitedGalleryAccess => 'Acceso limitado a galería';

  @override
  String get addMoreVideos => 'Toca para agregar más videos';

  @override
  String get noVideosFound => 'No se encontraron videos';

  @override
  String get selectedVideoLabel => 'Seleccionar video';

  @override
  String get selectVideoHint => 'Toca un video para seleccionarlo';

  @override
  String get useThisVideo => 'Usar este video';

  @override
  String packsFound(num count, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados de $total',
      one: '$count resultado de $total',
    );
    return '$_temp0';
  }

  @override
  String packsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquetes',
      one: '$count paquete',
    );
    return '$_temp0';
  }

  @override
  String get loadingVideo => 'Cargando video...';

  @override
  String get instagramLoadingNote =>
      'Esto puede tardar unos segundos con Instagram';

  @override
  String videoOpenError(Object error) {
    return 'No se pudo abrir el video: $error';
  }

  @override
  String get stickerEditorTitle => 'Editor de Sticker';

  @override
  String startTime(Object time) {
    return '⏱ $time';
  }

  @override
  String totalDuration(Object time) {
    return '$time total';
  }

  @override
  String get startPointLabel => 'Punto de inicio';

  @override
  String get durationLabel => 'Duración';

  @override
  String durationValue(Object value) {
    return '${value}s';
  }

  @override
  String get creatingSticker => 'Creando sticker...';

  @override
  String get generateAnimatedSticker => 'Generar Sticker Animado';

  @override
  String get stickerLimits => 'Máx. 5s · 500KB · formato WebP animado';

  @override
  String get generateStickerTitle => 'Generar sticker';

  @override
  String get aspectLabel => 'Aspecto';

  @override
  String get startLabel => 'Inicio';

  @override
  String get durationShort => 'Duración';

  @override
  String get generateButton => 'Generar';

  @override
  String get couldNotCreateSticker => 'No se pudo crear el sticker';

  @override
  String get videoTooComplex =>
      'El video tiene demasiados detalles y supera el límite de tamaño.';

  @override
  String get reduceSelectionArea => 'Reduce el área de selección';

  @override
  String get shortenClipDuration => 'Acorta la duración del clip';

  @override
  String get blurReduceFps => 'Blur + reducir FPS (Recomendado)';

  @override
  String get blurMildTenFps => 'Blur leve + 10 FPS';

  @override
  String get smoothDetails => 'Suavizar detalles';

  @override
  String get applyMildBlur => 'Aplica blur leve';

  @override
  String get reduceFpsLabel => 'Reducir FPS';

  @override
  String get reduceTo10Fps => 'Baja a 10 FPS';

  @override
  String get moreTransparency => 'Más transparencia';

  @override
  String get reduceVisibleArea => 'Reduce área visible';

  @override
  String get tryAnotherStrategy => 'Prueba otra estrategia';

  @override
  String get importFromTikTok => 'Importar de TikTok';

  @override
  String get stickerTooHeavy => 'El sticker es muy pesado';

  @override
  String needToReduce(int amount) {
    return 'Reduce ${amount}KB más para cumplir el límite de 500KB';
  }

  @override
  String get pasteVideoLink => 'Pega un enlace del video';

  @override
  String get pasteValidTikTokLink => 'Pega un enlace válido de TikTok';

  @override
  String get importFromInstagram => 'Importar de Instagram';

  @override
  String get pasteReelLink => 'Pega un enlace del Reel';

  @override
  String get pasteValidInstagramLink => 'Pega un enlace válido de Instagram';

  @override
  String get localVideo => 'Video local';

  @override
  String get fromGallery => 'Desde tu galería';

  @override
  String get videoLinkLabel => 'ENLACE DEL VIDEO';

  @override
  String get couldNotSendToWhatsApp =>
      'No se pudo enviar el paquete a WhatsApp.';

  @override
  String get sendingToWhatsApp => 'Enviando a WhatsApp...';

  @override
  String get addCoverFirst => 'Agrega una portada primero';

  @override
  String get needAtLeastThreeStickers => 'Necesitas al menos 3 stickers';

  @override
  String get addToWhatsApp => 'Agregar a WhatsApp';

  @override
  String get deleteSticker => 'Eliminar sticker';

  @override
  String get loop => 'loop';

  @override
  String get packInfoName => 'Nombre del paquete';

  @override
  String get packInfoAuthor => 'Autor';

  @override
  String get packInfoStickersAdded => 'Stickers agregados';

  @override
  String get packInfoCover => 'Portada';

  @override
  String get packInfoStatus => 'Estado';

  @override
  String get packInfoCreated => 'Creado';

  @override
  String get renamePackTitle => 'Renombrar paquete';

  @override
  String get packNamePlaceholder => 'Ej: Mis mejores momentos';

  @override
  String get authorNamePlaceholder => 'Ej: Carlos R.';

  @override
  String get saveChangesButton => 'Guardar cambios →';

  @override
  String get newSticker => 'Nuevo sticker';

  @override
  String get paste => 'Pegar';

  @override
  String get go => 'Ir →';

  @override
  String get freeSlots => 'libres';

  @override
  String get stickersTab => 'Stickers';

  @override
  String get packInfoTab => 'Info del pack';

  @override
  String get coverConfigured => 'Configurada ✓';

  @override
  String get noCover => 'Sin portada';

  @override
  String get statusComplete => 'Completo ✓';

  @override
  String get statusInProgress => 'En progreso';

  @override
  String get processCoverError => 'No se pudo procesar la portada.';

  @override
  String get fullPackWarning =>
      'Este paquete ya está lleno. Elige otro paquete o crea uno nuevo.';

  @override
  String get resolvingSharedVideo => 'Resolviendo video compartido...';

  @override
  String get onboardingWelcomeTitle => '¡Bienvenido a Stikerz!';

  @override
  String get onboardingWelcomeDesc =>
      'Crea tus propios paquetes de stickers a partir de videos de TikTok e Instagram, y compártelos con tus amigos en WhatsApp.';

  @override
  String get onboardingAddVideosTitle => 'Agrega Tus Videos';

  @override
  String get onboardingAddVideosMethodLink =>
      '🔗 Pega enlaces de TikTok o Instagram directamente en la app';

  @override
  String get onboardingAddVideosMethodGallery =>
      '📱 O selecciona videos de tu galería del dispositivo';

  @override
  String get onboardingShareDirectTitle => 'Comparte Directamente desde Apps';

  @override
  String get onboardingShareDirectDesc =>
      'La forma más fácil de extraer stickers de tus videos favoritos';

  @override
  String get onboardingShareDirectSteps => 'Cómo hacerlo:';

  @override
  String get onboardingShareDirectStep1 =>
      'Abre TikTok o Instagram y encuentra un video que te encante';

  @override
  String get onboardingShareDirectStep2 =>
      'Usa el botón de compartir y selecciona \"Stikerz\" de las opciones';

  @override
  String get onboardingAdsTitle => '¡Gracias por usar Stikerz!';

  @override
  String get onboardingAdsDescription =>
      '¡Apreciamos tu apoyo! Esta app es gratuita gracias a los anuncios que nos ayudan a mantenerla y mejorarla. Tu comprensión y paciencia significan mucho para nosotros. ¡Disfruta creando y compartiendo tus stickers! 🎨';

  @override
  String get onboardingFinishButton => 'Finalizar';

  @override
  String get onboardingNextButton => 'Siguiente →';

  @override
  String get onboardingBackButton => '← Atrás';

  @override
  String get onboardingWelcomeSmallLabel => 'BIENVENIDO AL FUTURO';

  @override
  String get onboardingWelcomeTitlePrimary => 'Anima';

  @override
  String get onboardingWelcomeTitleAccent => 'Cualquier cosa';

  @override
  String get onboardingContentLabel => 'TU CONTENIDO, ANIMADO';

  @override
  String get onboardingFromSocialTitlePrimary => 'De Social';

  @override
  String get onboardingFromSocialTitleAccent => 'a Stickers';

  @override
  String get onboardingFromSocialDesc =>
      'Transforma tus videos favoritos de TikTok y Reels de Instagram en stickers animados para WhatsApp en segundos.';

  @override
  String get onboardingShareLabel => 'COMPARTE DIRECTAMENTE';

  @override
  String get onboardingShareTitlePrimary => 'Directo';

  @override
  String get onboardingShareTitleAccent => 'Compartir';

  @override
  String get onboardingShareDescExtended =>
      'Simplemente usa el botón compartir en TikTok o IG y envíalo directamente a nuestra app. Son solo un par de toques — rápido, preserva la calidad y convierte clips en stickers animados al instante.';

  @override
  String get onboardingLegalPrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get onboardingLegalAnd => ' y nuestra ';

  @override
  String get onboardingLegalSuffix => '.';

  @override
  String get permissionRequiredTitle => 'Acceso a la galería requerido';

  @override
  String get permissionRequiredDesc =>
      'Previamente negaste acceso a tus videos. Para importar videos de tu galería, necesitas habilitar el permiso manualmente.';

  @override
  String get openSettingsButton => 'Abrir ajustes';

  @override
  String get permissionStep1 => 'Toca \'Abrir ajustes\' abajo';

  @override
  String get permissionStep2 =>
      'Encuentra \'Permisos\' y toca \'Fotos y videos\' o \'Contenido multimedia\'';

  @override
  String get permissionStep3 => 'Selecciona \'Permitir\' o \'Permitir todos\'';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get useDeviceLanguage => 'Usar idioma del dispositivo';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get rateApp => 'Valorar la app';

  @override
  String get reportBug => 'Reportar un error';

  @override
  String get aboutDeveloper => 'Sobre el desarrollador';

  @override
  String get aboutRole => 'Desarrollador y Diseñador Principal';

  @override
  String get aboutDescription =>
      'Creando experiencias digitales fluidas y hermosas para el mundo.';

  @override
  String get versionLabel => 'Versión';

  @override
  String get bugReport => 'Reporte de errores';

  @override
  String get deviceInfo => 'Información del dispositivo';

  @override
  String get describeProblem => 'Describe el problema';

  @override
  String get describeProblemHint =>
      'Describe tu problema o proporciona comentarios';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'tu.correo@ejemplo.com';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get alternatively => 'Alternativamente';

  @override
  String get sendEmail => 'Enviar correo';

  @override
  String get feedbackSent => '¡Gracias! Tu comentario ha sido enviado.';

  @override
  String get externalServiceDown =>
      'No se pudo conectar con el servicio externo. Puede estar temporalmente caído; inténtalo más tarde.';

  @override
  String get externalServiceTimeout =>
      'Tiempo de espera agotado. Intenta de nuevo en unos instantes.';

  @override
  String get externalServiceInvalidResponse =>
      'Respuesta inválida del servidor externo.';

  @override
  String get externalServiceNotVideo =>
      'El enlace no corresponde a un video. Elige un video válido.';

  @override
  String get externalServiceVideoNotPublic =>
      'No se pudo obtener el video. Verifica que sea público.';

  @override
  String get videoPreparationTitle => 'Procesando vídeo';

  @override
  String get videoPreparationDefault =>
      'El procesamiento del vídeo depende de la conexión de internet.';

  @override
  String get videoPreparationSlow =>
      'Seguimos preparando el vídeo. Si tarda, tu conexión puede estar lenta.';

  @override
  String get videoPreparationVerySlow =>
      'La conexión parece lenta. Seguimos intentando preparar el vídeo.';

  @override
  String get videoPreparationTooLong =>
      'Esto está tardando más de lo normal. Una conexión débil puede aumentar la espera.';

  @override
  String videoPreparationRetrying(int attempt, int maxAttempts) {
    return 'Se perdió la conexión. Reintentando ($attempt/$maxAttempts)...';
  }

  @override
  String get staticImage => 'Imagen estática';

  @override
  String get staticImageDescription => 'Desde tu galería';

  @override
  String get imageEditorTitle => 'Editor de Imagen';

  @override
  String get cropTypeRectangle => 'Rectángulo';

  @override
  String get cropTypeCircle => 'Círculo';

  @override
  String get cropTypeFreeForm => 'Trazo libre';

  @override
  String get cropTypeSmart => 'Recorte inteligente';

  @override
  String get cropTypeSmartComingSoon => 'Recorte inteligente (Próximamente)';

  @override
  String get generateStaticSticker => 'Generar Sticker';

  @override
  String get processingImage => 'Procesando imagen...';

  @override
  String get removeAdsTitle => 'Eliminar anuncios';

  @override
  String get oneTimePayment => 'pago único';

  @override
  String get removeAdsBenefit1 => 'Sin banner en la pantalla principal';

  @override
  String get removeAdsBenefit2 => 'Sin anuncios a pantalla completa';

  @override
  String get removeAdsBenefit3 => 'Experiencia limpia en toda la app';

  @override
  String buyForPrice(Object price) {
    return 'Comprar por $price';
  }

  @override
  String get notAvailable => 'No disponible';

  @override
  String get loadingPrice => 'Cargando precio…';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get noAdsBadge => 'SIN ANUNCIOS';

  @override
  String get premiumThanks => '¡Gracias por apoyar la app! ';

  @override
  String get premiumDescription =>
      'Disfruta de la experiencia sin interrupciones';

  @override
  String get addStickerFromDevice => 'Desde tu dispositivo';

  @override
  String get addStickerFromDeviceSubtitle =>
      'Elege un video o imagen de tu galería';

  @override
  String get addStickerFromSocial => 'Desde redes sociales';

  @override
  String get addStickerFromSocialSubtitle =>
      'Pega un enlace de TikTok o Instagram Reel';

  @override
  String get addStickerVideo => 'Video';

  @override
  String get addStickerVideoSubtitle => 'Elege un video de tu galería';

  @override
  String get addStickerImage => 'Imagen';

  @override
  String get addStickerImageSubtitle => 'Elege una imagen de tu galería';

  @override
  String addStickerPasteLinkHint(Object platform) {
    return 'Pega el enlace del $platform Reel o Video';
  }

  @override
  String get imageEditorTraceShapeFirst => 'Traza una forma primero.';

  @override
  String get imageEditorTraceOutline => 'Traza el contorno';

  @override
  String get imageEditorAdjustCrop => 'Ajustar recorte';

  @override
  String get imageEditorTraceShape => 'Trazar forma';

  @override
  String get imageEditorCouldNotCreate => 'No se pudo crear el sticker.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsSupport => 'Soporte';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsBuyMeCoffee => 'Buy Me a Coffee';

  @override
  String get settingsOpenLinkError => 'No se pudo abrir el enlace';

  @override
  String get cropToolbarFullscreen => 'Pantalla completa';

  @override
  String get freeFormTraceInstruction =>
      'Traza el contorno sin levantar el dedo';

  @override
  String get editorSlowConnectionRetrying => 'Conexión lenta — reintentando…';

  @override
  String get smartCropNoSubjectDetectedGenerate =>
      'No se detectó ningún sujeto. Usa primero Recorte Automático.';

  @override
  String get smartCropPreviewTitle => 'Vista previa del recorte automático';

  @override
  String get smartCropDetectionFailedSnackbar =>
      'No se pudo detectar el sujeto. Prueba con otra foto.';

  @override
  String smartCropErrorMessage(String error) {
    return 'Error en el recorte automático: $error';
  }

  @override
  String get smartCropDetectingSubject => 'Detectando sujeto...';

  @override
  String get smartCropNoSubjectFallbackMessage =>
      'No se detectó ningún sujeto. Prueba con otra foto.';
}
