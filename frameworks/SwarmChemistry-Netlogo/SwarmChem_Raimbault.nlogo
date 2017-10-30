extensions[table]

__includes[
  "utils/FileUtilities.nls"
  "utils/StringUtilities.nls"
  "utils/SortingUtilities.nls"
]


globals [

  ;;species description
  ;;universal map
  ;;format is: (param-name (String),species-id (int)) -> param-value
  ;;map is filled at setup, and is quite flexible for use in different ways
  ;;(as from file, or random, or by crossing (?))
  ;;
  ;; In case of file:
  ;; - id of species has to be canonical (1 -> species-number)
  ;; - "proportion" param is required
  species-description

  ;;list of names of variables parameters
  param-names
  species-ids

  ;;total particle number independant from setup (proportions of species are set according to param)
  particles-number



  ;;var for reporters
  moran-populations

]


;;breeding not necessarly needed but better for flexibility of the model
;;(e. g. extensions with new effects using turtles)
breed [particles particle]


particles-own [

  ;;characteristics

    ;;not essential, but useful in case of extension
    ;;(ex species changes would need recoloration)
    species

    ;;params
    perception-radius
    normal-speed
    max-speed

  ;;forces

    ;;cohesion
    cohesive-force-strength ;; \in [0;1]
    ;;alignement
    aligning-force-strength ;; \in [0;1]
    ;;separation
    separating-force-strength ;; \in [0;100]

    steering-proba
    pace-keeping-tendancy


  ;;Runtime vars

  ;;speeds

    ;;using vectors in NL is not practical (here we take lists)
    ;;but the "natural" solution using built-in heading var and a scalar for the norm of the speed
    ;;(and the same for the acceleration) posed problems in the implementation of the variation formula
    ;;(in particular, need of reciprocal determination of the heading, quite tricky)
    ;;speeds : list [x,y]
    current-speed
    next-speed

    ;;pseudo accel (discrete derivative)
    ;;list [x,y]
    acceleration

]


;;;;;;;;;;;;;;;;;;
;;General procedures
;;;;;;;;;;;;;;;;;;



to setup
  setup-world
  setup-species-description
  setup-particles
  setup-plots-and-reporters
end

to setup-world
  ;;set world
  ca reset-ticks
  resize-world 0 worldwidth 0 worldheight
  ;;since patches don't play any role in calculation, huge number of patches is not a problem
  set-patch-size 4
  ask patches [set pcolor white]
end

to setup-species-description
  ;;init map
  set species-description table:make
  set param-names []
  set species-ids []

  if setup-mode = "predefined1" [set setup-mode "file" set input-file "data/sample1.txt"]
  if setup-mode = "predefined2" [set setup-mode "file" set input-file "data/sample2.txt"]

  ifelse setup-mode = "file" [
    ;;read config file - skip first comment line
    ;;second line is params list
    let specieses but-first read-file input-file
    set param-names explode " " first specieses set specieses but-first specieses

    set species-number 0

    foreach specieses [[?] ->
       ;;skip comment lines
       if first ? != "#" [
         let params explode " " ? let i 0
         ;;id of the species
         let id read-from-string first params
         foreach but-first params [
           table:put species-description (list id (item (i + 1) param-names)) (read-from-string ?)
           set i i + 1
         ]

         ;;global var species-number has to be set because used in the reading of the table
         ;set species-number species-number + 1

         set species-ids lput id species-ids
       ]
    ]

  ][
    ;;else do a "random" config
    if setup-mode = "random" [
      let current-species-id 1
      set param-names explode " " "id proportion cohesive-force-strength aligning-force-strength separating-force-strength steering-proba pace-keeping-tendancy perception-radius normal-speed max-speed"
      ;;equal props
      let proportion 1 / species-number * 100
      repeat species-number [
        table:put species-description (list current-species-id "id") current-species-id
        table:put species-description (list current-species-id "proportion") proportion
        table:put species-description (list current-species-id "perception-radius") max list 0 (min list (random-normal perception-radius-mean (perception-radius-mean / 2)) 300)
        table:put species-description (list current-species-id "normal-speed") 5
        table:put species-description (list current-species-id "max-speed") 20
        table:put species-description (list current-species-id "cohesive-force-strength") max list 0 (min list (random-normal cohesive-force-strength-mean (cohesive-force-strength-mean / 2)) 1)
        table:put species-description (list current-species-id "aligning-force-strength") max list 0 (min list (random-normal aligning-force-strength-mean (aligning-force-strength-mean / 2)) 1)
        table:put species-description (list current-species-id "separating-force-strength") max list 0 (min list (random-normal separating-force-strength-mean (separating-force-strength-mean / 2)) 100)
        table:put species-description (list current-species-id "steering-proba") max list 0 (min list (random-normal steering-proba-mean (steering-proba-mean / 2)) 0.5)
        table:put species-description (list current-species-id "pace-keeping-tendancy") max list 0 (min list (random-normal pace-keeping-tendancy-mean (pace-keeping-tendancy-mean / 2)) 0.5)

        set species-ids lput current-species-id species-ids
        set current-species-id current-species-id + 1
      ]


    ]
  ]
