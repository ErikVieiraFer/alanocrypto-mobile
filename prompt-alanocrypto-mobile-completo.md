# PROMPT COMPLETO - ALANOCRYPTO MOBILE SETUP
# Copie e cole no Claude Code CLI

═══════════════════════════════════════════════════════════════════════════════
                              CONTEXTO DO PROJETO
═══════════════════════════════════════════════════════════════════════════════

PROJETO: AlanoCryptoFX (em rebranding para AlanoCrypto)
TIPO: Aplicativo de comunidade de trading para membros do canal YouTube do Alano
CLIENTE: Alano Costa

REPOSITÓRIO: C:\Programs\alano\alanocrypto-mobile\alanocrypto
(clonado de github.com/ErikVieiraFer/alanocrypto_teste)

OBJETIVO: Preparar código Flutter para build Android e iOS, com publicação na Play Store e App Store. Este é um repositório UNIFICADO que vai gerar builds para AMBAS as plataformas.

Firebase Project: alanocryptofx-v2
Project Number: 508290889017

═══════════════════════════════════════════════════════════════════════════════
                         REGRAS DE DESENVOLVIMENTO (OBRIGATÓRIO)
═══════════════════════════════════════════════════════════════════════════════

1. SEM COMENTÁRIOS no código - código deve ser autoexplicativo
2. SEM withOpacity() - usar Color.withValues(alpha: x) ou Color.fromRGBO()
3. Arquitetura Feature-First - cada feature isolada em lib/features/
4. Princípios SOLID - código limpo, responsabilidades separadas
5. Nomes em inglês - variáveis, funções, classes
6. UI em português - textos visíveis ao usuário

═══════════════════════════════════════════════════════════════════════════════
                         FUNCIONALIDADES JÁ IMPLEMENTADAS
═══════════════════════════════════════════════════════════════════════════════

✅ Autenticação (Google Sign-In + 2FA por email)
✅ Chat da Comunidade (tempo real, imagens, menções @, reações)
✅ Sinais de Trading (LONG/SHORT, filtros, copiar formatado)
✅ Posts do Alano (vídeos YouTube)
✅ Perfil do Usuário
✅ Notificações (in-app + push Android)
✅ Mercado (crypto, forex, stocks em tempo real)
✅ Cursos
✅ Área Premium "A Cúpula":
   - Chat Exclusivo (imagens clicáveis fullscreen, separadores de data)
   - Sinais Premium
   - Posts Exclusivos
   - Lives (ao vivo + gravadas em carrossel horizontal)
   - Carteira/Portfolio (estilo CoinMarketCap):
     * "Minha Carteira" - cada usuário gerencia a própria
     * "Carteira do Alano" - somente leitura (admins editam)
     * Transações (compra/venda) com busca CoinGecko
     * Gráfico de alocação (pizza/donut)
     * Preços em tempo real via CoinGecko

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 1: DIAGNÓSTICO INICIAL
═══════════════════════════════════════════════════════════════════════════════

Primeiro, verificar o estado atual do projeto:

```powershell
Write-Host "=== Flutter Version ==="
flutter --version

Write-Host "=== Verificando pubspec.yaml ==="
Get-Content pubspec.yaml | Select-Object -First 5

Write-Host "=== Verificando estrutura de pastas ==="
Get-ChildItem -Directory | Select-Object Name

Write-Host "=== Verificando se Carteira está presente ==="
Get-ChildItem lib/features/cupula/screens/ -Filter *portfolio*

Write-Host "=== Verificando imports do package ==="
Select-String -Path lib/main.dart -Pattern "package:" | Select-Object -First 5

Write-Host "=== Android - applicationId atual ==="
Select-String -Path android/app/build.gradle* -Pattern "applicationId|namespace"

Write-Host "=== iOS - Bundle ID atual ==="
Select-String -Path ios/Runner.xcodeproj/project.pbxproj -Pattern "PRODUCT_BUNDLE_IDENTIFIER" | Select-Object -First 3

Write-Host "=== Verificando google-services.json ==="
if (Test-Path android/app/google-services.json) {
    Select-String -Path android/app/google-services.json -Pattern "package_name"
} else {
    Write-Host "Arquivo não encontrado"
}

Write-Host "=== Verificando GoogleService-Info.plist ==="
if (Test-Path ios/Runner/GoogleService-Info.plist) {
    Select-String -Path ios/Runner/GoogleService-Info.plist -Pattern "BUNDLE_ID"
} else {
    Write-Host "Arquivo não encontrado"
}

Write-Host "=== Flutter analyze ==="
flutter analyze --no-fatal-infos 2>&1 | Select-Object -Last 20
```

