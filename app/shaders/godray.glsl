extern vec4 color;
extern float time;

#define pi 3.141592653589793238462

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);

  float direction = atan(texture_coords.y - .5, texture_coords.x - .5);

  float xfactor = 1.2 + cos(texture_coords.y * 100 + time / 10) / 20;
  float yfactor = 1.2 + cos(texture_coords.x * 100 + time / 10) / 20;
  xfactor *= .25 + abs(cos(direction * 30));
  yfactor *= .25 + abs(cos(direction * 30));
  vec2 rayCoords = vec2(((texture_coords.x - .5) / xfactor) + .5, ((texture_coords.y - .5) / yfactor) + .5);
  vec4 rayColor = Texel(texture, rayCoords) / 1;
  rayColor.a /= 2;

  return result + rayColor;
}
