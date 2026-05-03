// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtores movidos antes dos campos em PontosGerados e GeradorPontosComodo.
// [1.0.1] - 2026-04
// - ADD: implementação completa de gerar().
// [1.0.0] - 2026-04
// - ADD: scaffold de GeradorPontosComodo.

import 'package:normative_engine/normative_engine.dart';
import 'package:uuid/uuid.dart';

import '../../models/carga/comodo.dart';

const double _potenciaTugVa = 100.0;
const double _potenciaIlVa = 100.0;

/// Resultado da geração de pontos sugeridos pela norma.
final class PontosGerados {
  const PontosGerados({required this.tug, required this.il});

  final List<PontoUtilizacao> tug;
  final List<PontoUtilizacao> il;
}

/// Gera TUGs e ILs sugeridos pela norma.
/// Rastreabilidade: NBR 5410:2004 — 9.1.2 e 9.1.3.
final class GeradorPontosComodo {
  const GeradorPontosComodo({Uuid uuid = const Uuid()}) : _uuid = uuid;

  final Uuid _uuid;

  PontosGerados gerar(Comodo comodo) => switch (comodo.regraTomadasComodo) {
        RegraTomadasComodo.porPerimetro => _gerarPorPerimetro(comodo),
        RegraTomadasComodo.minimoFixo   => _gerarMinimoFixo(comodo),
        RegraTomadasComodo.custom       => const PontosGerados(tug: [], il: []),
      };

  PontosGerados _gerarPorPerimetro(Comodo comodo) {
    final numTug = (comodo.perimetroM / 5.0).ceil().clamp(1, 9999);
    return PontosGerados(
      tug: List.generate(numTug, (_) => PontoUtilizacao(
        idCircuito: _novoId(), tag: TagCircuito.tug, potenciaVA: _potenciaTugVa,
      )),
      il: [PontoUtilizacao(
        idCircuito: _novoId(), tag: TagCircuito.il, potenciaVA: _potenciaIlVa,
      )],
    );
  }

  PontosGerados _gerarMinimoFixo(Comodo comodo) => PontosGerados(
        tug: List.generate(2, (_) => PontoUtilizacao(
          idCircuito: _novoId(), tag: TagCircuito.tug, potenciaVA: _potenciaTugVa,
        )),
        il: [PontoUtilizacao(
          idCircuito: _novoId(), tag: TagCircuito.il, potenciaVA: _potenciaIlVa,
        )],
      );

  String _novoId() => 'C-${_uuid.v4().substring(0, 8).toUpperCase()}';
}
