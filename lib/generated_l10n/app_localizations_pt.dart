// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Whaticker';

  @override
  String get home => 'Início';

  @override
  String get videoPicker => 'Selecionar Vídeo';

  @override
  String get stickerEditor => 'Editor de Adesivos';

  @override
  String get yourPacks => 'Seus Pacotes';

  @override
  String get myStickers => 'Meus Adesivos';

  @override
  String get createPack => 'Criar Pacote';

  @override
  String get editPack => 'Editar Pacote';

  @override
  String get deletePack => 'Excluir Pacote';

  @override
  String get renamePack => 'Renomear Pacote';

  @override
  String get noPacksTitle => 'Nenhum Pacote de Adesivos Ainda';

  @override
  String get noPacksDesc =>
      'Compartilhe um vídeo do TikTok ou Instagram para criar seu primeiro pacote';

  @override
  String get galleryLimitedAccessTitle => 'Acesso à Galeria Limitado';

  @override
  String get galleryLimitedAccessDesc =>
      'Este aplicativo precisa acessar todas as suas fotos e vídeos para criar pacotes de adesivos a partir de sua mídia. Por favor, altere suas configurações de permissão.';

  @override
  String get grantAccess => 'Conceder Acesso Completo';

  @override
  String get selectVideo => 'Selecionar Vídeo';

  @override
  String get uploadVideo => 'Carregar Vídeo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Pronto';

  @override
  String get close => 'Fechar';

  @override
  String get search => 'Pesquisar';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get warning => 'Aviso';

  @override
  String get confirming => 'Confirmando...';

  @override
  String get copying => 'Copiando...';

  @override
  String get generating => 'Gerando...';

  @override
  String get invalidUrl => 'URL Inválida';

  @override
  String get noInternet => 'Sem conexão com a internet';

  @override
  String get permissionDenied => 'Permissão Negada';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get packName => 'Nome do Pacote';

  @override
  String get packNameHint => 'Digite o nome do pacote';

  @override
  String get author => 'Autor';

  @override
  String get authorHint => 'Digite o nome do autor';

  @override
  String get emptyFieldError => 'Este campo não pode estar vazio';

  @override
  String get tooLongError => 'O texto é muito longo';

  @override
  String get renamingPack => 'Renomeando pacote...';

  @override
  String get deletingPack => 'Excluindo pacote...';

  @override
  String get addedToPack => 'Adicionado ao pacote';

  @override
  String get failedToAdd => 'Falha ao adicionar ao pacote';

  @override
  String get videoNotSupported => 'Este tipo de mídia não é suportado';

  @override
  String get selectValidVideo => 'Por favor, selecione um vídeo válido';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get errorOccurred => 'Ocorreu um erro';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get shareDirectly => 'Compartilhe diretamente do TikTok ou Instagram';

  @override
  String get orSelectFromGallery => 'ou selecione um vídeo de sua galeria';

  @override
  String get myCollections => 'MINHAS COLEÇÕES';

  @override
  String get searchPackPlaceholder => 'Pesquisar pacote...';

  @override
  String get deletePackTitle => 'Excluir pacote';

  @override
  String deletePackMessage(Object packName) {
    return 'Excluir \"$packName\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get discard => 'Descartar';

  @override
  String get preparingVideo => 'Preparando seu vídeo';

  @override
  String get convertingLink =>
      'Estamos convertendo o link para que você possa adicioná-lo sem etapas extras.';

  @override
  String get createPackFirst => 'Crie um pacote primeiro';

  @override
  String get createPackHint =>
      'Depois de criar seu primeiro pacote, você poderá adicionar este vídeo compartilhado.';

  @override
  String get selectPackTitle => 'Selecione o pacote';

  @override
  String get selectPackDesc =>
      'O link está pronto. Escolha o pacote onde deseja adicioná-lo.';

  @override
  String get preparingVideoHint =>
      'Estamos preparando o vídeo compartilhado. Por favor, aguarde um momento.';

  @override
  String get createPackHint2 =>
      'Crie um pacote primeiro para adicionar este vídeo.';

  @override
  String get selectPackHint =>
      'Selecione o pacote onde deseja adicionar este vídeo.';

  @override
  String stickersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adesivos',
      one: '$count adesivo',
    );
    return '$_temp0';
  }

  @override
  String packCountByAuthor(Object author) {
    return 'por $author';
  }

  @override
  String stickerCountStatus(Object count) {
    return '$count / 30 — Pronto para WhatsApp!';
  }

  @override
  String stickerCountSimple(Object count) {
    return '$count / 30 adesivos';
  }

  @override
  String get newPack => 'Novo pacote';

  @override
  String get packNameExample => 'Ex: Meus melhores momentos';

  @override
  String get authorNameLabel => 'NOME DO AUTOR';

  @override
  String get authorNameExample => 'Ex: Carlos R.';

  @override
  String get createPackButton => 'Criar pacote →';

  @override
  String get packNameLabel => 'NOME DO PACOTE';

  @override
  String get noGalleryAccess => 'Sem acesso à galeria';

  @override
  String get galleryAccessNeeded =>
      'Precisamos de acesso aos seus vídeos para criar adesivos.';

  @override
  String get giveAccess => 'Dar acesso';

  @override
  String get limitedGalleryAccess => 'Acesso limitado à galeria';

  @override
  String get addMoreVideos => 'Toque para adicionar mais vídeos';

  @override
  String get noVideosFound => 'Nenhum vídeo encontrado';

  @override
  String get selectedVideoLabel => 'Selecionar vídeo';

  @override
  String get selectVideoHint => 'Toque em um vídeo para selecioná-lo';

  @override
  String get useThisVideo => 'Usar este vídeo';

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
      other: '$count pacotes',
      one: '$count pacote',
    );
    return '$_temp0';
  }

  @override
  String get loadingVideo => 'Carregando vídeo...';

  @override
  String get instagramLoadingNote =>
      'Isso pode levar alguns segundos com Instagram';

  @override
  String videoOpenError(Object error) {
    return 'Não foi possível abrir o vídeo: $error';
  }

  @override
  String get stickerEditorTitle => 'Editor de Adesivo';

  @override
  String startTime(Object time) {
    return '⏱ $time';
  }

  @override
  String totalDuration(Object time) {
    return '$time total';
  }

  @override
  String get startPointLabel => 'Ponto de início';

  @override
  String get durationLabel => 'Duração';

  @override
  String durationValue(Object value) {
    return '${value}s';
  }

  @override
  String get creatingSticker => 'Criando adesivo...';

  @override
  String get generateAnimatedSticker => 'Gerar Adesivo Animado';

  @override
  String get stickerLimits => 'Máx. 5s · 500KB · formato WebP animado';

  @override
  String get generateStickerTitle => 'Gerar adesivo';

  @override
  String get aspectLabel => 'Aspecto';

  @override
  String get startLabel => 'Início';

  @override
  String get durationShort => 'Duração';

  @override
  String get generateButton => 'Gerar';

  @override
  String get couldNotCreateSticker => 'Não foi possível criar o adesivo';

  @override
  String get videoTooComplex =>
      'O vídeo tem muitos detalhes e excede o limite de tamanho.';

  @override
  String get reduceSelectionArea => 'Reduza a área de seleção';

  @override
  String get shortenClipDuration => 'Encurte a duração do clipe';

  @override
  String get blurReduceFps => 'Blur + reduzir FPS (Recomendado)';

  @override
  String get blurMildTenFps => 'Blur leve + 10 FPS';

  @override
  String get smoothDetails => 'Suavizar detalhes';

  @override
  String get applyMildBlur => 'Aplica blur leve';

  @override
  String get reduceFpsLabel => 'Reduzir FPS';

  @override
  String get reduceTo10Fps => 'Reduzir para 10 FPS';

  @override
  String get moreTransparency => 'Mais transparência';

  @override
  String get reduceVisibleArea => 'Reduz área visível';

  @override
  String get tryAnotherStrategy => 'Tente outra estratégia';

  @override
  String get importFromTikTok => 'Importar do TikTok';

  @override
  String get stickerTooHeavy => 'O adesivo está muito pesado';

  @override
  String needToReduce(int amount) {
    return 'Reduza mais ${amount}KB para cumprir o limite de 500KB';
  }

  @override
  String get pasteVideoLink => 'Cole um link de vídeo';

  @override
  String get pasteValidTikTokLink => 'Cole um link válido do TikTok';

  @override
  String get importFromInstagram => 'Importar do Instagram';

  @override
  String get pasteReelLink => 'Cole um link do Reel';

  @override
  String get pasteValidInstagramLink => 'Cole um link válido do Instagram';

  @override
  String get localVideo => 'Vídeo local';

  @override
  String get fromGallery => 'De sua galeria';

  @override
  String get videoLinkLabel => 'LINK DO VÍDEO';

  @override
  String get couldNotSendToWhatsApp =>
      'Não foi possível enviar o pacote para o WhatsApp.';

  @override
  String get sendingToWhatsApp => 'Enviando para WhatsApp...';

  @override
  String get addCoverFirst => 'Adicione uma capa primeiro';

  @override
  String get needAtLeastThreeStickers =>
      'Você precisa de pelo menos 3 adesivos';

  @override
  String get addToWhatsApp => 'Adicionar ao WhatsApp';

  @override
  String get deleteSticker => 'Excluir adesivo';

  @override
  String get loop => 'loop';

  @override
  String get packInfoName => 'Nome do pacote';

  @override
  String get packInfoAuthor => 'Autor';

  @override
  String get packInfoStickersAdded => 'Adesivos adicionados';

  @override
  String get packInfoCover => 'Capa';

  @override
  String get packInfoStatus => 'Status';

  @override
  String get packInfoCreated => 'Criado';

  @override
  String get renamePackTitle => 'Renomear pacote';

  @override
  String get packNamePlaceholder => 'Ex: Meus melhores momentos';

  @override
  String get authorNamePlaceholder => 'Ex: Carlos R.';

  @override
  String get saveChangesButton => 'Salvar alterações →';

  @override
  String get newSticker => 'Novo adesivo';

  @override
  String get paste => 'Colar';

  @override
  String get go => 'Ir →';

  @override
  String get freeSlots => 'livres';

  @override
  String get stickersTab => 'Adesivos';

  @override
  String get packInfoTab => 'Info do pacote';

  @override
  String get coverConfigured => 'Configurada ✓';

  @override
  String get noCover => 'Sem capa';

  @override
  String get statusComplete => 'Completo ✓';

  @override
  String get statusInProgress => 'Em progresso';

  @override
  String get processCoverError => 'Não foi possível processar a capa.';

  @override
  String get fullPackWarning =>
      'Este pacote já está cheio. Escolha outro pacote ou crie um novo.';

  @override
  String get resolvingSharedVideo => 'Resolvendo vídeo compartilhado...';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao Whaticker!';

  @override
  String get onboardingWelcomeDesc =>
      'Crie seus próprios pacotes de adesivos a partir de vídeos do TikTok e Instagram, e compartilhe com seus amigos no WhatsApp.';

  @override
  String get onboardingAddVideosTitle => 'Adicione Seus Vídeos';

  @override
  String get onboardingAddVideosMethodLink =>
      '🔗 Cole links do TikTok ou Instagram diretamente no app';

  @override
  String get onboardingAddVideosMethodGallery =>
      '📱 Ou selecione vídeos da galeria do seu dispositivo';

  @override
  String get onboardingShareDirectTitle => 'Compartilhe Diretamente dos Apps';

  @override
  String get onboardingShareDirectDesc =>
      'A maneira mais fácil de extrair adesivos de seus vídeos favoritos';

  @override
  String get onboardingShareDirectSteps => 'Como fazer:';

  @override
  String get onboardingShareDirectStep1 =>
      'Abra TikTok ou Instagram e encontre um vídeo que você ama';

  @override
  String get onboardingShareDirectStep2 =>
      'Use o botão de compartilhamento e selecione \"Whaticker\" das opções';

  @override
  String get onboardingAdsTitle => 'Obrigado por usar o Whaticker!';

  @override
  String get onboardingAdsDescription =>
      'Agradecemos seu apoio! Este app é gratuito graças aos anúncios que nos ajudam a mantê-lo e melhorá-lo. Sua compreensão e paciência significam muito para nós. Aproveite criando e compartilhando seus adesivos! 🎨';

  @override
  String get onboardingFinishButton => 'Finalizar';

  @override
  String get onboardingNextButton => 'Próximo →';

  @override
  String get onboardingBackButton => '← Voltar';

  @override
  String get onboardingWelcomeSmallLabel => 'BEM-VINDO AO FUTURO';

  @override
  String get onboardingWelcomeTitlePrimary => 'Anime';

  @override
  String get onboardingWelcomeTitleAccent => 'Qualquer coisa';

  @override
  String get onboardingContentLabel => 'SEU CONTEÚDO, ANIMADO';

  @override
  String get onboardingFromSocialTitlePrimary => 'Do social';

  @override
  String get onboardingFromSocialTitleAccent => 'para stickers';

  @override
  String get onboardingFromSocialDesc =>
      'Transforme seus vídeos favoritos do TikTok e Reels do Instagram em adesivos animados do WhatsApp em segundos.';

  @override
  String get onboardingShareLabel => 'COMPARTILHE DIRETAMENTE';

  @override
  String get onboardingShareTitlePrimary => 'Direto';

  @override
  String get onboardingShareTitleAccent => 'Compartilhar';

  @override
  String get onboardingShareDescExtended =>
      'Basta tocar em compartilhar no TikTok ou IG e enviar diretamente para nosso app. São apenas alguns toques — rápido, preserva a qualidade e converte clipes em adesivos animados instantaneamente.';

  @override
  String get onboardingLegalPrefix => 'Ao continuar, você concorda com nossos ';

  @override
  String get onboardingLegalAnd => ' e com nossa ';

  @override
  String get onboardingLegalSuffix => '.';

  @override
  String get permissionRequiredTitle => 'Acesso à galeria necessário';

  @override
  String get permissionRequiredDesc =>
      'Anteriormente você negou acesso aos seus vídeos. Para importar vídeos da sua galeria, você precisa habilitar a permissão manualmente.';

  @override
  String get openSettingsButton => 'Abrir configurações';

  @override
  String get permissionStep1 => 'Toque em \'Abrir configurações\' abaixo';

  @override
  String get permissionStep2 =>
      'Encontre \'Permissões\' e toque em \'Fotos e vídeos\' ou \'Mídia\'';

  @override
  String get permissionStep3 => 'Selecione \'Permitir\' ou \'Permitir todos\'';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get changeLanguage => 'Mudar idioma';

  @override
  String get useDeviceLanguage => 'Usar o idioma do dispositivo';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get termsAndConditions => 'Termos e Condições';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get rateApp => 'Avaliar app';

  @override
  String get reportBug => 'Reportar bug';

  @override
  String get aboutDeveloper => 'Sobre o desenvolvedor';

  @override
  String get aboutRole => 'Desenvolvedor e Designer Principal';

  @override
  String get aboutDescription =>
      'Criando experiências digitais fluidas e bonitas para o mundo.';

  @override
  String get versionLabel => 'Versão';

  @override
  String get bugReport => 'Relatório de erro';

  @override
  String get deviceInfo => 'Informações do dispositivo';

  @override
  String get describeProblem => 'Descreva o problema';

  @override
  String get describeProblemHint =>
      'Descreva seu problema ou forneça comentários';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'seu.email@exemplo.com';

  @override
  String get sendFeedback => 'Enviar comentários';

  @override
  String get alternatively => 'Alternativamente';

  @override
  String get sendEmail => 'Enviar email';

  @override
  String get feedbackSent => 'Obrigado! Seus comentários foram enviados.';

  @override
  String get externalServiceDown =>
      'Não foi possível conectar ao serviço externo. Pode estar temporariamente fora do ar; tente novamente mais tarde.';

  @override
  String get externalServiceTimeout =>
      'Tempo de espera esgotado. Tente novamente em instantes.';

  @override
  String get externalServiceInvalidResponse =>
      'Resposta inválida do serviço externo.';

  @override
  String get externalServiceNotVideo =>
      'O link não é um vídeo. Escolha um vídeo válido.';

  @override
  String get externalServiceVideoNotPublic =>
      'Não foi possível obter o vídeo. Verifique se está público.';

  @override
  String get videoPreparationTitle => 'Processando vídeo';

  @override
  String get videoPreparationDefault =>
      'O processamento do vídeo depende da sua conexão com a internet.';

  @override
  String get videoPreparationSlow =>
      'Ainda estamos preparando o vídeo. Se demorar, sua conexão pode estar lenta.';

  @override
  String get videoPreparationVerySlow =>
      'A conexão parece lenta. Seguimos tentando preparar o vídeo.';

  @override
  String get videoPreparationTooLong =>
      'Isso está demorando mais do que o normal. Uma conexão fraca pode aumentar a espera.';

  @override
  String videoPreparationRetrying(int attempt, int maxAttempts) {
    return 'A conexão caiu. Tentando novamente ($attempt/$maxAttempts)...';
  }

  @override
  String get staticImage => 'Imagem estática';

  @override
  String get staticImageDescription => 'Da sua galeria';

  @override
  String get imageEditorTitle => 'Editor de Imagem';

  @override
  String get cropTypeRectangle => 'Retângulo';

  @override
  String get cropTypeCircle => 'Círculo';

  @override
  String get cropTypeFreeForm => 'Traço livre';

  @override
  String get cropTypeSmart => 'Recorte inteligente';

  @override
  String get cropTypeSmartComingSoon => 'Recorte inteligente (Em breve)';

  @override
  String get generateStaticSticker => 'Gerar Adesivo';

  @override
  String get processingImage => 'Processando imagem...';

  @override
  String get removeAdsTitle => 'Remover anúncios';

  @override
  String get oneTimePayment => 'pagamento único';

  @override
  String get removeAdsBenefit1 => 'Sem banner na tela inicial';

  @override
  String get removeAdsBenefit2 => 'Sem anúncios em tela cheia';

  @override
  String get removeAdsBenefit3 => 'Experiência limpa em todo o app';

  @override
  String buyForPrice(Object price) {
    return 'Comprar por $price';
  }

  @override
  String get notAvailable => 'Indisponível';

  @override
  String get loadingPrice => 'Carregando preço…';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get premiumActive => 'Premium ativo';

  @override
  String get noAdsBadge => 'SEM ANÚNCIOS';

  @override
  String get premiumThanks => 'Obrigado por apoiar o app!';

  @override
  String get premiumDescription => 'Aproveite a experiência sem interrupções';
}
