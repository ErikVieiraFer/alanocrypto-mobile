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
            _buildWarningBanner(),
            const SizedBox(height: 24),
            _buildSection(
              'Aceitação dos Termos',
              '''Ao acessar, se cadastrar ou utilizar o aplicativo AlanoCryptoFX, você declara expressamente que:

• Leu, compreendeu e concorda integralmente com estes Termos de Uso
• Tem capacidade legal para celebrar este acordo (maior de 18 anos)
• Está ciente de que o uso da plataforma não garante resultados financeiros de qualquer natureza
• Aceita total responsabilidade pelas decisões financeiras que tomar, independentemente do conteúdo consumido nesta plataforma
• Compreende que este aplicativo é uma COMUNIDADE FECHADA DE TROCA DE CONHECIMENTOS, e não um serviço de assessoria, consultoria ou intermediação financeira

Se você não concordar com qualquer parte destes termos, não poderá acessar ou utilizar o serviço.''',
            ),
            _buildSection(
              'Natureza do Serviço — O que é o AlanoCryptoFX',
              '''O AlanoCryptoFX é uma COMUNIDADE FECHADA E PRIVADA voltada ao compartilhamento de conhecimentos, experiências e informações sobre o mercado financeiro, criptomoedas e forex.

O que este aplicativo É:
• Uma comunidade de pessoas interessadas no mercado financeiro
• Um espaço para troca de experiências entre membros
• Uma plataforma de aprendizado colaborativo
• Um ambiente para acompanhar análises e conteúdos educacionais
• Um canal de comunicação entre o criador de conteúdo Alano e sua comunidade

O que este aplicativo NÃO É:
• NÃO é uma corretora de valores ou câmbio
• NÃO é uma gestora de investimentos
• NÃO é uma plataforma de assessoria financeira regulamentada
• NÃO é um serviço de recomendação de investimentos
• NÃO é substituto para orientação de um profissional financeiro qualificado
• NÃO possui autorização da CVM, Banco Central ou qualquer órgão regulador para ofertar serviços financeiros

Todo o conteúdo publicado — incluindo análises, comentários de mercado, gráficos e discussões — tem caráter EXCLUSIVAMENTE EDUCACIONAL E INFORMATIVO.''',
            ),
            _buildSection(
              'A Cúpula — Conteúdo Premium',
              '''A Cúpula é a área de acesso exclusivo e pago da plataforma AlanoCryptoFX, que oferece conteúdos produzidos pelo Alano, incluindo:

• Vídeos e análises exclusivas
• Materiais educacionais avançados
• Conteúdo de acompanhamento de mercado com fins didáticos
• Acesso a conteúdos e transmissões especiais

Ao assinar e acessar a Cúpula, o usuário declara estar ciente e concorda que:

• Todo o conteúdo disponibilizado tem caráter EDUCACIONAL, não constituindo recomendação de compra, venda ou manutenção de qualquer ativo financeiro
• O acesso à Cúpula não garante lucros, retornos ou resultados financeiros positivos de qualquer espécie
• O preço da assinatura remunera o acesso ao conteúdo educacional, e não promessas de ganhos
• Análises compartilhadas representam a visão pessoal e educacional do criador de conteúdo, podendo estar erradas
• O mercado financeiro é volátil e imprevisível, e qualquer operação realizada com base no conteúdo da Cúpula é de inteira responsabilidade do usuário
• A AlanoCryptoFX não se responsabiliza por perdas decorrentes da interpretação ou aplicação do conteúdo da Cúpula

O acesso à Cúpula está condicionado à manutenção da assinatura ativa. O cancelamento da assinatura encerra o acesso imediatamente ao término do período vigente.''',
            ),
            _buildSection(
              'Isenção de Responsabilidade Financeira',
              '''LEIA COM ATENÇÃO — ESTA CLÁUSULA É PARTE FUNDAMENTAL DO SEU ACORDO:

O mercado financeiro, de criptomoedas e de câmbio (forex) envolve RISCOS ELEVADOS E INERENTES. Ao utilizar esta plataforma, você reconhece e aceita que:

• NÃO há garantia de ganhos, rentabilidade ou qualquer resultado positivo decorrente do uso desta plataforma
• Resultados passados, citados ou apresentados NÃO garantem resultados futuros
• É possível perder PARCIAL OU TOTALMENTE o capital investido em operações financeiras
• O conteúdo disponibilizado reflete opiniões e análises pessoais, sujeitas a erro
• A volatilidade dos mercados pode tornar qualquer análise desatualizada em questão de minutos
• Nenhum membro da comunidade, incluindo o criador de conteúdo, possui bola de cristal ou método infalível
• Investir em ativos de risco é uma decisão pessoal e exclusiva do usuário
• A AlanoCryptoFX, seus administradores, criadores de conteúdo e membros NÃO se responsabilizam por decisões de investimento tomadas com base em qualquer conteúdo da plataforma

AVISO REGULATÓRIO: Este aplicativo não é registrado nem autorizado pela Comissão de Valores Mobiliários (CVM) ou pelo Banco Central do Brasil como prestador de serviços de investimento. Consulte sempre um assessor de investimentos habilitado antes de tomar qualquer decisão financeira.''',
            ),
            _buildSection(
              'Conta do Usuário',
              '''Para usar nosso serviço, você deve:

• Ter pelo menos 18 anos de idade
• Fornecer informações verdadeiras, precisas e atualizadas no cadastro
• Manter a confidencialidade de sua senha e dados de acesso
• Não compartilhar suas credenciais com terceiros sob nenhuma circunstância
• Notificar imediatamente qualquer acesso não autorizado à sua conta
• Manter um único cadastro — contas duplicadas podem ser suspensas

Você é inteiramente responsável por todas as atividades realizadas em sua conta. O uso da conta por terceiros, mesmo que autorizado pelo titular, não isenta o titular de responsabilidade pelas ações praticadas.''',
            ),
            _buildSection(
              'Conduta do Usuário — Violações',
              '''Ao usar nossa plataforma, você concorda em NÃO praticar os seguintes atos, sob pena de suspensão ou banimento imediato:

Sobre conteúdo publicado:
• Publicar informações falsas, enganosas, difamatórias ou fraudulentas
• Divulgar "dicas" de investimento como se fossem certezas ou garantias de lucro
• Compartilhar conteúdo de cunho sexual, violento, racista, discriminatório ou ilegal
• Fazer propaganda política ou religiosa de qualquer natureza
• Publicar dados pessoais de outros usuários sem consentimento (doxxing)

Sobre uso da plataforma:
• Compartilhar suas credenciais de acesso com outras pessoas
• Tentar acessar áreas restritas ou dados de outros usuários
• Utilizar bots, scripts ou automações para interagir com a plataforma
• Realizar engenharia reversa, descompilar ou copiar o código do aplicativo
• Fazer uso comercial não autorizado de qualquer conteúdo da plataforma

Sobre a comunidade:
• Assediar, ameaçar, intimidar ou ofender outros membros
• Fazer spam, flood ou publicidade não autorizada
• Criar clima de hostilidade ou conflito deliberado
• Impersonar outros membros, o criador de conteúdo ou a equipe da plataforma
• Divulgar conteúdo exclusivo da Cúpula fora da plataforma

Sobre operações financeiras:
• Prometer, garantir ou sugerir retornos financeiros a outros membros
• Captar recursos de outros membros para gestão ou investimento conjunto
• Formar grupos paralelos com o objetivo de manipular mercados
• Oferecer serviços de consultoria financeira dentro da plataforma

A prática de qualquer violação pode resultar em suspensão temporária, banimento permanente e, em casos graves, comunicação às autoridades competentes.''',
            ),
            _buildSection(
              'Propriedade Intelectual',
              '''Todo o conteúdo disponibilizado na plataforma — incluindo vídeos, textos, análises, gráficos, logos, identidade visual, código-fonte e marca — é propriedade exclusiva da AlanoCryptoFX ou de seus criadores de conteúdo, protegido pela legislação brasileira e internacional de direitos autorais.

É expressamente proibido:
• Reproduzir, copiar ou redistribuir conteúdo sem autorização prévia e escrita
• Compartilhar conteúdo da Cúpula em grupos, redes sociais ou qualquer outro meio
• Gravar transmissões ao vivo ou vídeos exclusivos para redistribuição
• Usar a marca ou identidade visual da AlanoCryptoFX sem autorização
• Criar produtos ou serviços derivados com base no conteúdo da plataforma

A violação dos direitos de propriedade intelectual pode ensejar medidas judiciais cíveis e criminais.''',
            ),
            _buildSection(
              'Limitação de Responsabilidade',
              '''Na máxima extensão permitida pela legislação brasileira, a AlanoCryptoFX não será responsável por:

• Perdas ou ganhos financeiros resultantes, direta ou indiretamente, do uso da plataforma
• Decisões de investimento tomadas com base em qualquer conteúdo publicado
• Interrupções, instabilidades ou indisponibilidade temporária do serviço
• Erros, imprecisões ou desatualizações no conteúdo publicado
• Danos causados por vírus, invasões ou falhas de segurança de terceiros
• Ações, omissões ou conteúdos publicados por outros membros da comunidade
• Perdas decorrentes de acesso não autorizado à conta do usuário por negligência do próprio usuário
• Falhas de conexão, dispositivo ou infraestrutura do usuário

O uso do serviço é inteiramente por sua conta e risco.''',
            ),
            _buildSection(
              'Suspensão e Encerramento de Conta',
              '''A AlanoCryptoFX reserva-se o direito de suspender ou encerrar sua conta, a qualquer momento e sem aviso prévio, nos seguintes casos:

• Violação de qualquer item destes Termos de Uso
• Inadimplência da assinatura
• Comportamento prejudicial à comunidade ou à plataforma
• Suspeita de fraude, golpe ou uso malicioso
• Determinação judicial ou solicitação de autoridade competente

O encerramento da conta não gera direito a reembolso de valores já pagos, salvo nos casos expressamente previstos na política de reembolso vigente.''',
            ),
            _buildSection(
              'Alterações nos Termos',
              '''Reservamo-nos o direito de modificar estes Termos de Uso a qualquer momento, por qualquer motivo, incluindo mudanças legais, regulatórias ou operacionais.

• Alterações significativas serão comunicadas via notificação no aplicativo ou por email
• O uso continuado do serviço após as alterações constitui aceitação automática dos novos termos
• Caso não concorde com as alterações, você deve encerrar sua conta antes da entrada em vigor das mudanças

Recomendamos a leitura periódica deste documento.''',
            ),
            _buildSection(
              'Lei Aplicável e Foro',
              '''Estes Termos de Uso são regidos exclusivamente pelas leis da República Federativa do Brasil, em especial pelo Código de Defesa do Consumidor (Lei nº 8.078/1990), o Marco Civil da Internet (Lei nº 12.965/2014) e a Lei Geral de Proteção de Dados (Lei nº 13.709/2018).

Fica eleito o foro da comarca de Belo Horizonte/MG para dirimir quaisquer controvérsias oriundas destes Termos, com renúncia a qualquer outro, por mais privilegiado que seja.''',
            ),
            _buildSection(
              'Contato',
              '''Para questões sobre estes Termos de Uso, denúncias de violações ou solicitações gerais:

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

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 165, 0, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(255, 165, 0, 0.5),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFFA500),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este aplicativo é uma comunidade educacional. Não oferecemos garantia de ganhos financeiros. Investir envolve riscos e você pode perder seu capital.',
              style: TextStyle(
                color: Color(0xFFFFA500),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