end


to setup-particles
  output-print word word "Species Description: " length species-ids " species"
  ;;read the table describing species and setup particles
  foreach species-ids [[?]->
    ;;output config for this species
    output-print word "Species " ?
    let id ? foreach but-first param-names [output-print word word word "  " ? " = " (table:get species-description (list id ?))]

    ;;create particles
    let current-particle-number round (particles-number * (table:get species-description (list ? "proportion")) / 100)
    create-particles current-particle-number [new-particle ?]
  ]

end

;;"Constructor" for breed particle;
;;particle procedure but used at setup so here.
to new-particle [species-id]
  ;;inevitably go other all params for each particle
  ;;shouldn't be costly
  ;;length param-names >= 3 (if not, no param !)
  foreach but-first but-first param-names [ [?]->
     run word word word "set " ? " " (table:get species-description (list species-id ?))
  ]

  set species species-id

  ;;random position ?
  setxy random-xcor random-ycor
  set size 4 set shape "circle"

  ;;color
  set color approximate-rgb (cohesive-force-strength * 255) (aligning-force-strength * 255) (separating-force-strength * 2.55)

  ;;need also to setup runtime params
  let dir random 360 ;;random direction for the speed
  set current-speed list (normal-speed * (cos dir)) (normal-speed * (sin dir))
  set next-speed current-speed
  set acceleration list 0 0

end


to setup-plots-and-reporters

  ;;setup moran table
  set moran-populations table:make
  clear-table-moran

  ;setup plots
  ;clustering : add one pen for each population
  set-current-plot "Species clustering"
  foreach species-ids [[?] ->
    create-temporary-plot-pen word "species-" ?
    let a one-of (particles with [species = ?])
    set-plot-pen-color [color] of a
  ]

end




to go
  ask particles [calculate-move]
  ask particles [move]
  ;plot-reporters
  tick
end


to plot-reporters
  set-current-plot "Species clustering"
  foreach species-ids [[?]-> set-current-plot-pen word "species-" ? plot spatial-autocorrelation-index ?]
end


;;export of current config into a cfg file
to export-configuration
  ;;print first comment line : date and time, etc.
  ;;Add runtime params, system ? TODO
  let commt word "# Configuration file automatically created at " date-and-time
  ;;create file in write mode - delete if exists. Must have rw rights on file.
  if file-exists? export-file-path [file-delete export-file-path]
  print-in-file export-file-path commt

  ;;write params list
  ;;beware not putting a space at the end
  let header "" foreach but-last param-names [[?]-> set header word word header ? " "] set header word header last param-names
  print-in-file export-file-path header

  ;;export values for each species
  foreach species-ids [[?] ->
    let values "" let id ?
    foreach but-last param-names [set values word word values (table:get species-description (list id ?)) " "]
    set values word values (table:get species-description (list id last param-names))
    print-in-file export-file-path values
  ]

end




;;;;;;;;;;;;;;;;;;;
;;Turtle procedures
;;;;;;;;;;;;;;;;;;;


;;turtle procedure to update
;;(core function)
to calculate-move
  ;;find neighbours
  let neighs other particles in-radius perception-radius

  ifelse count neighs = 0 [
    ;;random steering = Straying
    ;;[equivalent but simpler to randomize the norm of acceleration] NO here Y but not for the following
    set acceleration list (- 5 + random-float 10) (- 5 + random-float 10)
  ][
    ;;swarm behaviour
    let mean-xcor mean [xcor] of neighs let mean-ycor mean [ycor] of neighs
    let mean-xspeed mean [first current-speed] of neighs let mean-yspeed mean [last current-speed] of neighs
    let x-separating sum [([xcor] of myself - xcor)/(([xcor] of myself - xcor) ^ 2 +  ([ycor] of myself - ycor) ^ 2) ] of neighs
    let y-separating sum [([ycor] of myself - ycor)/(([xcor] of myself - xcor) ^ 2 +  ([ycor] of myself - ycor) ^ 2) ] of neighs
    let x-acc (cohesive-force-strength * (mean-xcor - xcor)) + (aligning-force-strength * (mean-xspeed - first current-speed )) + separating-force-strength * x-separating
    let y-acc (cohesive-force-strength * (mean-ycor - ycor)) + (aligning-force-strength * (mean-yspeed - last current-speed)) + separating-force-strength * y-separating
    set acceleration list x-acc y-acc

    ;;Whim
    if random-float 1 < steering-proba [set acceleration list (first acceleration - 5 + random-float 10) (last acceleration - 5 + random-float 10)]
  ]

  ;;update speed
  ;;discrete integration: includes real time-step value
  set next-speed list (first current-speed + (first acceleration * time-step)) (last current-speed + (last acceleration * time-step))

  ;;regulation of speed: can go other max-speed
  let regulation-factor min list 1 (max-speed / norm-2 next-speed)
  set next-speed list (regulation-factor * first next-speed) (regulation-factor * last next-speed)

  ;;pace keeping:
  ;;particles will regulate following their tendancy to flock and the normal speed (vector)
  let pc-factor normal-speed / norm-2 next-speed
  set next-speed list ((pace-keeping-tendancy * pc-factor * first next-speed) + ((1 - pace-keeping-tendancy) * first next-speed)) ((pace-keeping-tendancy * pc-factor * last next-speed) + ((1 - pace-keeping-tendancy) * last next-speed))

