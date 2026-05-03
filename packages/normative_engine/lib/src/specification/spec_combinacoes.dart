// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: verificação de combinações válidas iso × arq × método × arranjo × tensao.

import '../contracts/i_specification.dart';
import '../enums/isolacao.dart';
import '../enums/arquitetura.dart';
import '../enums/metodo_instalacao.dart';
import '../enums/arranjo_condutores.dart';
import '../enums/tensao.dart';
import '../models/violacao.dart';
import '../models/entrada_normativa.dart';

/// Verifica combinações válidas de Isolacao × Arquitetura × MetodoInstalacao
/// × ArranjoCondutores × Tensao × NumeroFases.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.3, Tabela 33, 6.1.3.1.1.
final class SpecCombinacoes implements ISpecification<EntradaNormativa> {
  const SpecCombinacoes();

  // ── Combinações válidas: Isolacao × Arquitetura ───────────────────────────
  // Rastreabilidade: NBR 5410:2004 — 6.2.3.
  static const _isoArq = {
    (Isolacao.pvc, Arquitetura.isolado),
    (Isolacao.pvc, Arquitetura.unipolar),
    (Isolacao.pvc, Arquitetura.multipolar),
    (Isolacao.xlpe, Arquitetura.unipolar),
    (Isolacao.xlpe, Arquitetura.multipolar),
    (Isolacao.epr, Arquitetura.unipolar),
    (Isolacao.epr, Arquitetura.multipolar),
  };

  // ── Combinações válidas: Arquitetura × MetodoInstalacao ───────────────────
  // Rastreabilidade: NBR 5410:2004 — Tabela 33.
  // Exceções documentadas:
  // - A1 aceita MULTIPOLAR via método físico 51 (parede termicamente isolante).
  // - B1 aceita MULTIPOLAR via método físico 43 (canaleta ventilada no piso).
  // - B2 aceita ISOLADO via método físico 26, UNIPOLAR via 23/25/27.
  static const _arqMet = {
    (Arquitetura.isolado,    MetodoInstalacao.a1),
    (Arquitetura.unipolar,   MetodoInstalacao.a1),
    (Arquitetura.multipolar, MetodoInstalacao.a1),
    (Arquitetura.multipolar, MetodoInstalacao.a2),
    (Arquitetura.isolado,    MetodoInstalacao.b1),
    (Arquitetura.unipolar,   MetodoInstalacao.b1),
    (Arquitetura.multipolar, MetodoInstalacao.b1),
    (Arquitetura.isolado,    MetodoInstalacao.b2),
    (Arquitetura.unipolar,   MetodoInstalacao.b2),
    (Arquitetura.multipolar, MetodoInstalacao.b2),
    (Arquitetura.unipolar,   MetodoInstalacao.c),
    (Arquitetura.multipolar, MetodoInstalacao.c),
    (Arquitetura.unipolar,   MetodoInstalacao.d),
    (Arquitetura.multipolar, MetodoInstalacao.d),
    (Arquitetura.multipolar, MetodoInstalacao.e),
    (Arquitetura.unipolar,   MetodoInstalacao.f),
    (Arquitetura.isolado,    MetodoInstalacao.g),
    (Arquitetura.unipolar,   MetodoInstalacao.g),
  };

  // ── ArranjoCondutores compatíveis com Método F ────────────────────────────
  static const _arranjoMetodoF = {
    ArranjoCondutores.justaposto2c,
    ArranjoCondutores.trifolio,
    ArranjoCondutores.planoJustaposto,
  };

  // ── ArranjoCondutores compatíveis com Método G ────────────────────────────
  static const _arranjoMetodoG = {
    ArranjoCondutores.espacadoHorizontal,
    ArranjoCondutores.espacadoVertical,
  };

  @override
  List<Violacao> verificar(EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    // 1. Tensao × NumeroFases
    final fasesValidas = Tensao.combinacoesValidas[entrada.tensao] ?? [];
    if (!fasesValidas.contains(entrada.numeroFases)) {
      violacoes.add(Violacao.combinacaoTensaoFases(
        tensao: '${entrada.tensao.valor}V',
        fases: entrada.numeroFases.name,
      ));
    }

    // 2. Isolacao × Arquitetura
    if (!_isoArq.contains((entrada.isolacao, entrada.arquitetura))) {
      violacoes.add(Violacao.combinacaoIsolacaoArquitetura(
        isolacao: entrada.isolacao.name.toUpperCase(),
        arquitetura: entrada.arquitetura.name,
      ));
    }

    // 3. Arquitetura × MetodoInstalacao
    if (!_arqMet.contains((entrada.arquitetura, entrada.metodo))) {
      violacoes.add(Violacao.combinacaoArquiteturaMetodo(
        arquitetura: entrada.arquitetura.name,
        metodo: entrada.metodo.name.toUpperCase(),
      ));
    }

    // 4. ArranjoCondutores × MetodoInstalacao
    _verificarArranjo(entrada, violacoes);

    return violacoes;
  }

  void _verificarArranjo(EntradaNormativa e, List<Violacao> violacoes) {
    switch (e.metodo) {
      case MetodoInstalacao.f:
        if (e.arranjo == null) {
          violacoes.add(Violacao.arranjoObrigatorio(metodo: 'F'));
        } else if (!_arranjoMetodoF.contains(e.arranjo)) {
          violacoes.add(Violacao.arranjoIncompativelComMetodo(
            arranjo: e.arranjo!.name,
            metodo: 'F',
          ));
        }

      case MetodoInstalacao.g:
        if (e.arranjo == null) {
          violacoes.add(Violacao.arranjoObrigatorio(metodo: 'G'));
        } else if (!_arranjoMetodoG.contains(e.arranjo)) {
          violacoes.add(Violacao.arranjoIncompativelComMetodo(
            arranjo: e.arranjo!.name,
            metodo: 'G',
          ));
        }

      default:
        // Métodos A1–E: arranjo deve ser null
        if (e.arranjo != null) {
          violacoes.add(Violacao.arranjoDeveSerNulo(
            metodo: e.metodo.name.toUpperCase(),
          ));
        }
    }
  }
}
