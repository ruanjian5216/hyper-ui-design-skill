#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 size;
uniform float padding;
uniform vec4 radii;
uniform float edge;
uniform float amount;
uniform float dispersion;
uniform float depth;
uniform float saturation;
uniform float brightness;
uniform float highlight;
uniform float stroke;
uniform float ambient;
uniform sampler2D content;
out vec4 fragColor;
vec2 safeNormal(vec2 v) { return v / max(length(v), 0.0001); }
vec2 gradRect(vec2 p, vec2 h, float r) {
  vec2 q = abs(p) - h + r;
  if (q.x >= 0.0 || q.y >= 0.0) return sign(p)*safeNormal(max(q,0.0));
  float x = step(q.y,q.x);
  return sign(p)*vec2(x,1.0-x);
}
vec4 sampleGlass(vec2 uv) {
  vec4 c = texture(content,clamp((uv+vec2(padding))/(size+vec2(padding*2.0)),0.0,1.0));
  float l = dot(c.rgb,vec3(0.2126,0.7152,0.0722));
  c.rgb = clamp(mix(vec3(l),c.rgb,saturation)+brightness*c.a,0.0,c.a);
  return c;
}
void main() {
  vec2 uv = FlutterFragCoord().xy;
  vec2 h = size*0.5;
  vec2 p = uv-h;
  float r = p.x < 0.0 ? (p.y < 0.0 ? radii.x : radii.w) : (p.y < 0.0 ? radii.y : radii.z);
  vec2 q = abs(p)-h+r;
  float sd = length(max(q,0.0))+min(max(q.x,q.y),0.0)-r;
  vec2 n = gradRect(p,h,min(r*1.5,min(h.x,h.y)));
  if (ambient > 0.0) {
    float d = dot(n,vec2(0.70710678));
    float t = step(0.0,d);
    fragColor = vec4(t,t,t,1.0)*abs(d)*sampleGlass(uv).a;
    return;
  }
  vec2 shift = vec2(0.0);
  if (edge > 0.0 && amount > 0.0 && -sd < edge) {
    float f = clamp(1.0+min(sd,0.0)/edge,0.0,1.0);
    shift = -(1.0-sqrt(max(1.0-f*f,0.0)))*amount*safeNormal(n+depth*safeNormal(p));
  }
  vec2 at = uv+shift;
  vec4 c;
  if (dispersion > 0.0) {
    vec2 spread = shift*dispersion*p.x*p.y/max(h.x*h.y,1.0);
    vec4 a=sampleGlass(at+spread),b=sampleGlass(at+spread*(2.0/3.0)),d=sampleGlass(at+spread/3.0);
    vec4 e=sampleGlass(at),f=sampleGlass(at-spread/3.0),g=sampleGlass(at-spread*(2.0/3.0)),k=sampleGlass(at-spread);
    c=vec4((2.0*(a.r+b.r+d.r)+k.r)/7.0,(b.g+2.0*(d.g+e.g+f.g))/7.0,(f.b+g.b+k.b)/3.0,(a.a+b.a+d.a+e.a+f.a+g.a+k.a)/7.0);
  } else c=sampleGlass(at);
  float rim=(1.0-smoothstep(stroke*0.5,stroke*1.5,abs(sd+stroke)))*highlight;
  c.rgb=min(c.rgb+vec3(rim*abs(dot(n,vec2(0.70710678)))*0.5),vec3(c.a));
  fragColor=c;
}