end

;;just move by updating speeds and positions
;;done separately from update because "decisions" are taken simultaneously
;;(would be interesting to study distance between both implementations in function of time-step, random seed, etc )
to move
  ;;update speed
  set current-speed next-speed
  ;;move
  setxy (xcor + (first current-speed * time-step)) (ycor + (last current-speed * time-step))
end



;;simplified utility for norm 2 of vectors in \mathbb{R}^{2}
to-report norm-2 [l]
  report sqrt ((first l)^ 2 + (last l) ^ 2)
end




;;;;;;;;;
;;reporters for output
;;;;;;;;;


to-report spatial-autocorrelation-index [species-id]
  ;;Moran index implementation
  ;;dirty but try to be efficient : sort particles lexically on coordinates
  ;;would be more efficient with single pass on patches for all species, but function would be totally unreadable
  clear-table-moran
  let ag sort-by [[?1 ?2]-> lexcomp ?1 ?2 (list task [floor (xcor / clustering-grid-size)] task [floor (ycor / clustering-grid-size)])] (particles with [species = species-id])
  let min-ag first ag
  let pop-count length ag
  ;;let cut the space in subregions, 50*50 should be enough precise
  ;;count are held in a table: for square x=i*step,y=j*step : (i,j) -> particles_count
  ;;table initialised with plots
  let i 0 let j 0 let xmax clustering-grid-size let ymax clustering-grid-size let ended? false
  repeat floor (world-width / clustering-grid-size) [
     repeat floor (world-height / clustering-grid-size) [
       while [not ended? and [xcor] of first ag < xmax and [ycor] of first ag < ymax] [
         ;;NOTE: cascade condition work in NL as in Java
         ;;DEBUG show implode (list "particle " ([xcor] of first ag) " - " ([ycor] of first ag) " in " i " - " j )
         table:put moran-populations (list i j) (table:get moran-populations (list i j) + 1)
         set ag but-first ag
         if length ag = 0 [set ended? true]
       ]
       set ymax ymax + clustering-grid-size
       set j j + 1
     ]
     set xmax xmax + clustering-grid-size set ymax clustering-grid-size
     set i i + 1 set j 0
  ]

  let N length table:keys moran-populations
  let d-mean pop-count / N
  let W 0 let S 0 let norm-factor 0
  foreach table:keys moran-populations [
    let site-i ? foreach table:keys moran-populations [
      let site-j ?
      if site-j != site-i [
        let weight  1 / (sqrt ((first site-i - first site-j) ^ 2 + (last site-i - last site-j) ^ 2 ))
        set W W + weight
        set S S + weight * (table:get moran-populations site-i - d-mean) * (table:get moran-populations site-j - d-mean)
      ]
    ]
    set norm-factor norm-factor + ((table:get moran-populations site-i - d-mean) ^ 2 )
  ]
  report N * S / (W * norm-factor)
end

to clear-table-moran
  let i 0 let j 0
  repeat floor (world-width / clustering-grid-size) [
     repeat floor (world-height / clustering-grid-size) [
       table:put moran-populations (list i j) 0 set j j + 1
     ] set j 0 set i i + 1
  ]

end


@#$#@#$#@
GRAPHICS-WINDOW
210
10
822
623
-1
-1
4.0
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
150
0
150
0
0
1
ticks
30.0

SLIDER
6
47
106
80
worldwidth
worldwidth
0
500
150.0
1
1
NIL
HORIZONTAL

SLIDER
106
47
207
80
worldheight
worldheight
0
500
150.0
1
1
NIL
HORIZONTAL

