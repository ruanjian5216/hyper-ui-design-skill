/** 文件职责：共享参考项目的圆角距离场、圆弧折射和七波段色散模型。 */
package hyper_ui

import androidx.compose.ui.graphics.RenderEffect

internal data class HyperGlassOptics(
    val width: Float, val height: Float, val padding: Float, val radii: List<Float>,
    val edge: Float, val amount: Float, val dispersion: Float, val depth: Float,
    val blur: Float, val saturation: Float, val brightness: Float,
    val highlight: Float, val stroke: Float, val ambient: Float = 0f
)

internal interface HyperGlassShader {
    val supported: Boolean get() = true
    val supportsAmbient: Boolean get() = supported
    fun effect(optics: HyperGlassOptics): RenderEffect?
    fun close() {}
}

internal const val HyperGlassShaderCode = """
uniform shader content;
uniform float2 size;
uniform float padding;
uniform float4 radii;
uniform float edge;
uniform float amount;
uniform float dispersion;
uniform float depth;
uniform float saturation;
uniform float brightness;
uniform float highlight;
uniform float stroke;
uniform float ambient;

float2 safeNormal(float2 v) { return v / max(length(v), 0.0001); }
float2 gradRect(float2 p, float2 h, float r) {
    float2 q = abs(p) - h + r;
    if (q.x >= 0.0 || q.y >= 0.0) return sign(p) * safeNormal(max(q, 0.0));
    float x = step(q.y, q.x);
    return sign(p) * float2(x, 1.0-x);
}
half4 sampleGlass(float2 uv) {
    half4 c = content.eval(uv);
    float l = dot(c.rgb, float3(0.2126,0.7152,0.0722));
    c.rgb = clamp(mix(float3(l),c.rgb,saturation)+brightness*c.a,0.0,c.a);
    return c;
}
half4 main(float2 uv) {
    float2 h = size*0.5;
    float2 p = uv-float2(padding)-h;
    float r = p.x < 0.0 ? (p.y < 0.0 ? radii.x : radii.w) : (p.y < 0.0 ? radii.y : radii.z);
    float2 q = abs(p)-h+r;
    float sd = length(max(q,0.0))+min(max(q.x,q.y),0.0)-r;
    float2 n = gradRect(p,h,min(r*1.5,min(h.x,h.y)));
    if (ambient > 0.0) {
        float d = dot(n,float2(0.70710678));
        float t = step(0.0,d);
        return half4(t,t,t,1.0)*abs(d)*content.eval(uv).a;
    }
    float2 shift = float2(0.0);
    if (edge > 0.0 && amount > 0.0 && -sd < edge) {
        float f = clamp(1.0+min(sd,0.0)/edge,0.0,1.0);
        shift = -(1.0-sqrt(max(1.0-f*f,0.0)))*amount*safeNormal(n+depth*safeNormal(p));
    }
    float2 at = uv+shift;
    half4 c;
    if (dispersion > 0.0) {
        float2 spread = shift*dispersion*p.x*p.y/max(h.x*h.y,1.0);
        half4 a = sampleGlass(at+spread);
        half4 b = sampleGlass(at+spread*(2.0/3.0));
        half4 d = sampleGlass(at+spread/3.0);
        half4 e = sampleGlass(at);
        half4 f = sampleGlass(at-spread/3.0);
        half4 g = sampleGlass(at-spread*(2.0/3.0));
        half4 k = sampleGlass(at-spread);
        c = half4((2.0*(a.r+b.r+d.r)+k.r)/7.0,
            (b.g+2.0*(d.g+e.g+f.g))/7.0,(f.b+g.b+k.b)/3.0,
            (a.a+b.a+d.a+e.a+f.a+g.a+k.a)/7.0);
    } else c = sampleGlass(at);
    float rim = (1.0-smoothstep(stroke*0.5,stroke*1.5,abs(sd+stroke)))*highlight;
    float light = abs(dot(n,float2(0.70710678)));
    c.rgb = min(c.rgb+float3(rim*light*0.5),float3(c.a));
    return c;
}
"""
