function maps_gui

AdjacencyStr = load('AdjacencyListStrE5.mat');
AdjacencyStr = AdjacencyStr.AdjacencyListStrE5;
AdjacencyInv = load('AdjacencyListInvE5.mat');
AdjacencyInv = AdjacencyInv.AdjacencyListInvE5;
Distance = load('NonEuclid3.mat');
Distance = Distance.NonEuclid2;
Map = load('Map.mat');
Map = Map.Map;
BiG = load('BiG.mat');
BiG = BiG.BiG;
%--------------------------------------------------------------------------
hMainFigure = figure(...
    'Visible', 'off',... 
    'MenuBar', 'none',...    
    'Toolbar', 'figure', ...
    'HandleVisibility', 'callback',...
    'Name', 'Карты',...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'),...
    'Tag', 'win',...
    'CloseRequestFcn', @ExitMenuitemCallback);

hAxes = axes(...
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback', ...
    'Position', [0.0 0.12 0.85 0.85],...
    'Visible', 'on',...
    'Tag', 'FigureAxes');

hTipPanel = uipanel(... % Подсказка
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback',...
    'Title', ' Подсказка ',...
    'Position', [0.02 0.02 0.71 0.08],...
    'Tag', 'TipPanel');

hTipText = uicontrol(...
    'Parent', hTipPanel,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback', ...
    'Style', 'text',...
    'Position', [0.02 0.02 0.96 0.96],...
    'HorizontalAlignment', 'left',...
    'Tag', 'TipText');

string = {'Наведитесь на интересующую зону и нажмите кнопку "Начало" в том месте, откуда хотите поехать'};
set(hTipText, 'String', textwrap(hTipText,string));

uicontrol(...
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback',...
    'Style', 'pushbutton',...
    'Position', [0.75 0.02 0.23 0.035],...
    'String', ' Выход из программы ',...
    'HorizontalAlignment', 'center',...
    'Visible', 'on',...
    'Callback', @ExitMenuitemCallback,...
    'Tag', 'ExitButton');

uicontrol(...
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback',...
    'Style', 'pushbutton',...
    'Position', [0.75 0.920 0.23 0.035],...
    'String', '  Начало  ',...
    'HorizontalAlignment', 'center',... 
    'Callback', @ChooseStartitemCallback,...
    'Tag', 'StartButton');

uicontrol(...
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback',...
    'Style', 'pushbutton',...
    'Position', [0.75 0.870 0.23 0.035],...
    'String', '  Конец  ',...
    'HorizontalAlignment', 'center',... 
    'Callback', @ChooseFinalitemCallback,...
    'Tag', 'CloseButton');

uicontrol(...
    'Parent', hMainFigure,...
    'Units', 'normalized',...
    'HandleVisibility', 'callback',...
    'Style', 'pushbutton',...
    'Position', [0.75 0.820 0.23 0.035],...
    'String', '  Рассчитать  ',...
    'HorizontalAlignment', 'center',... 
    'Callback', @CalculateitemCallback,...
    'Tag', 'CalculateButton');

hFileMenu = uimenu(...
    'Parent',hMainFigure,...
    'HandleVisibility','callback',...
    'Label','Файл',...
    'Tag', 'FileMenu');

uimenu(...
    'Parent', hFileMenu,...
    'Label', 'Выход',...
    'Separator', 'on',...
    'HandleVisibility', 'callback',...
    'Callback', @ExitMenuitemCallback,...
    'Tag', 'CloseMenuitem');
