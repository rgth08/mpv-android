//!DESC lucine-sharpen suave
//!HOOK SCALED
//!BIND HOOKED

// Afilado de luminancia con limite anti-halo. GLSL ES 1.00, 5 lecturas por pixel.
// Solo usa float; valido con precision mediump (fp16).
const float LSH_AMOUNT = 0.60;   // fuerza del afilado
const float LSH_CORING = 0.006;      // ignora diferencias minimas (grano fino / ruido)

float lsh_luma(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

vec4 hook() {
    vec4 c = HOOKED_texOff(vec2(0.0, 0.0));
    float l  = lsh_luma(c.rgb);
    float ln = lsh_luma(HOOKED_texOff(vec2( 0.0, -2.0)).rgb);
    float ls = lsh_luma(HOOKED_texOff(vec2( 0.0,  2.0)).rgb);
    float lw = lsh_luma(HOOKED_texOff(vec2(-2.0,  0.0)).rgb);
    float le = lsh_luma(HOOKED_texOff(vec2( 2.0,  0.0)).rgb);

    float blur = (ln + ls + lw + le) * 0.25;
    float d = l - blur;
    float mag = max(abs(d) - LSH_CORING, 0.0);
    float boost = (d < 0.0 ? -mag : mag) * LSH_AMOUNT;

    float mn = min(min(min(ln, ls), min(lw, le)), l);
    float mx = max(max(max(ln, ls), max(lw, le)), l);
    float lsh_target = clamp(l + boost, mn, mx);   // sin halos: nunca sale del rango local

    vec3 rgb = c.rgb + (lsh_target - l);
    return vec4(clamp(rgb, 0.0, 1.0), c.a);
}
