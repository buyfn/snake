program SnakeGame;
uses crt;
const
  SIZE		    = 20;
  DELAY_DURATION    = 100;
  SNAKE_BODY_SYMBOL = 'M';
  APPLE_SYMBOL	    = '*';

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

type
  point	  = record
	      x, y : integer;
	    end;   
  apple	  = point;
  itemptr = ^item;
  item	  = record
	      data : point;
	      next : itemptr;
	    end;   
  snake	  = record
	      dx, dy : integer;
	      body   : itemptr;
	    end;

procedure DrawBorder(width, height : integer);
var
  i : integer;
begin
  for i := 1 to width do
    begin
      GotoXY(i, 1);
      write('━');
      GotoXY(i, height);
      write('━');
    end;
  for i := 1 to height do
    begin
      GotoXY(1, i);
      write('|');
      GotoXY(width, i);
      write('|');
    end;
  GotoXY(1, 1);
end;

procedure CreateApple(var a : apple);
begin
  a.x := random(SIZE - 3) + 2;
  a.y := random(SIZE - 3) + 2;
end;

procedure ShowApple(a : apple);
begin
  GotoXY(a.x, a.y);
  write(APPLE_SYMBOL);
  GotoXY(1, 1)
end;

procedure HideItem(i : item);
begin
  GotoXY(i.data.x, i.data.y);
  write(' ');
  GotoXY(1, 1)
end;

procedure ShowItem(i : item);
begin
  GotoXY(i.data.x, i.data.y);
  write(SNAKE_BODY_SYMBOL);
  GotoXY(1, 1)
end;

procedure HideSnake(body : itemptr);
begin
  if not (body = nil) then
    begin
      HideItem(body^);
      HideSnake(body^.next)
    end;
end;

procedure ShowSnake(body : itemptr);
begin
  if not (body = nil) then
    begin
      ShowItem(body^);
      ShowSnake(body^.next)
    end;
end;

procedure HideHead(var s : snake);
begin
  GotoXY(s.body^.data.x, s.body^.data.y);
  write(' ');
  GotoXY(1, 1)
end;

procedure RemoveTail(var b : itemptr);
begin
  if (b^.next = nil) then b := nil
  else RemoveTail(b^.next)
end;

procedure PrependHead(var h, b : itemptr);
begin
  h^.next := b;
  b := h;
end;

procedure Grow(var s : snake; p : point);
var
  newHead : itemptr;
begin
  new(newHead);
  newHead^.data.x := p.x;
  newHead^.data.y := p.y;
  PrependHead(newHead, s.body)
end;

function Contains(body : itemptr; coord : point) : boolean;
begin
  if (body = nil) then Contains := false else
  if (body^.data.x = coord.x) and (body^.data.y = coord.y) then
    Contains := true
  else
  Contains := Contains(body^.next, coord)
end;

function HasCollided(
s :			 snake;
size :			 integer;
newCoord :		 point
			 ) : boolean;
begin
  if (s.body^.data.x <= 1) or
    (s.body^.data.x >= size) or
    (s.body^.data.y <= 1) or
    (s.body^.data.y >= size)
  then
    HasCollided := true
  else
    HasCollided := Contains(s.body, newCoord)
end;

procedure SetDirection(var s : snake;
		       var hasTicked: boolean;
			   dx, dy : integer);
begin
  if not hasTicked then exit;
  if (s.dx = -dx) and (s.dy = dy) then exit;
  if (s.dy = -dy) and (s.dx = dx) then exit;
  s.dx := dx;
  s.dy := dy;
  hasTicked := false
end;

procedure Tick(var s	     : snake;
	       var a	     : apple;
	       var hasTicked : boolean;
	       var gameOver  : boolean);
var
  newX, newY  : integer;
  newHead     : itemptr;
  newCoord    : point;
  collided : boolean;
begin
  HideSnake(s.body);

  newCoord.x := s.body^.data.x + s.dx;
  newCoord.y := s.body^.data.y + s.dy;
  collided := HasCollided(s, SIZE, newCoord);

  if collided then
  begin
    setDirection(s, hasTicked, 0, 0);
    gameOver := true;
    ShowSnake(s.body);
    ShowApple(a);
    exit
  end;

  if (newCoord.x = a.x) and (newCoord.y = a.y) then
    begin
      Grow(s, a);
      CreateApple(a)
    end
  else
    begin
      new(newHead);
      newHead^.data := newCoord;
      PrependHead(newHead, s.body);
      RemoveTail(s.body)
    end;

  ShowSnake(s.body);
  ShowApple(a);
  hasTicked := true;
end;

procedure Initialize(size : integer);
begin
  DrawBorder(size, size)
end;

var
  s	    : snake;
  a	    : apple;
  c	    : integer;
  hasTicked, gameOver : boolean;
begin
  randomize;
  clrscr;
  Initialize(SIZE);
  gameOver := false;
  hasTicked := false;
  new(s.body);
  s.body^.data.x := SIZE div 2;
  s.body^.data.y := SIZE div 2;
  s.dx := 1;
  s.dy := 0;
  ShowSnake(s.body);
  CreateApple(a);
  while true do
  begin
    if (not KeyPressed) and (not gameOver) then
    begin
      Tick(s, a, hasTicked, gameOver);
      delay(DELAY_DURATION);
      continue
    end;
    GetKey(c);
    case c of
      -75 : setDirection(s, hasTicked, -1, 0);
      -77 : setDirection(s, hasTicked, 1, 0);
      -72 : setDirection(s, hasTicked, 0, -1);
      -80 : setDirection(s, hasTicked, 0, 1);
      { 32  : setDirection(s, hasTicked, 0, 0); }
      27 : break
    end;
  end;
end.
