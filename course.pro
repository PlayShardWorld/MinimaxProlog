/*****************************************************************************

		Copyright (c) Our Company

 Project:  COURSE
 FileName: COURSE.PRO
 Purpose: No description
 Written by: Visual Prolog 5.2
 Comments:
******************************************************************************/

include "course.inc"
include "course.con"
include "hlptopic.con"

%BEGIN_WIN Task Window
/***************************************************************************
		Event handling for Task Window
***************************************************************************/
%======================================================================================================================%
% Циклы для заполнения БД
%
% size(Size), for(1, Size), % Заполнение поля
% nondeterm for(integer, integer) % Цикл for
% nondeterm for2(integer, integer, integer) % Цикл for
% for2(I, N, R):- I > N, !; КОСТЫЛИ
%	write(R, " ", I, "\n"), assert(field(R, I, "_")), 
%	I1 = I + 1, for2(I1, N, R).
% for(I, N):- I > N, !;
%	size(Size), for2(1, Size, I),
%	I1 = I + 1, for(I1, N).
%

/*
Хранимые значения:
1. Игровое поле
2. Тип фишки человека
3. Тип фишки компьютера

Набор необходимых предикат:
0. Проверка случая победы
1. Установить фишку по индексу
2. Получить фишку по индексу
3. Проверить фишку по индексу
4. Сделать ход
5. Проверить свободные поля
6. Метод минимакса
7. Перевод числа в координаты
8. Генерирование возможных ходов (СП)
9. Выбор лучшего хода из сгенерированных (СП)
10. Поиск любых возможных ходов (СП)
11. Вычисление стоимости хода (больше - лучше, для минимакса)

Набор отладочных предикат:
1. Вывод поля на экран
*/
%===============================================================================
%domains
%ilist = integer*
%slist = symbol*
constants
	ceil_size = 80		% Размер клетки
	top_offset = 25		% Отступ сверху
	left_offset = 25	% Отступ слева

database - main
board(integer, integer, symbol)
boardsize(integer)
winlength(integer)
pmm(integer)
pchip(symbol)
cchip(symbol)

predicates
% Инициализация игрового поля
destruction 
destruction(integer)
initialization 
initialization(integer)
drawLast(window, integer, integer, symbol)

% Проверка свободных полей
checkfree

% Проверка наличия победы
continue(symbol)
continue(symbol, integer)

maxlength(symbol, integer, integer, integer) % i i i o
maxlength(symbol, integer, integer, integer, integer, integer) % i o
maxlength(symbol, integer, integer, integer, integer, integer, integer) % i o
maxlengthzero(symbol, integer, integer, integer) % i i i o

max(integer, integer, integer, integer, integer)

% Отображение игрового поля
drawField(window, integer)

get(integer, integer, symbol)
	% integer - координата по X
	% integer - координата по Y
	% symbol - сюда будет помещено хранимое значение
	
set(integer, integer, symbol)
	% integer - координата по X
	% integer - координата по Y
	% symbol - этот символ будет помещён на своё место
	
del(integer, integer, symbol)
	% integer - координата по X
	% integer - координата по Y
	% symbol - символ
	
turn(window)
	% integer - номер игрока, чей производится ход
	
unfold(integer, integer, integer) % Перевод числа в координаты
	% integer - номер элемента
	% integer - координата по X
	% integer - координата по Y
findmaxzero(slist, symbol, integer)
checkfindzero(symbol, ilist, integer, integer)	
minimax(slist, symbol, integer, integer, integer)
	% integer - глубина поиска решения
	% integer - следующий лучший ход
	% integer - значение
	
genmoves(slist, symbol, ilist)
	% ilist - список возможных ходов
genmoves(slist, symbol, ilist, integer, integer)
	% ilist - список возможных ходов
	% integer - рассматриваемый ход
	% integer - количество найденных ходов

choose(slist, symbol, integer, ilist, integer, integer)
	% integer - глубина поиска
	% ilist - список возможных ходов
	% integer - выбранный ход
	% integer - вес хода
	
findfree(slist, integer, ilist)
	% ilist - список пустых ходов
	% integer - рассматриваемый ход
	
% Перевод поля в список
tolist(slist)
tolist(slist, integer)

opponent(symbol, symbol)
max(integer, integer, integer, integer, integer, integer)
value(slist, symbol, integer, integer)
good(slist, symbol, integer)
set(slist, integer, symbol, slist) % Создание нового списка и измененными значениями
	% list - игровое поле
	% integer - номер в списке
	% symbol - записываемый символ
	% list - новое игровое поле
	
	
	
	
	
	
	
sget(slist, integer, symbol) % Получение символа по номеру из списка
	% list - игровое поле
	% integer - номер в списке
	% symbol - отсюда будет взят символ
sget(slist, integer, integer, symbol) % Получение символа по индексам из списка
	% list - игровое поле
	% integer - индекс по X
	% integer - индекс по Y
	% symbol - отсюда будет взят символ	
	
nonblocking(symbol, symbol)		
points(integer, integer) % Расчёт очков за ряд
points(slist, integer, integer, symbol, integer)
points(slist, integer, integer, symbol, integer, integer, integer)
points(slist, integer, integer, symbol, integer, integer, integer, integer)	
open(integer, integer) % Расчёт очков за ряд с учётом открытых полей
open(slist, integer, integer, symbol, integer)
open(slist, integer, integer, symbol, integer, integer, integer)
open(slist, integer, integer, symbol, integer, integer, integer, integer)	
valid(integer)	
	
	
	
	
	
	
	
	
	
	
	
clauses
%==============================================================================%
% Обязательная часть игры
%==============================================================================%
% Переинициализация игрового поля размером Size*Size
destruction:-
	get(0, 0, _),
	boardsize(Size),
	N = Size * Size - 1,
	destruction(N), !.
