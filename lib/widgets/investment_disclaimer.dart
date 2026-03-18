import 'package:flutter/material.dart';

class InvestmentDisclaimer extends StatelessWidget {
  final VoidCallback onAccept;

  const InvestmentDisclaimer({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1a1f25),
      title: const Text(
        'Aviso Legal',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: const SingleChildScrollView(
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
          child: const Text(
            'Li e Aceito',
            style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