Reportar:
1. Versão do Flutter
2. Nome do package atual no pubspec.yaml
3. Se a carteira (portfolio) está presente
4. Bundle IDs atuais (Android e iOS)
5. Se os arquivos Firebase estão presentes
6. Quantos erros/warnings no flutter analyze

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 2: PADRONIZAR PACKAGE NAME (DART)
═══════════════════════════════════════════════════════════════════════════════

O package name definitivo é: alanocrypto

Se pubspec.yaml tiver name: alanoapp, alterar para:
```yaml
name: alanocrypto
description: "AlanoCrypto - Comunidade de Trading"
```

E substituir TODOS os imports em lib/ e test/:

```powershell
Get-ChildItem -Recurse -Filter *.dart -Path lib, test | ForEach-Object {
    (Get-Content $_.FullName) -replace 'package:alanoapp/', 'package:alanocrypto/' | Set-Content $_.FullName
}
```

Verificar se restou algum import antigo:
```powershell
Select-String -Path lib/*.dart, lib/**/*.dart -Pattern "package:alanoapp" -Recurse
```

Se encontrar, corrigir manualmente.

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 3: PADRONIZAR BUNDLE ID ANDROID
═══════════════════════════════════════════════════════════════════════════════

Bundle ID definitivo: com.alanocrypto.app

Arquivo: android/app/build.gradle.kts (ou build.gradle)

