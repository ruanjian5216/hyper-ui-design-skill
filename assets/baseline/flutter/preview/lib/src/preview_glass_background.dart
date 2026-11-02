import 'package:flutter/widgets.dart';
import 'package:flutter_hyper_ui/hyper_ui_preview_core.dart';

/// 与 Compose 组件文档共用静态背景，便于查看固定镜片的透色与折射。
class PreviewGlassBackground extends StatelessWidget {
  const PreviewGlassBackground({super.key,required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme=HyperUiTheme.of(context);
    return HyperBackdrop(background:CustomPaint(painter:_GlassScenePainter(theme.tokens.primary,theme.tokens.background)),child:child);
  }
}
class _GlassScenePainter extends CustomPainter {
  const _GlassScenePainter(this.accent,this.base);
  final Color accent,base;
  @override
  void paint(Canvas canvas,Size size) {
    final rect=Offset.zero & size;
    canvas.drawRect(rect,Paint()..shader=LinearGradient(colors:[
      Color.alphaBlend(accent.withValues(alpha:28/255),base),base,
      Color.alphaBlend(const Color.fromRGBO(154,130,215,28/255),base)],stops:const [0,0.52,1],
      begin:Alignment.topLeft,end:Alignment.bottomRight).createShader(rect));
    for(var index=0;index<12;index++) {
      canvas.drawCircle(Offset(size.width*index/11,size.height*((index%4+0.5)/4)),42,Paint()..color=accent.withValues(alpha:0.3));
    }
  }
  @override
  bool shouldRepaint(_GlassScenePainter oldDelegate)=>accent!=oldDelegate.accent||base!=oldDelegate.base;
}