destruction(-1):- !.
destruction(N):-
	boardsize(Size),
	X = N mod Size,
	Y = (N - X) div Size,
	del(X, Y, "_"), !,
	N1 = N - 1,
	destruction(N1);
	boardsize(Size),
	X = N mod Size,
	Y = (N - X) div Size,
	del(X, Y, "O"), !,
	N1 = N - 1,
	destruction(N1);
	boardsize(Size),
	X = N mod Size,
	Y = (N - X) div Size,
	del(X, Y, "X"), !,
	N1 = N - 1,
	destruction(N1).
%==============================================================================%
% Инициализация игрового поля размером Size*Size
initialization:-
	boardsize(Size),
	N = Size * Size - 1,
	initialization(N), !.
initialization(-1):- !.
initialization(N):-
	boardsize(Size),
	X = N mod Size,
	Y = (N - X) div Size,
	set(X, Y, "_"),
	N1 = N - 1,
	initialization(N1), !.
%==============================================================================%
% Получение и проверка символа по заданным индексам
get(X, Y, F):- board(X, Y, F), !.
%==============================================================================%
% Установка символа по заданным индексам
set(X, Y, F):- assert(board(X, Y, F)), !.
%==============================================================================%
% Удаление символа по заданным индексам
del(X, Y, F):- retract(board(X, Y, F)), !.
%==============================================================================%
% Проверка поля на пустые символы (доступные ходы)
checkfree:- board(_, _, "_"), !.
%==============================================================================%
% Проверка поля на наличие победных комбинаций
continue(F):- % Проверка для всех заполненных клеток
	boardsize(_BoardSize),
	N = _BoardSize * _BoardSize - 1,
	continue(F, N), !.
% Если поле закончилось - труе
continue(_, -1):- !. % Победа не найдена
continue(F, N):-
	% Вызываем ml для каждой клетки
	boardsize(Size),		% Получение размера поля
	X = N mod Size,			% Расчёт координаты X
	Y = (N - X) div Size,		% Расчёт координаты Y
	get(X, Y, F),			% Проверка, что в клетке символ игрока
	maxlength(F, X, Y, Length),	% Получаем длину комбинации для клетки X:Y
	winlength(WLength),		% Получаем выигрышную длину
	Length < WLength,
	N1 = N - 1,
	continue(F, N1), !.
continue(F, N):-
	% Проверка что символ был пустым или не игрока
	boardsize(Size),		% Получение размера поля
	X = N mod Size,			% Расчёт координаты X
	Y = (N - X) div Size,		% Расчёт координаты Y
	not(get(X, Y, F)),
	N1 = N - 1,
	continue(F, N1), !.
%==============================================================================%
% Length - необходимая длина для победы
% N - Номер рассматриваемой клетки в списке
maxlength(F, X, Y, Length):-
	get(X, Y, F),
	maxlength(F, X, Y, 1, 0, L1), % Проверка по горизонтали
	maxlength(F, X, Y, 0, 1, L2), % Проверка по вертикали
	maxlength(F, X, Y, 1, 1, L3), % Проверка по диагонали
	maxlength(F, X, Y, 1, -1, L4), % Проверка по диагонали
	max(L1, L2, L3, L4, Length). % Получаем максимальную длину
	
maxlength(F, X, Y, DX, DY, Length):-
	maxlength(F, X, Y, DX, DY, 1, L1),
	MDX = -DX, MDY = -DY,
	maxlength(F, X, Y, MDX, MDY, 1, L2),
	Length = L1 + L2 + 1. % Получение длины

maxlength(_, _, _, _, _, L, 0):-
	winlength(WL),
	WL = L, !.
maxlength(F, X, Y, DX, DY, D, Length):-
	X1 = X + DX * D, % Получение новой позиции по X
	Y1 = Y + DY * D, % Получение новой позиции по Y
	get(X1, Y1, F), % Проверка символа клетки на совпадение с символом игрока
	D1 = D + 1,
	maxlength(F, X, Y, DX, DY, D1, Length1),
	Length = Length1 + 1, !.
maxlength(_, _, _, _, _, _, 0).

maxlengthzero(F, X, Y, Length):-
	get(X, Y, "_"),
	maxlength(F, X, Y, 1, 0, L1), % Проверка по горизонтали
	maxlength(F, X, Y, 0, 1, L2), % Проверка по вертикали
	maxlength(F, X, Y, 1, 1, L3), % Проверка по диагонали
	maxlength(F, X, Y, 1, -1, L4), % Проверка по диагонали
	max(L1, L2, L3, L4, Length). % Получаем максимальную длину

max(A, B, C, D, A):- A >= B, A >= C, A >= D, !.
max(A, B, C, D, B):- B >= A, B >= C, B >= D, !.
max(A, B, C, D, C):- C >= A, C >= B, C >= D, !.
max(A, B, C, D, D):- D >= A, D >= B, D >= C, !.

% Board, Number, ML

findmaxzero(BL, F, N):-
	findfree(BL, 0, ML),
	checkfindzero(F, ML, 0, N), !.

checkfindzero(_, [], _, _):- !, fail.
checkfindzero(F, [H|_], _, H):-
	unfold(H, X, Y),
	maxlengthzero(F, X, Y, Length),
	winlength(WLength),
	Length >= WLength, !.
checkfindzero(F, [_|T], N, M):-
	checkfindzero(F, T, N, M).
	
%==============================================================================%
% Перевод номера в списке в координаты
unfold(M, X, Y):-
	boardsize(Size),
	X = M mod Size,
	Y = (M - X) div Size, !.
%==============================================================================%
% Сбор всех доступных ходов
% Списочный вариант поиска доступных ходов
findfree([], _, []).
findfree(["_"|T], N, [N|RT]):-
	N1 = N + 1,
	findfree(T, N1, RT), !.
findfree([_|T], N, RT):-
	N1 = N + 1,
	findfree(T, N1, RT).
