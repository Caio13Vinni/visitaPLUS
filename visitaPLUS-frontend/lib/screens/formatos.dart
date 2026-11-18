// Formatadores compartilhados de data/hora para as telas.

/// Formata a data como dd/MM/aaaa.
String fmtData(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/'
    '${data.month.toString().padLeft(2, '0')}/'
    '${data.year.toString().padLeft(4, '0')}';

/// Formata data e hora de um DateTime completo (dd/MM/aaaa HH:mm).
String fmtDataHora(DateTime dataHora) => '${fmtData(dataHora)} '
    '${dataHora.hour.toString().padLeft(2, '0')}:'
    '${dataHora.minute.toString().padLeft(2, '0')}';

/// Exibe o horario recebido da API (HH:mm:ss) como HH:mm.
String fmtHora(String horario) =>
    horario.length >= 5 ? horario.substring(0, 5) : horario;