SLIDER
2
260
95
293
species-number
species-number
0
10
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
13
17
163
35
Setup params
11
0.0
0

TEXTBOX
1128
10
1278
28
Runtime params
11
0.0
1

BUTTON
962
13
1028
46
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
962
50
1025
83
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1124
26
1223
59
time-step
time-step
0
10
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
69
182
207
242
input-file
data/sample1.txt
1
0
String

CHOOSER
5
85
143
130
setup-mode
setup-mode
"file" "random" "predefined1" "predefined2"
0

TEXTBOX
7
176
64
194
file setup
11
0.0
1

TEXTBOX
6
243
156
261
random setup
11
0.0
1

SLIDER
7
136
179
169
agents-number
agents-number
0
300
100.0
1
1
NIL
HORIZONTAL

SLIDER
4
296
199
329
cohesive-force-strength-mean
cohesive-force-strength-mean
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
3
333
199
366
aligning-force-strength-mean
aligning-force-strength-mean
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
2
368
200
401
separating-force-strength-mean
separating-force-strength-mean
0
100
19.0
1
1
NIL
HORIZONTAL

SLIDER
3
405
187
438
steering-proba-mean
steering-proba-mean
0
0.5
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
5
441
198
474
pace-keeping-tendancy-mean
pace-keeping-tendancy-mean
0
1
0.5
0.1
1
NIL
HORIZONTAL

BUTTON
1032
12
1115
45
see one traj
clear-drawing\nask agents [pen-up]\nask one-of agents [pen-down]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
476
199
509
perception-radius-mean
perception-radius-mean
0
300
52.0
1
1
NIL
HORIZONTAL

OUTPUT
983
505
1389
699
12

TEXTBOX
12
625
162
643
Export config
11
0.0
1

INPUTBOX
8
643
110
703
export-file-path
data/sample2.txt
1
0
String

BUTTON
115
655
188
688
export
export-configuration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
978
308
1381
493
Species clustering
time
clustering
0.0
10.0
-0.01
0.01
true
true
"" ""
PENS

SLIDER
1234
26
1373
59
clustering-grid-size
clustering-grid-size
0
20
20.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Simple implementation of heterogeneous Swarm Chemistry System (see references)

## HOW IT WORKS

Agents of heterogeneous species interact following local behavior, with different parameters values depending on the species. See ref.

NOTE: world is a sphere; in a closed box behaviors are not interesting (too much collisions on the wall, become more important than interactions)

## HOW TO USE IT

Different setup modes are proposed:
<ul>
  <li>setup from sile: reads a text file describing the species. First line is comment, second is parameters names list (separated by space) (two first lines mandatory). Following lines are values for each species (comment lines beginning with "#" are accepted).</li>
  <li>random: creates <code>species-number</code> species with random values of parameters (total number of agents is fixed). Parameters are distributed Gaussianly around the means (std-dev mean / 2 )</li>
  <li>predefined configurations (reproduction of results obtained in the ref article e. g.)</li>
</ul>

Run to have swarm.

If you obtained an interesting configuration through randomization, you can export it to a config file with the <code>export</code> button.

## THINGS TO NOTICE

Model is quite simple but possible behaviors are enormous.
Only with one species you can observe interesting things, then try to make the mixture heterogeneous.

Output clustering graph gives for each species Moran spatial-autocorrelation index: 0 is normal distrib, 1 is concerntred on one point, -1 is chessboard. See refs (Tsai 2005).

## THINGS TO TRY

Try exploring various configurations through the file input.

Try to explore different behavior through random setups, and then study them after exporting the configuration to a config file.
Many species leads to cool things.

## EXTENDING THE MODEL

Add crossing possibilities: after selecting two species, a new is created by crossing.
Crossing could be easily implemented by crossing of config files (and use of export interface).

## NETLOGO FEATURES

Nothing particular.

## RELATED MODELS

See refs.

## CREDITS AND REFERENCES

<h2>Implementation :</h2>
<a href="mailto:juste.raimbault@polytechnique.edu">Juste Raimbault</a>
M2 Complex Systems, Ecole Polytechnique ; LVMT, ENPC

<h2>References :</h2>

@incollection{sayama2007decentralized,
  title={Decentralized control and interactive design methods for large-scale heterogeneous self-organizing swarms},
  author={Sayama, Hiroki},
  booktitle={Advances in Artificial Life},
  pages={675--684},
  year={2007},
  publisher={Springer}
}


@article{tsai2005quantifying,
	Author = {Tsai, Yu-Hsin},
	Journal = {Urban Studies},
	Number = {1},
	Pages = {141--161},
	Title = {Quantifying urban form: compactness versus' sprawl'},
	Volume = {42},
	Year = {2005}}
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
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