/*
findfree(ML):-
	boardsize(Size),
	N = Size * Size - 1,
	findfree(ML, N), !.
findfree([], -1):- !.
findfree([N|T], N):-
	boardsize(Size),
	X = N mod Size,       % получаем координату по X
	Y = (N - X) div Size, % получаем координату по Y
	get(X, Y, "_"), % проверка на пустоту
	N1 = N - 1,
	findfree(T, N1), !.
findfree(T, N):-
	N1 = N - 1,
	findfree(T, N1), !.
*/
%==============================================================================%
% Установка символа в списке по номеру
set([_|T], 0, X, [X|T]):- !.
set([H|T], N, X, [H|R]):- % Составляем новое поле с изменёнными значениями
	N1 = N - 1,
	set(T, N1, X, R). % Рекурсивный вызов предиката
%==============================================================================%
% Генератор возможных ходов
% B - игровое поле
% F - символ текущего игрока
% ML - список доступных ходов
% i i o
genmoves(B, F, ML):- 
	genmoves(B, F, ML, 0, MC), % генерируем ходы
	MC > 0, !.
genmoves(B, _, ML):-
	findfree(B, 0, ML). % ищем любые доступные ходы
	
% N - номер проверяемой клетки
% MC - ???
% i i o i o тут неточно, код был написан пару дней назад и незадокументирован
genmoves(_, _, [], N, 0):-
	boardsize(Size),
	N = Size * Size, !.
genmoves(B, F, [N|T], N, MC):-
	good(B, F, N), % Проверка хода на адекватность
	N1 = N + 1, % берём следующую клетку
	genmoves(B, F, T, N1, MC1),
	MC = MC1 + 1, !. % увеличиваем количество полученных ходов на 1
genmoves(B, F, T, N, MC):-
	N1 = N + 1, % берём следующую клетку
	genmoves(B, F, T, N1, MC).
%==============================================================================%
% Выбор лучшего хода
% B - поле
% F - фишка текущего игрока
% D - глубина поиска минимакса
% ML ([H|T]) - список ходов
% M - выбранный ход минимакса
% V - стоимость хода
% i i i i o o
choose(_, _, _, [], -1, -999):- !. % Случай, когда не из чего выбирать ERR
choose(B, F, D, [H|T], M, V):-
	value(B, F, H, V1), % Расчёт очков для хода 'H'
	set(B, H, F, NB), % Установка нового символа
	opponent(F, FO), % В этом месте раскрывается суть минимакса (лучший для меня - худший для компьютера)
	D1 = D - 1,
	minimax(NB, FO, D1, _, V2), % Вызов минимакса с новым полем для оппонента
	VH = V1 - V2, % Для пары хода %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	choose(B, F, D, T, MT, VT),
	max(VH, H, VT, MT, V, M).
%==============================================================================%
max(VH, H, VT, _, VH, H):-
	VH > VT, !.
max(_, _, VT, MT, VT, MT).
%==============================================================================%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Расчёт очков хода
% Фактически: М - атака, О - защита
value(B, F, M, Points):- % M - ход минимакса, P - очки хода
	unfold(M, X, Y),
	points(B, X, Y, F, RPoM),
	open(B, X, Y, F, ROpM),
	opponent(F, FO),
	points(B, X, Y, FO, RPoO),
	open(B, X, Y, FO, ROpO),
	Points = 17 * RPoM + 9 * RPoO + 3 * ROpM + 1 * ROpO, !. % + защита
%==============================================================================%
good(B, F, M):-
	value(B, F, M, Points),
	Points > 25.
%==============================================================================%
opponent("X", "O").
opponent("O", "X").
%==============================================================================%
% Перевод поля в список
tolist(BL):- tolist(BL, 0), !.
tolist([], N):- 
	boardsize(Size),
	N = Size * Size, !.
tolist([H|BL], N):-
	boardsize(Size),
	X = N mod Size,
	Y = (N - X) div Size,
	get(X, Y, H),
	N1 = N + 1,
	tolist(BL, N1), !.
%==============================================================================%
% Моя фишка или открытое поле
nonblocking("_", _):- !.
nonblocking(A, A):- !.
%==============================================================================%
% Получение или проверка символа из/в списке [H]
% i i o/i
sget([H|_], 0, H):- !.
sget([_|T], N, R):- % Проходим по списку, чтобы вытащить необходимый символ
	N1 = N - 1,
	sget(T, N1, R), !. % Рекурсивный вызов предиката
sget(B, X, Y, R):-
	boardsize(S),
	-1 < X, X < S, % Проверяем, что индекс по X допустим
	-1 < Y, Y < S, % Проверяем, что индекс по Y допустим
	N = X + S * Y, % Получаем номер символа в списке
	sget(B, N, R), !. % Получаем символ и записываем его в R
%==============================================================================%
% Кодярина
% B - игровое поле (Board)
% X - координата по X
% Y - координата по Y
% F - фишка игрока (fishka ???)
% P - очки (Points)
% i i i i o
points(B, X, Y, F, Points):-
	sget(B, X, Y, "_"), % Проверяем клетку [X:Y] на пустоту
	points(B, X, Y, F, 1, 0, P1),  % Проверка по горизонтали [6]
	points(B, X, Y, F, 0, 1, P2),  % Проверка по вертикали   [8]
	points(B, X, Y, F, 1, 1, P3),  % Проверка по диагонали   [68]
	points(B, X, Y, F, 1, -1, P4), % Проверка по диагонали   [62]
	Points = P1 + P2 + P3 + P4. % Суммируем полученные очки
	
% DX - смещение по X
% DY - смещение по Y
% i i i i i i o	
points(B, X, Y, F, DX, DY, Points):-
	points(B, X, Y, F, DX, DY, 1, P1), % Проверка вперёд (вверх-вправо(3))
	MDX = -DX, MDY = -DY,
	points(B, X, Y, F, MDX, MDY, 1, P2), % Проверка назад (вниз-влево(3))
	PS = P1 + P2 + 1, % Получение длины составленного ряда
	points(PS, Points). % Перевод в очки
	
