extern vec4 color;
extern float time;

#define pi 3.141592653589793238462

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
  vec4 result = Texel(texture, texture_coords);

  float direction = atan(texture_coords.y - .5, texture_coords.x - .5);
  float ox = texture_coords.x - .5;
  float oy = texture_coords.y - .5;

  float xfactor = .7 + cos(ox * 100 + time / 91) / 20;
  float yfactor = .7 + sin(oy * 100 + time / 111) / 20;
  xfactor *= 1 + abs(cos(time / 43 + (11 + cos(direction) * 5))) / 1.25;
  yfactor *= 1 + abs(cos(.25 + time / 51 + (11 + sin(direction) * 5))) / 1.25;
  float factor = xfactor / 2 + yfactor / 2;
  vec2 rayCoords = vec2(((texture_coords.x - .5) / factor) + .5, ((texture_coords.y - .5) / factor) + .5);
  vec4 rayColor = Texel(texture, rayCoords) / 1;
  rayColor.rgb = vec3(.7, 1, .3);
  rayColor.a /= 2;

  return result + rayColor;
}
