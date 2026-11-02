/** 文件职责：按 Android 系统能力选择后端；新系统类型只在对应 API 实现中加载。 */
package hyper_ui

import android.graphics.RenderEffect as NativeEffect
import android.graphics.RuntimeShader
import android.graphics.Shader
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.ui.graphics.RenderEffect
import androidx.compose.ui.graphics.asComposeRenderEffect

internal fun createHyperGlassShader(): HyperGlassShader = when {
    Build.VERSION.SDK_INT >= 33 -> AndroidRefractiveShader()
    Build.VERSION.SDK_INT >= 31 -> AndroidBlurShader()
    else -> object : HyperGlassShader {
        override val supported = false
        override fun effect(optics: HyperGlassOptics): RenderEffect? = null
    }
}

@RequiresApi(31)
private open class AndroidBlurShader : HyperGlassShader {
    override val supportsAmbient: Boolean get() = false
    private var previous: HyperGlassOptics? = null
    private var cached: RenderEffect? = null
    protected open fun lens(optics: HyperGlassOptics): NativeEffect? = null
    override fun effect(optics: HyperGlassOptics): RenderEffect? {
        if (previous == optics) return cached
        previous = optics
        val blur = if (optics.blur > 0f) NativeEffect.createBlurEffect(optics.blur, optics.blur, Shader.TileMode.CLAMP) else null
        val lens = lens(optics)
        cached = (if (lens != null && blur != null) NativeEffect.createChainEffect(lens, blur) else lens ?: blur)?.asComposeRenderEffect()
        return cached
    }
}

@RequiresApi(33)
private class AndroidRefractiveShader : AndroidBlurShader() {
    override val supportsAmbient: Boolean get() = true
    private val shader = RuntimeShader(HyperGlassShaderCode)
    override fun lens(optics: HyperGlassOptics): NativeEffect {
        shader.setFloatUniform("size", optics.width, optics.height)
        shader.setFloatUniform("padding", optics.padding)
        shader.setFloatUniform("radii", optics.radii.toFloatArray())
        shader.setFloatUniform("edge", optics.edge)
        shader.setFloatUniform("amount", optics.amount)
        shader.setFloatUniform("dispersion", optics.dispersion)
        shader.setFloatUniform("depth", optics.depth)
        shader.setFloatUniform("saturation", optics.saturation)
        shader.setFloatUniform("brightness", optics.brightness)
        shader.setFloatUniform("highlight", optics.highlight)
        shader.setFloatUniform("stroke", optics.stroke)
        shader.setFloatUniform("ambient", optics.ambient)
        return NativeEffect.createRuntimeShaderEffect(shader, "content")
    }
}
