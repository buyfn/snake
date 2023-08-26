unit pointlist;
interface

type
  point       = record
                  x, y : integer;
                end;   
  ListItemPtr =  ^ListItem;
  ListItem    = record
                  data : point;
                  next : ListItemPtr;
                end;

procedure PrependHead(var head, list : ListItemPtr);
procedure RemoveLast(var list : ListItemPtr);
function Contains(list : ListItemPtr; coord : point) : boolean;

implementation

function Contains(list : ListItemPtr; coord: point) : boolean;
begin
  if (list = nil) then Contains := false else
  if (list^.data.x = coord.x) and (list^.data.y = coord.y) then
    Contains := true
  else
    Contains := Contains(list^.next, coord)
end;

procedure PrependHead(var head, list : ListItemPtr);
begin
  head^.next := list;
  list := head
end;

procedure RemoveLast(var list : ListItemPtr);
begin
  if (list^.next = nil) then
    list := nil
  else
    RemoveLast(list^.next)
end;

end.
