extern vec4 color;
extern float time;

#define pi 3.141592653589793238462

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);

  float direction = atan((texture_coords.y - .5) / (texture_coords.x - .5));
  float distance = length(texture_coords - vec2(.5, .5)) * 7;

  vec2 rayCoords = vec2(((texture_coords.x - .5) / 2) + .5, ((texture_coords.y - .5) / 2) + .5);
  rayCoords.x += cos(time / 11 + texture_coords.y / 2) * .04;
  rayCoords.y += sin(time / 9 + texture_coords.x / 2) * .04;
  vec4 rayColor = Texel(texture, rayCoords);
  rayColor.a = .5;

  return result + rayColor;
}
