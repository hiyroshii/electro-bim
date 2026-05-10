// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: tipo de cômodo residencial para carga mínima de circuito (P-6).

/// Tipo de cômodo residencial.
///
/// Determina a carga mínima por ponto de iluminação (T-13) e por TUG (T-14).
/// Rastreabilidade: NBR 5410:2004 — Seção 9.5.
enum TipoComodo {
  sala,        // Sala de estar, jantar ou estar/jantar combinados
  quarto,      // Quarto, suíte ou dormitório
  cozinha,     // Cozinha
  banheiro,    // Banheiro, lavabo ou toilete
  areaServico, // Área de serviço ou lavanderia
  corredor,    // Corredor, hall ou circulação interna
  garagem,     // Garagem ou estacionamento coberto
  varanda,     // Varanda, sacada ou terraço coberto
}
