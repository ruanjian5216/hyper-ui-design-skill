/** 文件职责：提供库内实色表面、阴影与交互色；不暴露材质档位。 */
package hyper_ui

import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.compositeOver

@Immutable
internal data class HyperSurfaceTokens(
    val surface: Color,
    val surfaceStrong: Color,
    val surfaceSubtle: Color,
    val edgeHighlight: Color,
    val edgeShade: Color,
    val shadow: Color,
    val controlTrack: Color,
    val selection: Color,
    val pressed: Color,
    val scrim: Color
) {
    val border: Color get() = edgeShade.compositeOver(edgeHighlight)

    companion object {
        fun light(): HyperSurfaceTokens = HyperSurfaceTokens(
            rgba(255, 255, 255), rgba(255, 255, 255),
            rgba(255, 255, 255), rgba(17, 18, 22, 24 / 255f),
            Color.Transparent, rgba(17, 26, 40, 20 / 255f),
            rgba(0, 0, 0, 22 / 255f), rgba(0, 0, 0, 31 / 255f),
            rgba(0, 0, 0, 20 / 255f), rgba(8, 11, 18, 82 / 255f)
        )

        fun dark(): HyperSurfaceTokens = HyperSurfaceTokens(
            rgba(27, 31, 39), rgba(27, 31, 39),
            rgba(27, 31, 39), rgba(52, 59, 71),
            Color.Transparent, rgba(0, 0, 0, 82 / 255f),
            rgba(255, 255, 255, 36 / 255f), rgba(255, 255, 255, 31 / 255f),
            rgba(255, 255, 255, 31 / 255f), rgba(0, 0, 0, 153 / 255f)
        )
    }
}

internal val hyperSurfaces: HyperSurfaceTokens
    @Composable @ReadOnlyComposable get() = HyperTheme.surfaces