%--------------------------------------------------------------------------
movegui(hMainFigure, 'center');
set(hMainFigure, 'Visible', 'on');
handles = guihandles(hMainFigure);
set(handles.CalculateButton, 'Enable', 'off');
handles.start = [];
handles.final = [];
guidata(hMainFigure, handles);
imshow(BiG, 'InitialMagnification', 'fit', 'Parent', handles.FigureAxes);
hAxes.YLim = hAxes.XLim;
hold(hAxes);
%--------------------------------------------------------------------------
function ChooseStartitemCallback(hObject, ~)
    handles = guidata(hObject);
    if isempty(handles.final)
        hold(hAxes, 'off');
        XLim = hAxes.XLim;
        YLim = hAxes.YLim;
        imshow(BiG, 'InitialMagnification', 'fit', 'Parent', handles.FigureAxes);
        hAxes.YLim = YLim;
        hAxes.XLim = XLim;
        hold(hAxes);
    end
    WrongPoint = true;
    string = {'Кликните на начало маршрута'};
    set(hTipText, 'String', textwrap(hTipText, string));
    while WrongPoint
        [x, y] = click;
        start = [x y];
        start = SphericalSearch(Map, start);
        WrongPoint = wrongPoint(start, AdjacencyStr);
    end
    handles.start = start;
    string = {'Начало положено. Теперь так же выберите конец'};
    set(hTipText, 'String', textwrap(hTipText, string));
    plot(x, y, 'go', 'MarkerFaceColor', [0 1 0], 'MarkerSize', 6);
    if ~isempty(handles.final)
        set(handles.CalculateButton, 'Enable', 'on');
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function ChooseFinalitemCallback(hObject, ~)
    handles = guidata(hObject);
    if isempty(handles.start)
        hold(hAxes, 'off');
        XLim = hAxes.XLim;
        YLim = hAxes.YLim;
        imshow(BiG, 'InitialMagnification', 'fit', 'Parent', handles.FigureAxes);
        hAxes.YLim = YLim;
        hAxes.XLim = XLim;
        hold(hAxes);
    end
    WrongPoint = true;
    string = {'Кликните на конец маршрута'};
    set(hTipText, 'String', textwrap(hTipText,string));
    while WrongPoint
        [x, y] = click;
        final = [x y];
        final = SphericalSearch(Map, final);
        WrongPoint = wrongPoint(final, AdjacencyInv);
    end
    handles.final = final;
    if ~isempty(handles.start)
        string = {'Теперь можно рассчитывать маршрут'};
        set(hTipText, 'String', textwrap(hTipText, string));
    else
        string = {'Нажмите "начало", чтобы выбрать исходную точку'};
        set(hTipText, 'String', textwrap(hTipText, string));
    end
    plot(x, y, 'ro', 'MarkerFaceColor', [1 0 0], 'MarkerSize', 6);
    if ~isempty(handles.start)
        set(handles.CalculateButton, 'Enable', 'on');
    end
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function CalculateitemCallback(hObject, ~)
    handles = guidata(hObject);
    CalculateRoute(Map, Distance, handles.start, handles.final, AdjacencyStr, AdjacencyInv);
    string = {'Готово'};
    set(hTipText, 'String', textwrap(hTipText, string));
    set(handles.CalculateButton, 'Enable', 'off');
    handles.start = [];
    handles.final = [];
    guidata(hObject, handles);
end
%--------------------------------------------------------------------------
function ExitMenuitemCallback(~, ~)        
    selection = questdlg(['Выйти из программы ' get(hMainFigure,'Name') '?'],...
        'Выход', 'Да', 'Нет', 'Да');
    if strcmp(selection, 'Нет')
        return;
    end
    delete(hMainFigure);
end
%--------------------------------------------------------------------------
end
%==========================================================================
function CalculateRoute(Map, Distances, start, final, AdjacencyStr, AdjacencyInv)
%Берёт на себя все обязанности по созданию маршрута
%   Запись:     CalculateRoute(Map,Adjacency,Distances,start,final)
number = Dijkstra(AdjacencyStr, Distances, start, final);
Route = drive(AdjacencyInv, Distances, number, start, final);
drawRoute(Map, Route);
end
%==========================================================================
function [number] = Dijkstra(Adjacency, Distances, start, final)
%Функция расчета удаленностей от стартовой точки
%   Запись: [number] = Dijkstra(Adjacency,Distances,start,final)
tic
[n, p] = size(Adjacency);
[n1, p1] = size(Distances);
if n1 ~= n || p1 ~= p
    error('Adjacency and distance matrices must be the same size');
end
for i = 1:n
    for j = 1:p
        if Distances(i, j) < 0
            error('Distances cannot be negative');
        end
    end
end
Terminal = start;
number = int16(inf([1 n]));
number(start) = 0;
%--------------------------------------------------------------------------
%Расчёт удалённостей
%--------------------------------------------------------------------------
while ~isempty(Terminal)
    
    [~, index] = sort(number(Terminal));
    k = 0;
    if length(Terminal) > 49
        len = 2 * length(Terminal) + 2;
    else
        len = 3 * length(Terminal) + 2;
    end
    PreTerminal = zeros([1 len]);
    for i = index
        x = Terminal(i);
        for j = 1:p
            if Adjacency(x, j) ~= 0 && number(x) + Distances(x, j) < number(Adjacency(x, j))
                number(Adjacency(x, j)) = number(x) + Distances(x, j);
                if ~ismember(Adjacency(x, j), PreTerminal) && number(Adjacency(x, j)) < number(final)
                    k = k + 1;
                    PreTerminal(k) = Adjacency(x, j);
                end
            end
        end
    end
    fin = find(PreTerminal < 1);
    fin = fin(1);
    PreTerminal(fin:end) = [];
    Terminal = PreTerminal;
