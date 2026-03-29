import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        elevation: 0,
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            _buildLastUpdate(),
            const SizedBox(height: 24),
            _buildSection(
              'Introdução',
              'A AlanoCryptoFX ("nós", "nosso" ou "aplicativo") está comprometida em proteger sua privacidade. Esta Política de Privacidade explica como coletamos, usamos, armazenamos e protegemos suas informações pessoais quando você usa nosso aplicativo.',
            ),
            _buildSection(
              'Informações que Coletamos',
              '''Coletamos os seguintes tipos de informações:

• Nome: Para identificação no perfil e comunidade
• Email: Para autenticação, login e verificação em duas etapas
• Número de Telefone: Para contato e suporte ao cliente
• ID do Telegram: Para integração com nosso bot e comunidade
• Fotos e Vídeos: Quando você envia imagens no chat ou atualiza foto de perfil
• Áudio: Quando você envia mensagens de áudio no chat
• Dados de Uso: Informações sobre como você interage com o app
• Dados de Diagnóstico: Logs de erro e performance para melhorar o app''',
            ),
            _buildSection(
              'Como Usamos suas Informações',
              '''Utilizamos suas informações para:

• Fornecer e manter nossos serviços
• Autenticar sua conta e garantir segurança
• Permitir comunicação na comunidade
• Enviar notificações sobre sinais de trading
• Processar sua assinatura premium
• Melhorar nossos serviços e experiência do usuário
• Fornecer suporte ao cliente
• Cumprir obrigações legais''',
            ),
            _buildSection(
              'Compartilhamento de Dados',
              '''Não vendemos suas informações pessoais. Podemos compartilhar dados com:

• Firebase (Google): Para autenticação e armazenamento
• Mercado Pago: Para processamento de pagamentos (apenas dados necessários)
• Provedores de serviço que nos ajudam a operar o aplicativo

Todos os terceiros são obrigados a proteger suas informações de acordo com esta política.''',
            ),
            _buildSection(
              'Segurança dos Dados',
              'Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações, incluindo criptografia de dados em trânsito (HTTPS/TLS), autenticação segura e verificação em duas etapas.',
            ),
            _buildSection(
              'Seus Direitos',
              '''Você tem o direito de:

• Acessar seus dados pessoais
• Corrigir dados incorretos
• Solicitar exclusão da sua conta
• Exportar seus dados
• Retirar consentimento a qualquer momento

Para exercer esses direitos, entre em contato conosco.''',
            ),
            _buildSection(
              'Retenção de Dados',
              'Mantemos suas informações enquanto sua conta estiver ativa. Após a exclusão da conta, seus dados serão removidos em até 30 dias, exceto quando necessário para cumprir obrigações legais.',
            ),
            _buildSection(
              'Menores de Idade',
              'Nosso aplicativo não é destinado a menores de 18 anos. Não coletamos intencionalmente informações de menores. Se tomarmos conhecimento de que coletamos dados de um menor, excluiremos essas informações.',
            ),
            _buildSection(
              'Alterações nesta Política',
              'Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos sobre mudanças significativas através do aplicativo ou por email.',
            ),
            _buildSection(
              'Contato',
              '''Para questões sobre esta política ou sobre seus dados pessoais, entre em contato:

Email: suporte@alanocryptofx.com.br
Site: https://alanocryptofx.com.br''',
            ),
            const SizedBox(height: 40),
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'AC',
                style: TextStyle(
                  color: Color(0xFF111418),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AlanoCryptoFX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(0, 255, 136, 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.update,
            color: Color(0xFF00FF88),
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Última atualização: 29 de março de 2026',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1f25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.85),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            '© 2026 AlanoCryptoFX',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.5),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Todos os direitos reservados',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
