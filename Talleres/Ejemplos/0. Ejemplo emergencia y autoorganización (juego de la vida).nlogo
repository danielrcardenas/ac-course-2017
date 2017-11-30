; Declaración de 2 nuevas propiedades a los patches
patches-own [
  vive?
  vecinos-vivos
]

globals[ban tam]

to setup
  set ban 100
  if patrones = "Vacio" [setup-vacio]
  if patrones = "Aleatorio" [setup-aleatorio]
  if patrones = "Patrones estáticos" [setup-estaticos]
  if patrones = "Patrones periódicos" [setup-periodicos]
  if patrones = "Planeador" [setup-planeador]
  if patrones = "Nave espacial ligera" [setup-nave]
  if patrones = "Araña" [setup-araña]
  if patrones = "Rana" [setup-rana]
  if patrones = "Pistola de Gosper" [setup-pistola]
end

; Procedimiento para preparar la simulación sin células vivas iniciales
to setup-vacio
  ca
  resize-world 0 120 -60 0
  set-patch-size 6.5
  set tam patch-size
  ask patches [morir-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con células vivas repartidas aleatoriamente
to setup-aleatorio
  ca
  resize-world 0 180 -90 0
  set-patch-size 4.3
  set tam patch-size
  ask patches
    [ifelse random-float 100.0 < densidad-inicial
      [nacer-celula]
      [morir-celula]]
  reset-ticks
end


; Procedimiento para preparar la simulación con los patrones estáticos
to setup-estaticos
  ca
  resize-world 0 39 -12 0
  set-patch-size 20
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points
  [
    [3 -2][2 -3][4 -3][3 -4]
    [3 -7][4 -7][5 -8][5 -9][4 -10][3 -10][2 -9][2 -8]
    [7 -3][8 -2][9 -2][10 -3][9 -4][8 -4][7 -3]
    [8 -8][8 -9][9 -7][9 -10][10 -8][10 -10][11 -9]
    [13 -4][13 -3][14 -4][14 -2][15 -3][15 -2]
    [14 -7][14 -8][15 -8][16 -8][16 -10][17 -9][17 -10]
    [18 -2][18 -3][19 -2][19 -4][20 -3]
    [20 -7][20 -8][21 -6][21 -9][22 -6][22 -7][22 -9][23 -7][23 -9][23 -10][24 -7][24 -10][25 -8][25 -9]
    [23 -2][23 -3][24 -2][25 -3][26 -2][26 -3]
    [27 -6][28 -5][28 -7][29 -5][29 -7][30 -3][30 -4][30 -8][30 -9][31 -2][31 -10][32 -3][32 -4][32 -8][32 -9][33 -5][33 -7][34 -5][34 -7][35 -6]
    [36 -2][37 -2][36 -3][37 -3]
  ]
  [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con los patrones periódicos
to setup-periodicos
  ca
  resize-world 0 79 -43 0
  set-patch-size 7
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points
  [
    [11 -7][11 -8][12 -7][12 -8][7 -11][8 -11][7 -12][8 -12][13 -17][14 -17][13 -18][14 -18][17 -11][18 -11][17 -12][18 -12]
    [10 -11][10 -12][10 -13][10 -14][11 -10][12 -10][13 -10][14 -10][11 -15][12 -15][13 -15][14 -15][15 -11][15 -12][15 -13][15 -14]
    [11 -13][12 -12][13 -12]
    [27 -15][27 -16][28 -16][29 -16][30 -17][31 -18][30 -19][29 -19][29 -18][29 -21][29 -22][30 -21][30 -24][31 -23][31 -24]
    [29 -10][29 -11][30 -11][31 -9][32 -9][32 -10][34 -9][34 -10][35 -9][35 -11][36 -10][37 -9][37 -8][37 -7][38 -7]
    [42 -9][42 -10][43 -9][43 -12][44 -12][44 -11][43 -14][44 -14][44 -15][42 -15][43 -16][44 -17][45 -17][46 -17][46 -18]
    [36 -24][36 -25][36 -26][35 -26][37 -23][38 -22][38 -24][39 -23][39 -24][41 -23][41 -24][42 -24][43 -22][44 -22][44 -23]
    [38 -15][37 -16][38 -16][39 -16][37 -17][39 -17]
    [10 -32][11 -32][12 -31][12 -33][13 -32][14 -32][15 -32][16 -32][17 -31][17 -33][18 -32][19 -32]
    [56 -34][57 -34][58 -34][57 -33][58 -33][59 -33]
    [65 -33][66 -33][67 -33]
    [55 -12][56 -12][57 -12][57 -13][57 -17][57 -18][56 -18][55 -18][59 -8][59 -9][59 -10][60 -10][64 -10][65 -10][65 -9][65 -8][67 -12][67 -13][67 -17][67 -18][68 -12][69 -12][68 -18][69 -18][59 -20][59 -21][59 -22][60 -20][64 -20][65 -20][65 -21][65 -22]
    [59 -13][59 -14][60 -12][60 -14][61 -12][61 -13][59 -16][59 -17][60 -16][60 -18][61 -17][61 -18][63 -12][63 -13][64 -12][64 -14][65 -13][65 -14][63 -17][63 -18][64 -16][64 -18][65 -16][65 -17]
  ]
  [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con el patrón Planeador
to setup-planeador
  ca
  resize-world 0 60 -30 0
  set-patch-size 13
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points [[2 -3][3 -4][4 -2][4 -3][4 -4]] [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con el patron Nave espacial ligera
to setup-nave
  ca
  resize-world 0 60 -29 0
  set-patch-size 13
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points [[2 -13][2 -15][3 -16][4 -16][5 -16][5 -13][6 -14][6 -15][6 -16]] [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con el patrón Araña
to setup-araña
  ca
  resize-world -22 52 -60 20
  set-patch-size 4
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points
  [
    [2 -54][2 -53][3 -53][4 -53][3 -56][3 -57][4 -56][4 -57][5 -52][6 -52][6 -53][6 -54][6 -55][7 -55][6 -57][7 -57][7 -58][8 -52][8 -53][8 -54][9 -53][10 -52][10 -53][11 -51][12 -52][13 -52]
    [14 -54][14 -55][14 -56][16 -54][16 -55][16 -56]
    [17 -52][18 -52][19 -51][20 -52][20 -53][21 -53][22 -52][22 -53][22 -54][23 -55][24 -55][24 -54][24 -53][24 -52][25 -52][23 -57][23 -58][24 -57][26 -53][27 -53][28 -53][28 -54][26 -57][26 -56][27 -56][27 -57]
  ]
  [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con el patrón Rana
to setup-rana
  ca
  resize-world -23 36 -50 20
  set-patch-size 5
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points
  [
    [2 -48][3 -48][3 -47][4 -47][5 -47][6 -47][7 -47][8 -47][9 -47][10 -47][10 -48][11 -48]
    [3 -45][3 -44][10 -44][10 -45]
    [3 -42][4 -42][4 -41][4 -40][5 -41][5 -43][6 -42][7 -42][8 -41][8 -43][9 -40][9 -41][9 -42][10 -42]
    [2 -40][2 -39][2 -38][3 -38][3 -39][5 -38][6 -37][7 -37][8 -38][10 -38][10 -39][11 -38][11 -39][11 -40]
  ]
  [nacer-celula]
  reset-ticks
end


; Procedimiento para preparar la simulación con el patrón pistola de Gosper
to setup-pistola
  ca
  resize-world 0 52 -40 0
  set-patch-size 10
  set tam patch-size
  ask patches [morir-celula]
  ask patches at-points
  [
    [2 -8][2 -9][3 -8][3 -9]
    [12 -8][12 -9][12 -10][13 -7][13 -11][14 -6][14 -12][15 -6][15 -12][16 -9][17 -7][17 -11][18 -8][18 -9][18 -10][19 -9]
    [22 -8][22 -7][22 -6][23 -8][23 -7][23 -6][24 -5][24 -9][26 -5][26 -4][26 -9][26 -10]
    [36 -7][36 -6][37 -7][37 -6]
  ]
  [nacer-celula]
  reset-ticks
end


; Procedimiento para crear una célula viva
to nacer-celula
  set vive? true
  set pcolor black
end


; Procedimiento para eliminar una célula viva
to morir-celula
  set vive? false
  set pcolor white
end


; Procedimiento para iniciar la simulación
to go
  if ban != porcentaje-zoom
  [
    if zoom
    [
      set-patch-size (porcentaje-zoom / 100 * tam)
    set ban (porcentaje-zoom)
    ]
  ]
  if (patrones = "Pistola de Gosper") and ticks mod 30 = 0 [ask patches at-points [[52 -40][52 -39][51 -40][51 -39]][nacer-celula]]
  ask patches [set vecinos-vivos count neighbors with [vive?]]
  ask patches
  [
    ifelse vecinos-vivos = 3
    [nacer-celula]
    [
      if vecinos-vivos != 2 [morir-celula]
    ]
  ]
  tick
end


; Procedimiento para dibujar con el puntero del mouse células vivas
to dibujar-celulas
  let borrar? [vive?] of patch mouse-xcor mouse-ycor
  while [mouse-down?]
  [ 
    ask patch mouse-xcor mouse-ycor
    [
      ifelse borrar?
      [ morir-celula]
      [nacer-celula]
    ]
    display
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
404
39
1184
457
-1
-1
4.3
1
10
1
1
1
0
1
1
1
0
180
-90
0
1
1
1
ticks
15.0

SLIDER
37
117
185
150
densidad-inicial
densidad-inicial
0.0
100.0
50
0.1
1
%
HORIZONTAL

BUTTON
220
365
368
398
Go Tick
go
NIL
1
T
OBSERVER
NIL
T
NIL
NIL
1

BUTTON
38
364
186
397
Go continuo
go
T
1
T
OBSERVER
NIL
C
NIL
NIL
1

TEXTBOX
199
253
359
328
          | Mientas este abajo el \n_____| botón, podrá dibujar con\n          | el puntero del mouse\n          | células vivas presionando\n          | el click principal
11
0.0
0

BUTTON
38
260
186
295
Dibujar células
dibujar-celulas
T
1
T
OBSERVER
NIL
D
NIL
NIL
1

CHOOSER
37
72
185
117
patrones
patrones
"Vacio" "Aleatorio" "Patrones estáticos" "Patrones periódicos" "Planeador" "Nave espacial ligera" "Araña" "Rana" "Pistola de Gosper"
1

BUTTON
37
182
185
215
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

TEXTBOX
192
127
375
155
   -------| Solo para patrón \"Aleatorio\"
11
0.0
1

SWITCH
38
430
149
463
zoom
zoom
0
1
-1000

SLIDER
186
430
368
463
porcentaje-zoom
porcentaje-zoom
25
300
100
5
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This program is an example of a two-dimensional cellular automaton.  This particular cellular automaton is called The Game of Life.

A cellular automaton is a computational machine that performs actions based on certain rules.  It can be thought of as a board which is divided into cells (such as square cells of a checkerboard).  Each cell can be either "alive" or "dead."  This is called the "state" of the cell.  According to specified rules, each cell will be alive or dead at the next time step.

## HOW IT WORKS

The rules of the game are as follows.  Each cell checks the state of itself and its eight surrounding neighbors and then sets itself to either alive or dead.  If there are less than two alive neighbors, then the cell dies.  If there are more than three alive neighbors, the cell dies.  If there are 2 alive neighbors, the cell remains in the state it is in.  If there are exactly three alive neighbors, the cell becomes alive. This is done in parallel and continues forever.

There are certain recurring shapes in Life, for example, the "glider" and the "blinker". The glider is composed of 5 cells which form a small arrow-headed shape, like this:

       O
        O
      OOO

This glider will wiggle across the world, retaining its shape.  A blinker is a block of three cells (either up and down or left and right) that rotates between horizontal and vertical orientations.

## HOW TO USE IT

The INITIAL-DENSITY slider determines the initial density of cells that are alive.  SETUP-RANDOM places these cells.  GO-FOREVER runs the rule forever.  GO-ONCE runs the rule once.

If you want to draw your own pattern, use the DRAW-CELLS button and then use the mouse to "draw" and "erase" in the view.

## THINGS TO NOTICE

Find some objects that are alive, but motionless.

Is there a "critical density" - one at which all change and motion stops/eternal motion begins?

## THINGS TO TRY

Are there any recurring shapes other than gliders and blinkers?

Build some objects that don't die (using DRAW-CELLS)

How much life can the board hold and still remain motionless and unchanging? (use DRAW-CELLS)

The glider gun is a large conglomeration of cells that repeatedly spits out gliders.  Find a "glider gun" (very, very difficult!).

## EXTENDING THE MODEL

Give some different rules to life and see what happens.

Experiment with using neighbors4 instead of neighbors (see below).

## NETLOGO FEATURES

The neighbors primitive returns the agentset of the patches to the north, south, east, west, northeast, northwest, southeast, and southwest.  So `count neighbors with [living?]` counts how many of those eight patches have the `living?` patch variable set to true.

`neighbors4` is like `neighbors` but only uses the patches to the north, south, east, and west.  Some cellular automata, like this one, are defined using the 8-neighbors rule, others the 4-neighbors.

## RELATED MODELS

Life Turtle-Based --- same as this, but implemented using turtles instead of patches, for a more attractive display  
CA 1D Elementary --- a model that shows all 256 possible simple 1D cellular automata  
CA 1D Totalistic --- a model that shows all 2,187 possible 1D 3-color totalistic cellular automata  
CA 1D Rule 30 --- the basic rule 30 model  
CA 1D Rule 30 Turtle --- the basic rule 30 model implemented using turtles  
CA 1D Rule 90 --- the basic rule 90 model  
CA 1D Rule 110 --- the basic rule 110 model  
CA 1D Rule 250 --- the basic rule 250 model

## CREDITS AND REFERENCES

The Game of Life was invented by John Horton Conway.

See also:

Von Neumann, J. and Burks, A. W., Eds, 1966. Theory of Self-Reproducing Automata. University of Illinois Press, Champaign, IL.

"LifeLine: A Quarterly Newsletter for Enthusiasts of John Conway's Game of Life", nos. 1-11, 1971-1973.

Martin Gardner, "Mathematical Games: The fantastic combinations of John Conway's new solitaire game `life',", Scientific American, October, 1970, pp. 120-123.

Martin Gardner, "Mathematical Games: On cellular automata, self-reproduction, the Garden of Eden, and the game `life',", Scientific American, February, 1971, pp. 112-117.

Berlekamp, Conway, and Guy, Winning Ways for your Mathematical Plays, Academic Press: New York, 1982.

William Poundstone, The Recursive Universe, William Morrow: New York, 1985.


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (1998).  NetLogo Life model.  http://ccl.northwestern.edu/netlogo/models/Life.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
setup-random repeat 20 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