% D - начальная длина ряда
% N - длина ряда
% i i i i i i i o
points(_, _, _, _, _, _, D, 0):- winlength(WLength), D - 1 = WLength, !. % Поиск комбинаций, не длинее чем D-1 клет[ки/ок]
points(B, X, Y, F, DX, DY, D, N):-
	X1 = X + DX * D, % Получение новой позиции по X
	Y1 = Y + DY * D, % Получение новой позиции по Y
	sget(B, X1, Y1, F), % Проверка символа клетки на совпадение с символом игрока
	D1 = D + 1,
	points(B, X, Y, F, DX, DY, D1, N1), % Рекурсивный вызов проверки
	N = N1 + 1, !. % Добавление единицы к длине ряда
points(_, _, _, _, _, _, _, 0).

% i o
points(1, 0):- !. % Если ряд не образован - 0 очков
/*points(N, Points):-
	winlength(WLength),
	N - 1 >= WLength,
	Points = 5, !.*/
points(N, Points):-
	Points = N - 2, !. % Перевод длины ряда в очки
%==============================================================================%
% B - игровое поле (Board)
% X - координата по X
% Y - координата по Y
% F - фишка игрока (fishka ???)
% P - очки (Points)
% i i i i o
open(B, X, Y, F, Points):-
	sget(B, X, Y, "_"), % Проверяем клетку [X:Y] на пустоту
	open(B, X, Y, F, 1, 0, P1),  % Проверка по горизонтали [6]
	open(B, X, Y, F, 0, 1, P2),  % Проверка по вертикали   [8]
	open(B, X, Y, F, 1, 1, P3),  % Проверка по диагонали   [68]
	open(B, X, Y, F, 1, -1, P4), % Проверка по диагонали   [62]
	Points = P1 + P2 + P3 + P4. % Суммируем полученные очки
	
% DX - смещение по X
% DY - смещение по Y
% i i i i i i o	
open(B, X, Y, F, DX, DY, Points):-
	open(B, X, Y, F, DX, DY, 1, P1), % Проверка вперёд (вверх-вправо(3))
	MDX = -DX, MDY = -DY,
	open(B, X, Y, F, MDX, MDY, 1, P2), % Проверка назад (вниз-влево(3))
	PS = P1 + P2 + 1, % Получение длины составленного ряда
	open(PS, Points). % Перевод в очки
	
% D - начальная длина ряда
% N - длина ряда
% i i i i i i i o
open(_, _, _, _, _, _, D, 0):- winlength(WLength), D - 1 = WLength, !. % Поиск комбинаций, не длинее чем D клет[ки/ок]
open(B, X, Y, F, DX, DY, D, N):-
	X1 = X + DX * D, % Получение новой позиции по X
	Y1 = Y + DY * D, % Получение новой позиции по Y
	sget(B, X1, Y1, M), % Запись значения выбранной клетки в M
	nonblocking(M, F),  % Проверка клетки на совпадение или на пустоту
	D1 = D + 1,
	open(B, X, Y, F, DX, DY, D1, N1), % Рекурсивный вызов проверки
	N = N1 + 1, !. % Добавление единицы к длине ряда
open(_, _, _, _, _, _, _, 0).

% i o
open(1, 0):- !. % Если ряд не образован - 0 очков
/*open(N, Points):-
	winlength(WLength),
	N - 1 >= WLength,
	Points = 5000, !.*/
open(N, Points):-
	Points = N - 2. % Перевод длины ряда в очки
%==============================================================================%
% Минимакс
minimax(_, _, _, 4, 0):- % ход в середину, если она свободна
	boardsize(3),
	get(1, 1, "_"), !.
minimax(_, _, 0, 0, 0):- !.
minimax(B, F, D, M, V):-
	%write("Minimax"), nl,
	genmoves(B, F, ML), % генерируем возможные ходы и записываем их в ML
	%write(ML),
	choose(B, F, D, ML, M, V). % выбираем лучший ход
%==============================================================================%
% Ходы
% проверка атаки
turn(_Win):-
	checkfree, % Проверка на доступные поля
	cchip(F),  % Получение фишки компьютера
	tolist(BL), % перевод доски в список
	findmaxzero(BL, F, M),
	unfold(M, X, Y), % Перевод значения в координаты
  	valid(X),
  	valid(Y),
  	del(X, Y, "_"),
  	set(X, Y, F),
  	drawField(_Win, 0), drawLast(_Win, X, Y, F),
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	str_int(_sX, X), str_int(_sY, Y),
  	format(_sTEMP, "Компьютер   % - %", _sY, _sX),
  	lbox_Add(_hListBox, -1, _sTEMP),
  	continue(F),
  	_hText = win_GetCtlHandle(_Win, idc_text),
  	win_SetText(_hText, "Ход человека"), !;
  	
