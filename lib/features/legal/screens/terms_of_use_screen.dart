import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        elevation: 0,
        title: const Text(
          'Termos de Uso',
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
              'Aceitação dos Termos',
              'Ao acessar ou usar o aplicativo AlanoCryptoFX, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não poderá acessar o serviço.',
            ),
            _buildSection(
              'Descrição do Serviço',
              '''O AlanoCryptoFX é uma plataforma educacional e de comunidade para traders de criptomoedas e forex, que oferece:

• Sinais de trading educacionais
• Comunidade e chat em grupo
• Conteúdo exclusivo do Alano
• Ferramentas de análise de mercado
• Calendário econômico
• Portfólio pessoal

O serviço é disponibilizado mediante assinatura premium.''',
            ),
            _buildSection(
              'Conta do Usuário',
              '''Para usar nosso serviço, você deve:

• Ter pelo menos 18 anos de idade
• Fornecer informações verdadeiras e precisas
• Manter a confidencialidade de sua senha
• Notificar imediatamente qualquer uso não autorizado

Você é responsável por todas as atividades realizadas em sua conta.''',
            ),
            _buildSection(
              'Conduta do Usuário',
              '''Ao usar nosso serviço, você concorda em NÃO:

• Publicar conteúdo falso, enganoso ou difamatório
• Assediar, ameaçar ou intimidar outros usuários
• Compartilhar conteúdo protegido por direitos autorais sem permissão
• Tentar acessar dados de outros usuários
• Usar o serviço para atividades ilegais
• Fazer spam ou publicidade não autorizada
• Compartilhar credenciais de acesso com terceiros''',
            ),
            _buildSection(
              'Isenção de Responsabilidade sobre Investimentos',
              '''AVISO IMPORTANTE:

O AlanoCryptoFX é uma plataforma EDUCACIONAL. Todo o conteúdo, sinais e análises fornecidos têm fins exclusivamente educacionais e informativos.

• NÃO somos uma corretora ou gestora de investimentos
• NÃO oferecemos consultoria financeira personalizada
• Os sinais de trading são exemplos educacionais, NÃO recomendações de investimento
• Investimentos em criptomoedas e forex envolvem ALTO RISCO
• Resultados passados NÃO garantem resultados futuros
• Você pode perder todo o capital investido

Sempre consulte um profissional financeiro qualificado antes de investir.''',
            ),
            _buildSection(
              'Propriedade Intelectual',
              '''Todo o conteúdo do aplicativo, incluindo textos, gráficos, logos, ícones e software, é propriedade da AlanoCryptoFX ou de seus fornecedores de conteúdo e está protegido por leis de direitos autorais.

Você não pode reproduzir, distribuir ou criar obras derivadas sem nossa permissão expressa por escrito.''',
            ),
            _buildSection(
              'Limitação de Responsabilidade',
              '''Na máxima extensão permitida pela lei, a AlanoCryptoFX não será responsável por:

• Perdas financeiras resultantes do uso do aplicativo
• Interrupções ou indisponibilidade do serviço
• Erros ou imprecisões no conteúdo
• Danos causados por vírus ou outros códigos maliciosos
• Ações de terceiros

O uso do serviço é por sua conta e risco.''',
            ),
            _buildSection(
              'Rescisão',
              'Podemos encerrar ou suspender sua conta imediatamente, sem aviso prévio, se você violar estes Termos de Uso. Após a rescisão, seu direito de usar o serviço cessará imediatamente.',
            ),
            _buildSection(
              'Alterações nos Termos',
              'Reservamos o direito de modificar estes termos a qualquer momento. Notificaremos sobre mudanças significativas através do aplicativo. O uso continuado do serviço após as alterações constitui aceitação dos novos termos.',
            ),
            _buildSection(
              'Lei Aplicável',
              'Estes Termos de Uso são regidos pelas leis do Brasil. Qualquer disputa será submetida à jurisdição exclusiva dos tribunais brasileiros.',
            ),
            _buildSection(
              'Contato',
              '''Para questões sobre estes Termos de Uso, entre em contato:

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
