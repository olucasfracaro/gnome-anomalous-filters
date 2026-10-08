uniform sampler2D tex;
uniform float STRENGTH;

void main() {
    vec4 c = texture2D(tex, cogl_tex_coord_in[0].st);

    // Converte sRGB para o espaço LMS (Hunt-Pointer-Estevez)
    float L = (0.313996 * c.r) + (0.639512 * c.g) + (0.046492 * c.b);
    float M = (0.155372 * c.r) + (0.757894 * c.g) + (0.086701 * c.b);
    float S = (0.017752 * c.r) + (0.109442 * c.g) + (0.872569 * c.b);

    // Isola a diferença perceptual entre os cones L (vermelho) e M (verde)
    float rg_diff = L - M;

    // Aplica o ganho seletivo proporcional à intensidade
    float shift = rg_diff * (STRENGTH * 1.5);

    // Re-projeta a compensação nos canais RGB mantendo a luminosidade equilibrada
    vec4 corrected;
    corrected.r = c.r + (shift * 0.7);
    corrected.g = c.g - (shift * 0.5);
    corrected.b = c.b + (shift * 0.1);
    corrected.a = c.a;

    // Garante limites sRGB válidos [0.0, 1.0]
    cogl_color_out = clamp(corrected, 0.0, 1.0);
}