% проверка защиты
	checkfree, % Проверка на доступные поля
	cchip(F),  % Получение фишки компьютера
	continue(F),
	pchip(PF),  % Получение фишки человека
	tolist(BL), % перевод доски в список
	findmaxzero(BL, PF, M),
	unfold(M, X, Y), % Перевод значения в координаты
  	valid(X),
  	valid(Y),
  	del(X, Y, "_"),
  	set(X, Y, F),
  	drawField(_Win, 0), drawLast(_Win, X, Y, F),
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	str_int(_sX, X), str_int(_sY, Y),
  	format(_sTEMP, "Компьютер   % - %", _sY, _sX),
  	lbox_Add(_hListBox, -1, _sTEMP),
  	continue(F),
  	_hText = win_GetCtlHandle(_Win, idc_text),
  	win_SetText(_hText, "Ход человека"), !;
  	
	checkfree, % Проверка на доступные поля
	cchip(F),  % Получение фишки компьютера
	continue(F),
	tolist(BL), % перевод доски в список
	pmm(_Power),
	minimax(BL, "O", _Power, M, _), % Запуск метода минимакса для поиска хода
	M >= 0,
	unfold(M, X, Y), % Перевод значения в координаты
  	valid(X),
  	valid(Y),
  	del(X, Y, "_"),
  	set(X, Y, F),
  	drawField(_Win, 0), drawLast(_Win, X, Y, F),
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	str_int(_sX, X), str_int(_sY, Y),
  	format(_sTEMP, "Компьютер   % - %", _sY, _sX),
  	lbox_Add(_hListBox, -1, _sTEMP),
  	continue(F),
  	_hText = win_GetCtlHandle(_Win, idc_text),
  	win_SetText(_hText, "Ход человека"),
  	!;
  	checkfree, % Проверка на доступные поля
	cchip(F),  % Получение фишки компьютера
	continue(F),
	tolist(BL), % перевод доски в список
	findfree(BL, 0, [M|_]),
	unfold(M, X, Y), % Перевод значения в координаты
  	valid(X),
  	valid(Y),
  	del(X, Y, "_"),
  	set(X, Y, F),
  	drawField(_Win, 0), drawLast(_Win, X, Y, F),
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	str_int(_sX, X), str_int(_sY, Y),
  	format(_sTEMP, "Компьютер   % - %", _sY, _sX),
  	lbox_Add(_hListBox, -1, _sTEMP),
  	continue(F),
  	_hText = win_GetCtlHandle(_Win, idc_text),
  	win_SetText(_hText, "Ход человека"), 
  	!;
  	
  	cchip(_ComputerChip), 
  	not(continue(_ComputerChip)), 
  	dlg_Note("Конец игры", "Компьютер победил!"),
	_hText = win_GetCtlHandle(_Win, idc_text), win_SetText(_hText, "Компьютер победил!"), 
	!;
	
	not(checkfree),
	dlg_Note("Конец игры", "Ничья!"),
	_hText = win_GetCtlHandle(_Win, idc_text), win_SetText(_hText, "Ничья!"), 
	!;
	
	dlg_Note("ERROR #677", "Ошибка алгоритма!"), 
	!.

%======================================================================================================================%
% Отрисовка клетки
drawField(_Win, N):-
	% Отрисовка пустой клетки
	boardsize(_BoardSize),
	N < _BoardSize * _BoardSize,
	X = N div _BoardSize,
	Y = N mod _BoardSize,
	board(X, Y, "_"), !,
	
	% Отрисовка фона клетки
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	_X1 = left_offset + X * ceil_size,
	_Y1 = top_offset + Y * ceil_size,
	_X2 = _X1 + ceil_size,
	_Y2 = _Y1 + ceil_size,
	draw_Rect(_Win, rct(_X1, _Y1, _X2, _Y2)),
	
	% Отрисовка текста
	_XT = _X1 + 1,
	_YT = _Y1 + ceil_size div 6 + 1,
	format(_sCOORD, "% - %", Y, X), 
	draw_Text(_Win, _XT, _YT, _sCOORD),
	
  	N1 = N + 1,
  	drawField(_Win, N1);
  	
  	%==============================================================================================================%
	% Отрисовка крестика
	boardsize(_BoardSize),
	N < _BoardSize * _BoardSize,
	X = N div _BoardSize,
	Y = N mod _BoardSize,
	board(X, Y, "X"), !,
	
	% Отрисовка фона клетки
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	_X1 = left_offset + X * ceil_size,
	_Y1 = top_offset + Y * ceil_size,
	_X2 = _X1 + ceil_size,
	_Y2 = _Y1 + ceil_size,
	draw_Rect(_Win, rct(_X1, _Y1, _X2, _Y2)),
	
	% Отрисовка текста
	_XT = _X1 + 1,
	_YT = _Y1 + ceil_size div 6 + 1,
	format(_sCOORD, "% - %", Y, X), 
	draw_Text(_Win, _XT, _YT, _sCOORD),
	
	_XCoord = left_offset + X * ceil_size + ceil_size div 2,
	_YCoord =  top_offset + Y * ceil_size + ceil_size div 2,
	
	X1 = _XCoord - ceil_size div 3,
	Y1 = _YCoord - ceil_size div 6,
	X2 = _XCoord - ceil_size div 6,
	Y2 = _YCoord - ceil_size div 3,
	X3 = _XCoord,
	Y3 = _YCoord - ceil_size div 6,
	X4 = _XCoord + ceil_size div 6,
	Y4 = _YCoord - ceil_size div 3,
	X5 = _XCoord + ceil_size div 3,
	Y5 = _YCoord - ceil_size div 6,
	X6 = _XCoord + ceil_size div 6,
	Y6 = _YCoord,
	X7 = _XCoord + ceil_size div 3,
	Y7 = _YCoord + ceil_size div 6,
	X8 = _XCoord + ceil_size div 6,
	Y8 = _YCoord + ceil_size div 3,
	X9 = _XCoord,
	Y9 = _YCoord + ceil_size div 6,
	X10 = _XCoord - ceil_size div 6,
	Y10 = _YCoord + ceil_size div 3,
	X11 = _XCoord - ceil_size div 3,
	Y11 = _YCoord + ceil_size div 6,
	X12 = _XCoord - ceil_size div 6,
	Y12 = _YCoord,
	
	win_SetBrush(_Win, brush(pat_Solid, 13200000)), % Установка цвета кисти
	%win_SetBrush(_Win, brush(pat_Solid, 16747520)), % Установка цвета кисти
	draw_Polygon(_Win, [
		pnt(X1, Y1), 
		pnt(X2, Y2), 
		pnt(X3, Y3), 
		pnt(X4, Y4), 
		pnt(X5, Y5), 
		pnt(X6, Y6), 
		pnt(X7, Y7), 
		pnt(X8, Y8), 
		pnt(X9, Y9), 
		pnt(X10, Y10), 
		pnt(X11, Y11), 
		pnt(X12, Y12) 
	]),
  	N1 = N + 1,
  	drawField(_Win, N1);
  	
  	%==============================================================================================================%
	% Отрисовка нолика
	boardsize(_BoardSize),
	N < _BoardSize * _BoardSize,
	X = N div _BoardSize,
	Y = N mod _BoardSize,
	board(X, Y, "O"), !,
	
	% Отрисовка фона клетки
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	_X1 = left_offset + X * ceil_size,
	_Y1 = top_offset + Y * ceil_size,
	_X2 = _X1 + ceil_size,
	_Y2 = _Y1 + ceil_size,
	draw_Rect(_Win, rct(_X1, _Y1, _X2, _Y2)),
	
	% Отрисовка текста
	_XT = _X1 + 1,
	_YT = _Y1 + ceil_size div 6 + 1,
	format(_sCOORD, "% - %", Y, X), 
	draw_Text(_Win, _XT, _YT, _sCOORD),
			
	_XCoord = left_offset + X * ceil_size + ceil_size div 2,
	_YCoord =  top_offset + Y * ceil_size + ceil_size div 2,
	
  	X1 = _XCoord - ceil_size div 3,		% координаты прямоугольника для впиывания круга
  	X2 = _XCoord + ceil_size div 3,
  	Y1 = _YCoord - ceil_size div 3,
  	Y2 = _YCoord + ceil_size div 3,
	win_SetBrush(_Win, brush(pat_Solid, 5275647)), % Установка цвета кисти
	draw_Ellipse(_Win, rct(X1, Y1, X2, Y2)),
	
	X3 = _XCoord - ceil_size div 6,		% координаты прямоугольника для впиывания круга
  	X4 = _XCoord + ceil_size div 6,
  	Y3 = _YCoord - ceil_size div 6,
  	Y4 = _YCoord + ceil_size div 6,
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	draw_Ellipse(_Win, rct(X3, Y3, X4, Y4)),
	
  	N1 = N + 1,
  	drawField(_Win, N1).
  	
