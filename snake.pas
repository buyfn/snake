program SnakeGame;
uses crt;
const
  FIELD_WIDTH	    = 30;
  FIELD_HEIGHT	    = 20;
  DELAY_DURATION    = 100;
  SNAKE_BODY_SYMBOL = 'O';
  APPLE_SYMBOL	    = '*';
  WALL_SYMBOL	    = '#';

type
  point	    = record
		x, y : integer;
	      end;
  itemptr   = ^item;
  item	    = record
		data : point;
		next : itemptr;
	      end;
  snake	    = record
		dx, dy : integer;
		body   : itemptr;
	      end;
  apple	    = point;
  gameState = record
		gameOver  : boolean;
		hasTicked : boolean;
		snake	  : snake;
		apple	  : apple;
	      end;

procedure GetKey(var code : integer);
var
  c : char;
begin
  c := ReadKey;
  if c = #0 then
  begin
    c := ReadKey;
    code := -ord(c)
  end
  else
  begin
    code := ord(c)
  end
end;

procedure DrawBorder();
var i : integer;
begin
  for i := 1 to FIELD_WIDTH do
  begin
    GotoXY(i, 1);
    write(WALL_SYMBOL);
    GotoXY(i, FIELD_HEIGHT);
    write(WALL_SYMBOL);
  end;
  for i := 1 to FIELD_HEIGHT do
  begin
    GotoXY(1, i);
    write(WALL_SYMBOL);
    GotoXY(FIELD_WIDTH, i);
    write(WALL_SYMBOL);
  end;
  GotoXY(1, 1)
end;

procedure PrependHead(var head, body : itemptr);
begin
  head^.next := body;
  body := head
end;

procedure RemoveTail(var body : itemptr);
begin
  if (body^.next = nil) then
    body := nil
  else
    RemoveTail(body^.next)
end;

procedure RenderItem(i : item);
begin
  GotoXY(i.data.x, i.data.y);
  write(SNAKE_BODY_SYMBOL);
  GotoXY(1, 1)
end;

procedure RenderSnake(body : itemptr);
begin
  if (body = nil) then exit;
  RenderItem(body^);
  RenderSnake(body^.next)
end;

procedure HideItem(i : item);
begin
  GotoXY(i.data.x, i.data.y);
  write(' ');
  GotoXY(1, 1)
end;

procedure HideSnake(body : itemptr);
begin
  if (body = nil) then exit;
  HideItem(body^);
  HideSnake(body^.next)
end;

procedure CreateApple(var state	: gameState);
begin
  state.apple.x := random(FIELD_WIDTH - 2) + 2;
  state.apple.y := random(FIELD_HEIGHT - 2) + 2;
end;

procedure RenderApple(apple : apple);
begin
  GotoXY(apple.x, apple.y);
  write(APPLE_SYMBOL);
  GotoXY(1, 1)
end;

procedure Render(state : gameState);
begin
  RenderSnake(state.snake.body);
  RenderApple(state.apple)
end;

procedure SetDirection(var state  : gameState;
			   dx, dy : integer);
begin
  if state.gameOver then exit;
  if (state.snake.dx = -dx) and (state.snake.dy = dy) then exit;
  if (state.snake.dy = -dy) and (state.snake.dx = dx) then exit;
  if state.hasTicked then
  begin
    state.snake.dx := dx;
    state.snake.dy := dy;
  end;
  state.hasTicked := false
end;

function Contains(body : itemptr; coord : point) : boolean;
begin
  if (body = nil) then Contains := false else
  if (body^.data.x = coord.x) and (body^.data.y = coord.y) then
    Contains := true
  else
    Contains := Contains(body^.next, coord)
end;

function HasCollided(state    : gameState;
		     newCoord : point) : boolean;
begin
  if (newCoord.x <= 1) or
    (newCoord.x >= FIELD_WIDTH) or
    (newCoord.y <= 1) or
    (newCoord.y >= FIELD_HEIGHT)
  then
    HasCollided := true
  else
    HasCollided := Contains(state.snake.body, newCoord)
end;

procedure Grow(var state : gameState);
var newHead : itemptr;
begin
  new(newHead);
  newHead^.data.x := state.apple.x;
  newHead^.data.y := state.apple.y;
  PrependHead(newHead, state.snake.body)
end;

procedure Tick(var state : gameState);
var
  newCoord : point;
  newHead  : itemptr;
  collided : boolean;
begin
  HideSnake(state.snake.body);

  newCoord.x := state.snake.body^.data.x + state.snake.dx;
  newCoord.y := state.snake.body^.data.y + state.snake.dy;

  if state.gameOver then
  begin
    SetDirection(state, 0, 0);
  end;

  collided := HasCollided(state, newCoord);
  if collided then
  begin
    state.gameOver := true;
    Render(state);
    exit
  end;

  if (newCoord.x = state.apple.x) and (newCoord.y = state.apple.y) then
  begin
    Grow(state);
    CreateApple(state)
  end
  else
    begin
      new(newHead);
      newHead^.data := newCoord;
      PrependHead(newHead, state.snake.body);
      RemoveTail(state.snake.body);
    end;
  Render(state)
end;

procedure Initialize(var state : gameState);
begin
  randomize;
  clrscr;
  DrawBorder();
  state.gameOver := false;
  new(state.snake.body);
  state.snake.body^.data.x := FIELD_WIDTH div 2;
  state.snake.body^.data.y := FIELD_HEIGHT div 2;
  state.snake.dx := 1;
  state.snake.dy := 0;
  CreateApple(state);
  Render(state)
end;

var
  state : gameState;
  c	: integer;
begin
  Initialize(state);
  while true do
  begin
    if not KeyPressed then
    begin
      Tick(state);
      state.hasTicked := true;
      delay(DELAY_DURATION);
      continue
    end;
    GetKey(c);
    if not state.hasTicked then continue;
    case c of
      -75 : SetDirection(state, -1, 0);
      -77 : SetDirection(state, 1, 0);
      -72 : SetDirection(state, 0, -1);
      -80 : SetDirection(state, 0, 1);
      27 : break
    end;
  end;
end.
