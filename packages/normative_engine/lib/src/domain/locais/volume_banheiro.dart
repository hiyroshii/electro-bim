// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: v3 — zona periférica externa (IPX1, tomada comum com DR).
// - FIX: v1.ipXMinimo corrigido de 5 para 4 (base NBR; IPX5 só com jatos de água).
// [1.0.0] - 2026-05
// - ADD: VolumeBanheiro — zonas de proteção em locais de banho (NBR 5410 — Seção 701).

/// Zonas de proteção em locais contendo banheira ou box de chuveiro.
///
/// Baseado em IEC 60364-7-701, referenciado pela NBR 5410:2004.
/// Cada volume impõe restrições crescentes de IP e de equipamentos admitidos.
enum VolumeBanheiro {
  /// Volume 0 — interior da banheira ou do box.
  ///
  /// Somente equipamentos próprios para uso submerso (IPX7).
  /// Nenhuma tomada de corrente é admitida.
  v0,

  /// Volume 1 — imediatamente acima/redor da banheira até 2,25 m do piso.
  ///
  /// Somente circuitos SELV ≤ 12 V CA. Grau mínimo IPX4.
  /// Tomadas apenas com transformador de isolação embutido (tomada de barbeador).
  v1,

  /// Volume 2 — zona periférica (0,6 m além do volume 1).
  ///
  /// Equipamentos com grau mínimo IPX4.
  /// Tomadas SELV ou com transformador de isolação admitidas.
  v2,

  /// Volume 3 — zona externa ao volume 2 (até 2,4 m além do volume 2).
  ///
  /// Equipamentos com grau mínimo IPX1.
  /// Tomadas comuns admitidas desde que protegidas por DR com I∆n ≤ 30 mA.
  v3;

  /// Grau de proteção mínimo X (segundo dígito do IP) exigido para o volume.
  int get ipXMinimo => switch (this) {
        VolumeBanheiro.v0 => 7,
        VolumeBanheiro.v1 => 4,
        VolumeBanheiro.v2 => 4,
        VolumeBanheiro.v3 => 1,
      };

  /// Rótulo legível para mensagens de violação.
  String get rotulo => switch (this) {
        VolumeBanheiro.v0 => 'Volume 0',
        VolumeBanheiro.v1 => 'Volume 1',
        VolumeBanheiro.v2 => 'Volume 2',
        VolumeBanheiro.v3 => 'Volume 3',
      };
}