drawField(_, _).
%======================================================================================================================%
drawLast(_Win, X, Y, "X"):- 
	% Отрисовка фона клетки
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	_X1 = left_offset + X * ceil_size,
	_Y1 = top_offset + Y * ceil_size,
	_X2 = _X1 + ceil_size,
	_Y2 = _Y1 + ceil_size,
	draw_Rect(_Win, rct(_X1, _Y1, _X2, _Y2)),
	
	% Отрисовка текста
	_XT = _X1 + 1,
	_YT = _Y1 + ceil_size div 6 + 1,
	format(_sCOORD, "% - %", Y, X), 
	draw_Text(_Win, _XT, _YT, _sCOORD),
	
	_XCoord = left_offset + X * ceil_size + ceil_size div 2,
	_YCoord =  top_offset + Y * ceil_size + ceil_size div 2,
	
	X1 = _XCoord - ceil_size div 3,
	Y1 = _YCoord - ceil_size div 6,
	X2 = _XCoord - ceil_size div 6,
	Y2 = _YCoord - ceil_size div 3,
	X3 = _XCoord,
	Y3 = _YCoord - ceil_size div 6,
	X4 = _XCoord + ceil_size div 6,
	Y4 = _YCoord - ceil_size div 3,
	X5 = _XCoord + ceil_size div 3,
	Y5 = _YCoord - ceil_size div 6,
	X6 = _XCoord + ceil_size div 6,
	Y6 = _YCoord,
	X7 = _XCoord + ceil_size div 3,
	Y7 = _YCoord + ceil_size div 6,
	X8 = _XCoord + ceil_size div 6,
	Y8 = _YCoord + ceil_size div 3,
	X9 = _XCoord,
	Y9 = _YCoord + ceil_size div 6,
	X10 = _XCoord - ceil_size div 6,
	Y10 = _YCoord + ceil_size div 3,
	X11 = _XCoord - ceil_size div 3,
	Y11 = _YCoord + ceil_size div 6,
	X12 = _XCoord - ceil_size div 6,
	Y12 = _YCoord,
	
	win_SetBrush(_Win, brush(pat_Solid, color_Green)), % Установка цвета кисти
	draw_Polygon(_Win, [
		pnt(X1, Y1), 
		pnt(X2, Y2), 
		pnt(X3, Y3), 
		pnt(X4, Y4), 
		pnt(X5, Y5), 
		pnt(X6, Y6), 
		pnt(X7, Y7), 
		pnt(X8, Y8), 
		pnt(X9, Y9), 
		pnt(X10, Y10), 
		pnt(X11, Y11), 
		pnt(X12, Y12) 
	]), !.

drawLast(_Win, X, Y, "O"):-
	% Отрисовка фона клетки
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	_X1 = left_offset + X * ceil_size,
	_Y1 = top_offset + Y * ceil_size,
	_X2 = _X1 + ceil_size,
	_Y2 = _Y1 + ceil_size,
	draw_Rect(_Win, rct(_X1, _Y1, _X2, _Y2)),
	
	% Отрисовка текста
	_XT = _X1 + 1,
	_YT = _Y1 + ceil_size div 6 + 1,
	format(_sCOORD, "% - %", Y, X), 
	draw_Text(_Win, _XT, _YT, _sCOORD),
	
	_XCoord = left_offset + X * ceil_size + ceil_size div 2,
	_YCoord =  top_offset + Y * ceil_size + ceil_size div 2,
	
  	X1 = _XCoord - ceil_size div 3,		% координаты прямоугольника для впиывания круга
  	X2 = _XCoord + ceil_size div 3,
  	Y1 = _YCoord - ceil_size div 3,
  	Y2 = _YCoord + ceil_size div 3,
	win_SetBrush(_Win, brush(pat_Solid, color_Green)), % Установка цвета кисти
	draw_Ellipse(_Win, rct(X1, Y1, X2, Y2)),
	
	X3 = _XCoord - ceil_size div 6,		% координаты прямоугольника для впиывания круга
  	X4 = _XCoord + ceil_size div 6,
  	Y3 = _YCoord - ceil_size div 6,
  	Y4 = _YCoord + ceil_size div 6,
	win_SetBrush(_Win, brush(pat_Solid, color_White)), % Установка цвета кисти
	draw_Ellipse(_Win, rct(X3, Y3, X4, Y4)), !.