Se for build.gradle.kts:
```kotlin
android {
    namespace = "com.alanocrypto.app"
    compileSdk = 35
    
    defaultConfig {
        applicationId = "com.alanocrypto.app"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

Se for build.gradle (Groovy):
```groovy
android {
    namespace "com.alanocrypto.app"
    compileSdk 35
    
    defaultConfig {
        applicationId "com.alanocrypto.app"
        minSdk 23
        targetSdk 35
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

Arquivo: android/build.gradle (raiz)
Garantir:
```groovy
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Arquivo: android/gradle/wrapper/gradle-wrapper.properties
```
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
```

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 4: PADRONIZAR BUNDLE ID iOS
═══════════════════════════════════════════════════════════════════════════════

Bundle ID definitivo: com.alanocrypto.app

Arquivo: ios/Runner.xcodeproj/project.pbxproj

Substituir TODAS as ocorrências de Bundle IDs antigos por:
- com.alanocrypto.app (para Runner - Debug, Release, Profile)
- com.alanocrypto.app.RunnerTests (para RunnerTests - Debug, Release, Profile)

Usar buscar/substituir para:
- com.example.alanoapp → com.alanocrypto.app
- com.example.alanoapp.test → com.alanocrypto.app
- com.erikvieirafer.alanoapp → com.alanocrypto.app
- ccom.erikvieira.alanoapp.tests → com.alanocrypto.app.RunnerTests (corrigir typo "ccom")

Verificar com:
```powershell
Select-String -Path ios/Runner.xcodeproj/project.pbxproj -Pattern "PRODUCT_BUNDLE_IDENTIFIER"
```

Deve mostrar APENAS:
- com.alanocrypto.app (para Runner)
- com.alanocrypto.app.RunnerTests (para RunnerTests)

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 5: ATUALIZAR Info.plist (iOS)
═══════════════════════════════════════════════════════════════════════════════

Arquivo: ios/Runner/Info.plist

Alterar CFBundleDisplayName e CFBundleName para "AlanoCrypto"

Garantir que estas permissões estão presentes:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Para enviar fotos no chat</string>
<key>NSCameraUsageDescription</key>
<string>Para tirar fotos no chat</string>
<key>NSMicrophoneUsageDescription</key>
<string>Para gravar mensagens de áudio no chat</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

Manter o CFBundleURLSchemes com o REVERSED_CLIENT_ID:
com.googleusercontent.apps.508290889017-p224pp9boj1t35ril17kv3oh71nof0di

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 6: CONFIGURAR AppDelegate.swift (iOS PUSH)
═══════════════════════════════════════════════════════════════════════════════

PROBLEMA CONHECIDO: Push notifications não funcionam no iOS porque APNs não está configurado corretamente.

Arquivo: ios/Runner/AppDelegate.swift

Substituir conteúdo completo por:

```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    UNUserNotificationCenter.current().delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    
    application.registerForRemoteNotifications()
    
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
```

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 7: ATUALIZAR firebase_options.dart
═══════════════════════════════════════════════════════════════════════════════

Arquivo: lib/firebase_options.dart

Garantir que iosBundleId e androidPackageName usam os novos IDs:

No bloco `static const FirebaseOptions ios`:
- iosBundleId: 'com.alanocrypto.app'

No bloco `static const FirebaseOptions android`:
- Verificar se appId está correto

Se o google-services.json ou GoogleService-Info.plist ainda usam Bundle IDs antigos, os valores em firebase_options.dart devem ser atualizados para refletir com.alanocrypto.app.

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 8: REQUISITO OBRIGATÓRIO - DELETE ACCOUNT
═══════════════════════════════════════════════════════════════════════════════

Obrigatório para App Store e Play Store 2025/2026.

Verificar se existe método deleteAccount em lib/services/user_service.dart

Se não existir, criar:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final uid = user.uid;
    
    await _firestore.collection('users').doc(uid).delete();
    
    final portfolioTransactions = await _firestore
        .collection('cupula_portfolio_transactions')
        .where('oderId', isEqualTo: uid)
        .get();
    
    for (var doc in portfolioTransactions.docs) {
      await doc.reference.delete();
    }
    
    await user.delete();
  }
}
```

Verificar se existe botão "Excluir Conta" na tela de perfil/configurações.

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 9: DISCLAIMER DE INVESTIMENTOS
═══════════════════════════════════════════════════════════════════════════════

Verificar se existe disclaimer de investimentos no primeiro acesso ou na tela de sinais.

Se não existir, criar arquivo: lib/widgets/investment_disclaimer.dart

```dart
import 'package:flutter/material.dart';

class InvestmentDisclaimer extends StatelessWidget {
  final VoidCallback onAccept;

  const InvestmentDisclaimer({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF1a1f25),
      title: Text(
        'Aviso Legal',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Text(
          'Este aplicativo fornece informações educacionais sobre trading e criptomoedas. '
          'Os sinais e análises apresentados NÃO constituem aconselhamento financeiro.\n\n'
          'Trading envolve riscos significativos e você pode perder todo o capital investido. '
          'Nunca invista mais do que pode perder.\n\n'
          'Ao continuar, você reconhece que:\n'
          '• Entende os riscos envolvidos\n'
          '• É responsável por suas próprias decisões de investimento\n'
          '• Este app não garante lucros',
          style: TextStyle(color: Color(0xFF9ca3af), fontSize: 14),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAccept,
          child: Text(
            'Li e Aceito',
            style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
```

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 10: VERIFICAR CARTEIRA DA CÚPULA
═══════════════════════════════════════════════════════════════════════════════

Verificar se todos estes arquivos existem:

```powershell
$files = @(
    "lib/features/cupula/models/portfolio_models.dart",
    "lib/features/cupula/services/cupula_portfolio_service.dart",
    "lib/features/cupula/services/coingecko_portfolio_service.dart",
    "lib/features/cupula/screens/cupula_portfolio_screen.dart",
    "lib/features/cupula/screens/cupula_portfolio_tabs_screen.dart",
    "lib/features/cupula/screens/cupula_alano_portfolio_screen.dart",
    "lib/features/cupula/widgets/add_transaction_modal.dart",
    "lib/features/cupula/widgets/portfolio_allocation_chart.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file"
    } else {
        Write-Host "❌ FALTANDO: $file"
    }
}
```

Se algum estiver faltando, reportar quais.

Verificar se a Carteira está integrada na navegação (5ª aba):
```powershell
Select-String -Path lib/features/cupula/screens/cupula_main_screen.dart -Pattern "CupulaPortfolioTabsScreen|portfolio|Carteira"
```

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 11: CORRIGIR withOpacity()
═══════════════════════════════════════════════════════════════════════════════

Buscar TODOS os usos de withOpacity() e substituir por Color.withValues(alpha:) ou Color.fromRGBO():

```powershell
Select-String -Path lib/*.dart, lib/**/*.dart -Pattern "\.withOpacity\(" -Recurse
```

Exemplos de correção:
- Colors.white.withOpacity(0.5) → Colors.white.withValues(alpha: 0.5)
- Color(0xFF00FF88).withOpacity(0.3) → Color(0xFF00FF88).withValues(alpha: 0.3)
- Colors.black.withOpacity(0.8) → Color.fromRGBO(0, 0, 0, 0.8)

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 12: REMOVER COMENTÁRIOS DESNECESSÁRIOS
═══════════════════════════════════════════════════════════════════════════════

Buscar comentários no código e remover os desnecessários:

```powershell
Select-String -Path lib/*.dart, lib/**/*.dart -Pattern "^\s*//" -Recurse | Select-Object -First 50
```

Remover comentários como:
- // TODO: ...
- // FIXME: ...
- // Este método faz...
- // Comentário explicativo óbvio

MANTER comentários de licença/copyright se existirem.

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 13: BUILD TEST ANDROID
═══════════════════════════════════════════════════════════════════════════════

```powershell
flutter clean
flutter pub get
flutter analyze --no-fatal-infos

# Build debug APK para teste
flutter build apk --debug

# Se sucesso, build release
flutter build apk --release

# Se sucesso, build AAB para Play Store
flutter build appbundle --release
```

Reportar:
- Se build foi sucesso ou falhou
- Se falhou, quais erros
- Tamanho do APK/AAB gerado
- Caminho do arquivo gerado

═══════════════════════════════════════════════════════════════════════════════
                    TAREFA 14: PREPARAR PARA iOS (info apenas)
═══════════════════════════════════════════════════════════════════════════════

NOTA: Build iOS só pode ser feito no Mac com Xcode.

No Mac, os comandos seriam:
```bash
cd ios
pod install --repo-update
cd ..

flutter build ios --release --no-codesign
```

Para testar no simulador:
```bash
flutter run -d "iPhone 15"
```

Para build assinado (requer Apple Developer Account):
```bash
flutter build ipa --release
```

═══════════════════════════════════════════════════════════════════════════════
                           RESULTADO ESPERADO
═══════════════════════════════════════════════════════════════════════════════

Ao final, reportar:

1. ✅/❌ Flutter analyze sem erros críticos
2. ✅/❌ Package name padronizado (alanocrypto) no pubspec.yaml
3. ✅/❌ ZERO ocorrências de "package:alanoapp" em qualquer .dart
4. ✅/❌ Bundle ID Android padronizado (com.alanocrypto.app)
5. ✅/❌ Bundle ID iOS padronizado (com.alanocrypto.app)
6. ✅/❌ Android build APK debug sucesso
7. ✅/❌ Android build APK release sucesso
8. ✅/❌ Android build AAB sucesso
9. ✅/❌ Carteira da Cúpula presente e integrada
10. ✅/❌ Delete Account implementado
11. ✅/❌ Disclaimer de investimentos presente
12. ✅/❌ ZERO usos de withOpacity() (substituídos por withValues ou fromRGBO)
13. ✅/❌ AppDelegate.swift configurado para push notifications
14. Lista de arquivos modificados

═══════════════════════════════════════════════════════════════════════════════
                              CORES DO TEMA
═══════════════════════════════════════════════════════════════════════════════

Usar estas cores para qualquer novo componente:
- Background principal: #111418, #0f0f0f
- Cards: #1a1f25, #22282F
- Verde primário (neon): #00FF88
- Verde secundário: #16a34a
- Texto principal: #FFFFFF
- Texto secundário: #9ca3af
- Erro/Venda: #EF4444
- Compra: #00FF88

═══════════════════════════════════════════════════════════════════════════════
                           UIDs ADMINS (referência)
═══════════════════════════════════════════════════════════════════════════════

Estes UIDs têm permissão especial para editar a "Carteira do Alano":
- Erik: MSnKrBPj5uZK3JK8LsB8CeHLdb82
- Alano: XHMsmRONXcOp3vm7VM3326P1DSt2

═══════════════════════════════════════════════════════════════════════════════
