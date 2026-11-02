/** 文件职责：集中保存参考设计的动画曲线与时长，供交互和选择控件复用。 */
package hyper_ui

import androidx.compose.animation.core.CubicBezierEasing

internal object HyperMotionSpec {
    val OverlayCurve = CubicBezierEasing(0.23f, 1f, 0.32f, 1f)
    val SelectionCurve = CubicBezierEasing(0.77f, 0f, 0.175f, 1f)
    val EaseOutCubic = CubicBezierEasing(0.215f, 0.61f, 0.355f, 1f)
    const val PressInDuration = 85
    const val PressOutDuration = 180
    const val SelectionDuration = 260
    const val StateDuration = 160
    const val OverlayDuration = 280
    const val MenuDuration = 180
    const val TooltipDuration = 125
    const val ModalDuration = 250
}
