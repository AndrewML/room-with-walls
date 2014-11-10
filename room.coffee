r = 30
[x0, y0] = [300, 600]
[Vx0, Vy0] = [7, 12]

wall_length0 = 280
wall_thickness0 = 5

width = window.innerWidth - 20
height = window.innerHeight - 20

canvas = document.createElement("canvas")
canvas.width = width
canvas.height = height
context = canvas.getContext("2d")

random_int = (l, u) ->
  [l, u] = [u, l] if l > u
  Math.floor(Math.random() * (u - l + 1) + l)

random_hex_color = (len=6) ->
  patt = '0123456789ABCDEF'.split ''
  str = '#'
  str += patt[random_int(0, patt.length - 1)] for [1..len]
  str

wedge_product = (xA, yA, xB, yB) ->
  xA*yB - xB*yA

get_distance = (dx, dy) ->
  Math.sqrt(Math.pow(dx,2) + Math.pow(dy,2))

Ball = (x, y, Vx, Vy, radius=r, color='#000000') ->
  @x = x
  @y = y
  @vel = {x: Vx, y: Vy}
  @vel.length = get_distance(@vel.x, @vel.y)
  @radius = radius
  @color = color
  @mass = @radius

random_ball = ->
  new Ball(random_int(100, width - 100), random_int(100, height - 100), random_int(5, 15), random_int(5, 15), r, random_hex_color())

random_balls = (n=3) ->
  random_ball() for [1..n]

Wall = (x, y, wall_width, wall_height) ->
  @x = x
  @y = y
  @width = wall_width
  @height = wall_height

Wall::render = ->
  context.fillStyle = "#000000"
  context.fillRect @x, @y, @width, @height

random_vert_wall = -> new Wall(random_int(100, width - 100), random_int(100, height - 100), wall_thickness0, random_int(100, 300))

random_hor_wall = -> new Wall(random_int(100, width - 100), random_int(100, height - 100), random_int(100, 300), wall_thickness0)

random_walls = (nHor=5, nVert=5) ->
  verts = (random_vert_wall() for [1..nVert])
  hors = (random_hor_wall() for [1..nHor])
  hors.concat verts

all_balls = random_balls(5)
all_walls = random_walls(2,2)

check_balls_collision = (B1, B2) ->
  dx = B1.x - B2.x
  dy = B1.y - B2.y
  return if get_distance(dx, dy) > B1.radius + B2.radius
  angle = Math.atan2(dy, dx)
  u1 = B1.vel
  u2 = B2.vel
  angle1 = Math.atan2(u1.y, u1.x)
  angle2 = Math.atan2(u2.y, u2.x)
  u1x = u1.length * Math.cos(angle1 - angle)
  u1y = u1.length * Math.sin(angle1 - angle)
  u2x = u2.length * Math.cos(angle2 - angle)
  u2y = u2.length * Math.sin(angle2 - angle)
  v1x = ((B1.mass - B2.mass) * u1x + (B2.mass + B2.mass) * u2x) / (B1.mass + B2.mass)
  v2x = ((B1.mass + B1.mass) * u1x + (B2.mass - B1.mass) * u2x) / (B1.mass + B2.mass)
  v1y = u1y
  v2y = u2y
  v1 = {}
  v2 = {}
  v1.x = Math.cos(angle) * v1x + Math.cos(angle + Math.PI / 2) * v1y
  v1.y = Math.sin(angle) * v1x + Math.sin(angle + Math.PI / 2) * v1y
  v1.length = get_distance(v1.x, v1.y)
  v2.x = Math.cos(angle) * v2x + Math.cos(angle + Math.PI / 2) * v2y
  v2.y = Math.sin(angle) * v2x + Math.sin(angle + Math.PI / 2) * v2y
  v2.length = get_distance(v2.x, v2.y)
  B1.vel = v1
  B2.vel = v2

Ball::check_sides_collision = ->
  if @x < r
    @x = r
    @vel.x = -@vel.x
  else if @x > width - r
    @x = width - r
    @vel.x = -@vel.x
  else if @y < r
    @y = r
    @vel.y = -@vel.y
  else if @y > height - r
    @y = height - r
    @vel.y = -@vel.y

Ball::check_walls_collision = (walls) ->
  for wall in walls
    if wall.width == wall_thickness0
      wpVert = wedge_product(0, -wall.height, @x - wall.x, @y - (wall.y + wall.height))
      if wpVert <= 0 and (wall.y - r < @y < wall.y + wall.height + r) and @x + r > wall.x
        @x = wall.x - r
        @vel.x = -@vel.x
      else if wpVert > 0 and (wall.y - r < @y < wall.y + wall.height + r) and @x - r < wall.x + wall.width
        @x = wall.x + wall.width + r
        @vel.x = -@vel.x
    else
    if wall.height == wall_thickness0
      wpHor = wedge_product(wall.width, 0, @x - wall.x, @y - wall.y)
      if wpHor <= 0 and (wall.x - r < @x < wall.x + wall.width + r) and @y + r > wall.y
        @y = wall.y - r
        @vel.y = -@vel.y
      else if wpHor > 0 and (wall.x - r < @x < wall.x + wall.width + r) and @y - r < wall.y + wall.height
        @y = wall.y + wall.height + r
        @vel.y = -@vel.y

Ball::render = ->
  context.beginPath()
  context.arc @x, @y, @radius, 2 * Math.PI, false
  context.fillStyle = @color
  context.fill()

Ball::update = ->
  @x += @vel.x
  @y += @vel.y
  @check_sides_collision()
  @check_walls_collision(all_walls)

render = ->
  context.fillStyle = "#008800"
  context.fillRect(0, 0, width, height)
  ball.render() for ball in all_balls
  wall.render() for wall in all_walls

update = ->
  i = 0
  while i < all_balls.length
    all_balls[i].update()
    j = i + 1
    while j < all_balls.length
      check_balls_collision(all_balls[i],all_balls[j])
      j++
    i++


animate = window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or (callback) ->
  window.setTimeout callback, 1000

window.onload = ->
  document.body.appendChild canvas
  animate step

step = ->
  update()
  render()
  animate step

