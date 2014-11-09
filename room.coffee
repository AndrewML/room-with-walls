r = 100
x0 = 100
y0 = 100
x_speed0 = 12
y_speed0 = 7

wall_length0 = 280
wall_thickness0 = 5

width = window.innerWidth - 20
height = window.innerHeight - 20

canvas = document.createElement("canvas")
canvas.width = width
canvas.height = height
context = canvas.getContext("2d")

randomInt = (l, u) ->
  [l, u] = [u, l] if l > u
  Math.floor(Math.random() * (u - l + 1) + l)

randomHexColor = (len=6)->
  pattern = '0123456789ABCDEF'.split ''
  str = '#'
  str += pattern[randomInt(0,pattern.length-1)] for [1..len]
  str

putRandomWalls = (nHor=5, nVert=5) ->
  hors = (new Wall(randomInt(100, width - 100), randomInt(100, height - 100), wall_thickness0, randomInt(100, 300)) for [1..nHor])
  verts = (new Wall(randomInt(100, width - 100), randomInt(100, height - 100), randomInt(100, 300), wall_thickness0) for [1..nVert])
  hors.concat verts

putRandomBalls = (n=3) ->
  new Ball(randomInt(100, width - 100), randomInt(100, height - 100),randomHexColor()) for [1..n]

wedge_product = (xA, yA, xB, yB) ->
  xA*yB - xB*yA

Ball = (x, y, color) ->
  @x = x
  @y = y
  @x_speed = x_speed0
  @y_speed = y_speed0
  @radius = r
  @color = color

Wall = (x, y, wall_width, wall_height) ->
  @x = x
  @y = y
  @width = wall_width
  @height = wall_height

ball = new Ball(x0, y0)
all_balls = putRandomBalls(2)
all_walls = [] #putRandomWalls()

Ball::render = ->
  context.beginPath()
  context.arc @x, @y, @radius, 2 * Math.PI, false
  context.fillStyle = @color
  context.fill()

Ball::case_sides_collision = ->
  if @x < r
    @x = r
    @x_speed = -@x_speed
  else if @x > width - r
    @x = width - r
    @x_speed = -@x_speed
  else if @y < r
    @y = r
    @y_speed = -@y_speed
  else if @y > height - r
    @y = height - r
    @y_speed = -@y_speed

Ball::case_walls_collision = (walls) ->
  for wall in walls
    if wall.width == wall_thickness0
      wpVert = wedge_product(0, -wall.height, @x - wall.x, @y - (wall.y + wall.height))
      if wpVert <= 0 and (wall.y - r < @y < wall.y + wall.height + r) and @x + r > wall.x
        @x = wall.x - r
        @x_speed = -@x_speed
      else if wpVert > 0 and (wall.y - r < @y < wall.y + wall.height + r) and @x - r < wall.x + wall.width
        @x = wall.x + wall.width + r
        @x_speed = -@x_speed
    else
    if wall.height == wall_thickness0
      wpHor = wedge_product(wall.width, 0, @x - wall.x, @y - wall.y)
      if wpHor <= 0 and (wall.x - r < @x < wall.x + wall.width + r) and @y + r > wall.y
        @y = wall.y - r
        @y_speed = -@y_speed
      else if wpHor > 0 and (wall.x - r < @x < wall.x + wall.width + r) and @y - r < wall.y + wall.height
        @y = wall.y + wall.height + r
        @y_speed = -@y_speed

Ball::update = ->
  @x += @x_speed
  @y += @y_speed
  @case_sides_collision()
  @case_walls_collision(all_walls)

Wall::render = ->
  context.fillStyle = "#000000"
  context.fillRect @x, @y, @width, @height

render = ->
  context.fillStyle = "#008800";
  context.fillRect(0, 0, width, height);
  wall.render() for wall in all_walls
  ball.render() for ball in all_balls

update = ->
  ball.update() for ball in all_balls

animate = window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or (callback) ->
  window.setTimeout callback, 100

window.onload = ->
  document.body.appendChild canvas
  animate step

step = ->
  update()
  render()
  animate step