end
toc
end
%==========================================================================
function drawRoute(Map, Route)
%Рисует маршрут на уже имеющемся изображении
%   Запись:     drawRoute(Map,Route)
[~, three] = size(Map);
if three ~= 3
    error('Map must be a matrix of nx3 size');
end
[n, ~] = size(Route);
if n ~= 1
    error('Route isnt vector');
end
for i = 2:length(Route)
    line([Map(Route(i), 2) Map(Route(i - 1), 2)],[Map(Route(i), 3) Map(Route(i - 1), 3)], 'Color', 'r', 'linewidth', 2);
end
end
%==========================================================================
function [Route] = drive(Adjacency, Distances, number, start, final)
%Определяет маршрут, исходя из удалённостей
%   Запись:     [RouteMatrix] = drive(Adjacency,Distances,number,start,final)
[n, p] = size(Adjacency);
[n1, p1] = size(Distances);
if n1 ~= n || p1 ~= p
    error('Adjacency and distance matrices must be the same size');
end
for i = 1:n
    for j = 1:p
        if Distances(i, j) < 0
            error('Distances cannot be negative');
        end
    end
end
Terminal = final;
Route = final;
while Terminal ~= start
    check = 0;
    for i = 1:p
        if Adjacency(Terminal, i) ~= 0
            if number(Adjacency(Terminal, i)) == number(Terminal) - Distances(Terminal, i) && check == 0
                Route = [Adjacency(Terminal, i) Route]; %#ok<AGROW>
                check = 1;   % пускай работает до первого совпадения
            end
        end
    end
    Terminal = Route(1);
end
Route = [start Route];
end
%==========================================================================
function [medianPoint] = SphericalSearch(Map,point)
%Сферический поиск точки на плоскости, ближайшей к заданной
%   Запись: [nodePoint] = SphericalSearch(Map,point)
[n, R] = size(Map);
if R ~= 3
    error('Map size must be nx3');
end
for i = 2:n
    if Map(i, 3) < Map(i - 1, 3)
        error('Map must be y-growing');
    end
end
%--------------------------------------------------------------------------
% Двоичный поиск
%--------------------------------------------------------------------------
left = 1;
right = n;
while right - left > 1
    middle = fix((right + left) / 2);
    if point(2) > Map(middle, 3)
        left = middle;
    else
        right = middle;
    end
end
medianPoint = middle;
%--------------------------------------------------------------------------
% Поиск минимума влево
%--------------------------------------------------------------------------
i = 0;
min = inf;
while middle - i > 0 && min > abs(Map(middle - i, 3) - point(2))
    distance = ((Map(middle - i, 3) - point(2))^2+(Map(middle - i, 2) - point(1))^2)^0.5;
        if distance < min
            min = distance;
            medianPoint = middle - i;
        end
    i = i + 1;
end
%--------------------------------------------------------------------------
% Поиск минимума вправо
%--------------------------------------------------------------------------
i = 0;
min1 = inf;
while middle + i < n + 1 && min1 > abs(Map(middle + i, 3) - point(2))
    distance = ((Map(middle + i, 3) - point(2))^2 + (Map(middle + i, 2) - point(1))^2)^0.5;
        if distance < min1
            min1 = distance;
            medianPoint1 = middle + i;
        end
    i = i + 1;
end
%--------------------------------------------------------------------------
if min1 < min
    medianPoint = medianPoint1;
end
end
%==========================================================================
function [x, y] = click()
% Приостанавливает ход программы, чтобы возвратить координаты кликнутой тчк
%   Запись: [x,y]=click()

waitforbuttonpress;
point = get(gca, 'CurrentPoint');
point(2, :) = [];
point(3) = [];
point(2) = point(2);
x=point(1);
y=point(2);
end
%==========================================================================
function boolean = wrongPoint(index, AdjacencyList)
if sum(AdjacencyList(index, :)) == 0
    boolean = true;
else
    boolean = false;
end
end