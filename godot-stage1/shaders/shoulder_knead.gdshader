shader_type canvas_item;
uniform float pressure : hint_range(0.0, 1.0) = 0.0;
varying vec4 vertex_tint;
void vertex() { vertex_tint = COLOR; }
void fragment() {
    // Deform only the existing shoulder cloth under the independent hand layer.
    vec2 distance_from_grip = (UV - vec2(0.65, 0.217)) / vec2(0.08, 0.045);
    float influence = exp(-dot(distance_from_grip, distance_from_grip) * 2.0);
    vec2 cloth_uv = UV - vec2(0.0, 0.0035 * pressure * influence);
    COLOR = texture(TEXTURE, cloth_uv) * vertex_tint;
}