%======================================================================================================================%
valid(I) :- 
	boardsize(_BoardSize),	% выбрать размер поля
	I >= 0,			% проверка нижней границы
	I < _BoardSize, !.	% проверка верхней границы
%======================================================================================================================%

predicates

  task_win_eh : EHANDLER

constants

%BEGIN Task Window, CreateParms, 14:49:40-14.5.2018, Code automatically updated!
  task_win_Flags = [wsf_SizeBorder,wsf_TitleBar,wsf_Close,wsf_Maximize,wsf_Minimize,wsf_ClipSiblings]
  task_win_Menu  = res_menu(idr_task_menu)
  task_win_Title = "Invincible"
  task_win_Help  = idh_contents
%END Task Window, CreateParms

clauses

%BEGIN Task Window, e_Create
  task_win_eh(_Win,e_Create(_),0):- dlg_mainwindow_Create(_Win), win_Destroy(_Win), !,
%BEGIN Task Window, InitControls, 14:49:40-14.5.2018, Code automatically updated!
%END Task Window, InitControls
%BEGIN Task Window, ToolbarCreate, 14:49:40-14.5.2018, Code automatically updated!
	tb_project_toolbar_Create(_Win),
	tb_help_line_Create(_Win),
%END Task Window, ToolbarCreate
ifdef use_message
	msg_Create(100),
enddef
	!.
%END Task Window, e_Create

%MARK Task Window, new events

%BEGIN Task Window, id_help_contents
  task_win_eh(_Win,e_Menu(id_help_contents,_ShiftCtlAlt),0):-!,
  	vpi_ShowHelp("course.hlp"),
	!.
%END Task Window, id_help_contents

%BEGIN Task Window, id_help_about
  task_win_eh(Win,e_Menu(id_help_about,_ShiftCtlAlt),0):-!,
	dlg_about_dialog_Create(Win),
	!.
%END Task Window, id_help_about

%BEGIN Task Window, id_file_exit
  task_win_eh(Win,e_Menu(id_file_exit,_ShiftCtlAlt),0):-!,
  	win_Destroy(Win),
	!.
%END Task Window, id_file_exit

%BEGIN Task Window, e_Size
  task_win_eh(_Win,e_Size(_Width,_Height),0):-!,
ifdef use_tbar
	toolbar_Resize(_Win),
enddef
ifdef use_message
	msg_Resize(_Win),
enddef
	!.
%END Task Window, e_Size

%END_WIN Task Window

/***************************************************************************
		Invoking on-line Help
***************************************************************************/

  project_ShowHelpContext(HelpTopic):-
  	vpi_ShowHelpContext("course.hlp",HelpTopic).

/***************************************************************************
			Main Goal
***************************************************************************/

goal

ifdef use_mdi
  vpi_SetAttrVal(attr_win_mdi,b_true),
enddef
ifdef ws_win
  ifdef use_3dctrl
    vpi_SetAttrVal(attr_win_3dcontrols,b_true),
  enddef
enddef  
  vpi_Init(task_win_Flags,task_win_eh,task_win_Menu,"course",task_win_Title).

%BEGIN_TLB Project toolbar, 12:11:46-13.5.2018, Code automatically updated!
/**************************************************************************
	Creation of toolbar: Project toolbar
**************************************************************************/

clauses

  tb_project_toolbar_Create(_Parent):-
ifdef use_tbar
	toolbar_create(tb_top,0xC0C0C0,_Parent,
		[tb_ctrl(id_file_new,pushb,idb_new_up,idb_new_dn,idb_new_up,"New;New file",1,1),
		 tb_ctrl(id_file_open,pushb,idb_open_up,idb_open_dn,idb_open_up,"Open;Open file",1,1),
		 tb_ctrl(id_file_save,pushb,idb_save_up,idb_save_dn,idb_save_up,"Save;File save",1,1),
		 separator,
		 tb_ctrl(id_edit_undo,pushb,idb_undo_up,idb_undo_dn,idb_undo_up,"Undo;Undo",1,1),
		 tb_ctrl(id_edit_redo,pushb,idb_redo_up,idb_redo_dn,idb_redo_up,"Redo;Redo",1,1),
		 separator,
		 tb_ctrl(id_edit_cut,pushb,idb_cut_up,idb_cut_dn,idb_cut_up,"Cut;Cut to clipboard",1,1),
		 tb_ctrl(id_edit_copy,pushb,idb_copy_up,idb_copy_dn,idb_copy_up,"Copy;Copy to clipboard",1,1),
		 tb_ctrl(id_edit_paste,pushb,idb_paste_up,idb_paste_dn,idb_paste_up,"Paste;Paste from clipboard",1,1),
		 separator,
		 separator,
		 tb_ctrl(id_help_contents,pushb,idb_help_up,idb_help_down,idb_help_up,"Help;Help",1,1)]),
enddef
	true.
%END_TLB Project toolbar

%BEGIN_TLB Help line, 12:11:46-13.5.2018, Code automatically updated!
/**************************************************************************
	Creation of toolbar: Help line
**************************************************************************/

clauses

  tb_help_line_Create(_Parent):-
ifdef use_tbar
	toolbar_create(tb_bottom,0xC0C0C0,_Parent,
		[tb_text(idt_help_line,tb_context,452,0,4,10,0x0,"")]),
enddef
	true.
%END_TLB Help line

%BEGIN_DLG About dialog
/**************************************************************************
	Creation and event handling for dialog: About dialog
**************************************************************************/

constants

%BEGIN About dialog, CreateParms, 11:23:30-5.6.2018, Code automatically updated!
  dlg_about_dialog_ResID = idd_dlg_about
  dlg_about_dialog_DlgType = wd_Modal
  dlg_about_dialog_Help = idh_contents
%END About dialog, CreateParms

