uniform sampler2D tex;
uniform float STRENGTH;

void main() {
    vec4 c = texture2D(tex, cogl_tex_coord_in[0].st);

    //converte sRGB para LMS
    float L = (0.313996 * c.r) + (0.639512 * c.g) + (0.046492 * c.b);
    float M = (0.155372 * c.r) + (0.757894 * c.g) + (0.086701 * c.b);

    //isola a diferença R-G
    float rg_diff = L - M;

    //boost no eixo R-G
    float boost = STRENGTH * 3.5;
    float shift = rg_diff * boost;

    vec4 corrected;
    corrected.r = c.r + (shift * 1.2);
    corrected.g = c.g - (shift * 0.8);
    corrected.b = c.b - (shift * 0.2);

    //estratégia de contraste de luminosidade (marrom x vermelho)
    float luma = (c.r * 0.299) + (c.g * 0.587) + (c.b * 0.114);

    //se for um tom terroso/marrom (R > G, G >= B e luma média/baixa)
    if (c.r > c.g && c.g >= c.b && luma < 0.55) {
        //reduz o brilho para puxar o marrom para um tom mais denso/escuro,
        //mas preserva o canal azul/verde para não virar vermelho escuro.
        float dark_factor = (1.0 - luma) * STRENGTH * 0.25;
        corrected.r -= dark_factor * 0.5;
        corrected.g -= dark_factor * 0.3;
        corrected.b -= dark_factor * 0.2;
    }

    corrected.a = c.a;
    cogl_color_out = clamp(corrected, 0.0, 1.0);
}
