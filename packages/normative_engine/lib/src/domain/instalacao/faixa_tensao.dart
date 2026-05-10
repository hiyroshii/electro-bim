// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: criação do enum FaixaTensao — suporte à spec 6.2.9.5.

/// Faixas de tensão conforme NBR 5410:2004 — 6.2.9.5.
///
/// faixaI  = SELV/PELV/FELV — tensão de segurança (≤ 50 V CA / ≤ 120 V CC).
/// faixaII = instalações em baixa tensão convencional (127 V, 220 V, 380 V).
///
/// Todos os valores atuais de [Tensao] (v127, v220, v380) são [faixaII].
/// O enum está preparado para quando tensões ELV forem adicionadas ao sistema.
enum FaixaTensao { faixaI, faixaII }