predicates

  dlg_about_dialog_eh : EHANDLER

clauses

  dlg_about_dialog_Create(Parent):-
	win_CreateResDialog(Parent,dlg_about_dialog_DlgType,dlg_about_dialog_ResID,dlg_about_dialog_eh,0).

%BEGIN About dialog, idc_ok _CtlInfo
  dlg_about_dialog_eh(_Win,e_Control(idc_ok,_CtrlType,_CtrlWin,_CtrlInfo),0):-!,
	win_Destroy(_Win),
	!.
%END About dialog, idc_ok _CtlInfo
%MARK About dialog, new events

  dlg_about_dialog_eh(_,_,_):-!,fail.

%END_DLG About dialog

%BEGIN_DLG mainwindow
/**************************************************************************
	Creation and event handling for dialog: mainwindow
**************************************************************************/

constants

%BEGIN mainwindow, CreateParms, 20:46:15-13.5.2018, Code automatically updated!
  dlg_mainwindow_ResID = idd_mainwindow
  dlg_mainwindow_DlgType = wd_Modal
  dlg_mainwindow_Help = idh_contents
%END mainwindow, CreateParms

predicates

  dlg_mainwindow_eh : EHANDLER
  dlg_mainwindow_handle_answer(INTEGER EndButton,DIALOG_VAL_LIST)
  dlg_mainwindow_update(DIALOG_VAL_LIST)

clauses

  dlg_mainwindow_Create(Parent):-

%MARK mainwindow, new variables

	dialog_CreateModal(Parent,dlg_mainwindow_ResID,"",
  		[
%BEGIN mainwindow, ControlList, 20:46:15-13.5.2018, Code automatically updated!
		df(idc_listbox,listbox([],[0]),nopr)
%END mainwindow, ControlList
		],
		dlg_mainwindow_eh,0,VALLIST,ANSWER),
	dlg_mainwindow_handle_answer(ANSWER,VALLIST).

  dlg_mainwindow_handle_answer(idc_ok,VALLIST):-!,
	dlg_mainwindow_update(VALLIST).
  dlg_mainwindow_handle_answer(idc_cancel,_):-!.  % Handle Esc and Cancel here
  dlg_mainwindow_handle_answer(_,_):-
	errorexit().

  dlg_mainwindow_update(_VALLIST):-
%BEGIN mainwindow, Update controls, 20:46:15-13.5.2018, Code automatically updated!
	dialog_VLGetListBox(idc_listbox,_VALLIST,_IDC_LISTBOX_ITEMLIST,_IDC_LISTBOX_SELECT),
%END mainwindow, Update controls
	true.

%MARK mainwindow, new events

%======================================================================================================================%
% Действия при создании главного окна
  dlg_mainwindow_eh(_Win,e_Create(_CreationData),0):-
  	assert(boardsize(5)),	% Размер поля
  	assert(winlength(5)),	% Победная длина
  	assert(pmm(3)),		% Глубина рекурсии "Минимакса"
  	assert(pchip("X")),
  	assert(cchip("O")),
  	initialization,
  	!.
%======================================================================================================================%
% Действия при обновлении главного окна
  dlg_mainwindow_eh(_Win,e_Update(_UpdateRct),0):-
  	drawField(_Win, 0), 
	!.
%======================================================================================================================%
% Действия при нажатии на кнопку "Помощь"
  dlg_mainwindow_eh(_Win,e_Control(idc_help,_CtrlType,_CtrlWin,_CtlInfo),0):-
  	dlg_about_dialog_Create(_Win),
	!.
%======================================================================================================================%
% Действия при нажатии на левую кнопку мыши
  dlg_mainwindow_eh(_Win,e_MouseDown(pnt(XCoord, YCoord),_ShiftCtlAlt,_Button),0):-
  	checkfree,
  	cchip(_ComputerChip), continue(_ComputerChip),
  	pchip(_HumanChip), continue(_HumanChip),
  	XCoord > left_offset, YCoord > top_offset,
  	X = (XCoord - left_offset) div ceil_size, 	% перевод оконных координат мыши
	Y = (YCoord - top_offset) div ceil_size,	% в логические номера клетки
  	valid(X), valid(Y), % Проверка координат
  	del(X, Y, "_"),
  	set(X, Y, _HumanChip),
  	drawField(_Win, 0), drawLast(_Win, X, Y, _HumanChip),
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	str_int(_sX, X), str_int(_sY, Y),
  	format(_sTEMP, "Человек        % - %", _sY, _sX),
  	lbox_Add(_hListBox, -1, _sTEMP),
  	continue(_HumanChip), !,
  	_hText = win_GetCtlHandle(_Win, idc_text),
  	win_SetText(_hText, "Ход компьютера..."),
  	turn(_Win),
	!;
	pchip(_HumanChip), not(continue(_HumanChip)), dlg_Note("Конец игры", "Человек победил!"),
	_hText = win_GetCtlHandle(_Win, idc_text), win_SetText(_hText, "Человек победил!"), !;
	cchip(_ComputerChip), not(continue(_ComputerChip)), dlg_Note("Конец игры", "Компьютер победил!"),
	_hText = win_GetCtlHandle(_Win, idc_text), win_SetText(_hText, "Компьютер победил!"), !;
	boardsize(_), not(checkfree), dlg_Note("Конец игры", "Ничья!"),
	_hText = win_GetCtlHandle(_Win, idc_text), win_SetText(_hText, "Ничья!"), !;
	!.
%======================================================================================================================%
% Действия при нажатии на кнопку "Новая игра"
  dlg_mainwindow_eh(_Win,e_Control(idc_newgame,_CtrlType,_CtrlWin,_CtlInfo),0):-
  	destruction, 
  	initialization,
  	drawField(_Win, 0), 
  	_hListBox = win_GetCtlHandle(_Win, idc_listbox),
  	lbox_Clear(_hListBox),
  	!.
%======================================================================================================================%
dlg_mainwindow_eh(_,_,_):-!,fail.