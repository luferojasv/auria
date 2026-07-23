import 'package:flutter/material.dart';

import '../../theme/glass_tokens.dart';
import 'glass_card.dart';

/// Tarjeta de metrica: icono, valor grande, unidad y etiqueta.
class MetricaTile extends StatelessWidget {
  const MetricaTile({
    super.key,
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
    this.unidad,
    this.pie,
    this.onTap,
    this.desenfocar = true,
  });

  final IconData icono;
  final String valor;
  final String? unidad;
  final String etiqueta;
  final Color color;

  /// Linea auxiliar bajo la etiqueta (comparativa, tendencia...).
  final Widget? pie;

  final VoidCallback? onTap;
  final bool desenfocar;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      tinte: color,
      desenfocar: desenfocar,
      padding: const EdgeInsets.all(G.e4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: color.withValues(alpha: 0.18),
            ),
            child: Icon(icono, size: 16, color: color),
          ),
          const SizedBox(height: G.e3),
          // baseline para que la unidad se apoye en el pie del numero.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  valor,
                  style: T.metrica,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unidad != null) ...[
                const SizedBox(width: 3),
                Text(unidad!, style: T.unidad),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(etiqueta, style: T.etiqueta, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (pie != null) ...[const SizedBox(height: G.e2), pie!],
        ],
      ),
    );
  }
}

/// Encabezado de seccion con accion opcional a la derecha.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.titulo,
    this.accion,
    this.onAccion,
  });

  final String titulo;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(G.e1, G.e5, G.e1, G.e3),
      child: Row(
        children: [
          Expanded(child: Text(titulo, style: T.seccion)),
          if (accion != null)
            GestureDetector(
              onTap: onAccion,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: G.e2, vertical: G.e1),
                child: Text(
                  accion!,
                  style: T.etiqueta.copyWith(
                    color: G.acentoActividad,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip de filtro.
class GlassChip extends StatelessWidget {
  const GlassChip({
    super.key,
    required this.texto,
    this.activo = false,
    this.onTap,
    this.color = G.acentoEjercicio,
    this.icono,
  });

  final String texto;
  final bool activo;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: G.rapido,
        curve: G.curvaSuave,
        padding: const EdgeInsets.symmetric(horizontal: G.e3, vertical: G.e2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: activo ? color.withValues(alpha: 0.22) : G.cristalRelleno,
          border: Border.all(
            color: activo ? color.withValues(alpha: 0.55) : G.cristalBorde,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 13, color: activo ? Colors.white : G.textoBajo),
              const SizedBox(width: 5),
            ],
            Text(
              texto,
              style: T.etiqueta.copyWith(
                color: activo ? Colors.white : G.textoMedio,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacio o de error, centrado.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(G.e8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(G.e5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: G.cristalRelleno,
                border: Border.all(color: G.cristalBorde),
              ),
              child: Icon(icono, size: 30, color: G.textoBajo),
            ),
            const SizedBox(height: G.e5),
            Text(titulo, style: T.seccion, textAlign: TextAlign.center),
            if (detalle != null) ...[
              const SizedBox(height: G.e2),
              Text(detalle!, style: T.cuerpo, textAlign: TextAlign.center),
            ],
            if (accion != null) ...[
              const SizedBox(height: G.e5),
              BotonGlass(texto: accion!, onTap: onAccion),
            ],
          ],
        ),
      ),
    );
  }
}

/// Boton primario de cristal.
class BotonGlass extends StatelessWidget {
  const BotonGlass({
    super.key,
    required this.texto,
    this.onTap,
    this.icono,
    this.color = G.acentoEjercicio,
    this.expandido = false,
  });

  final String texto;
  final VoidCallback? onTap;
  final IconData? icono;
  final Color color;
  final bool expandido;

  @override
  Widget build(BuildContext context) {
    final activo = onTap != null;

    final hijo = Row(
      mainAxisSize: expandido ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icono != null) ...[
          Icon(icono, size: 18, color: activo ? Colors.white : G.textoTenue),
          const SizedBox(width: G.e2),
        ],
        Text(
          texto,
          style: T.cuerpoFuerte.copyWith(
            color: activo ? Colors.white : G.textoTenue,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: G.e6, vertical: G.e4),
        decoration: BoxDecoration(
          borderRadius: G.brS,
          gradient: activo ? G.gradienteAcento(color) : null,
          color: activo ? null : G.cristalRelleno,
          border: Border.all(
            color: activo ? Colors.white.withValues(alpha: 0.22) : G.cristalBorde,
          ),
          boxShadow: activo ? G.halo(color, intensidad: 0.32) : null,
        ),
        child: hijo,
      ),
    );
  }
}
