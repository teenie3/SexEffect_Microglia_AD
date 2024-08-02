globals[
  region-boundaries
  neuron-distance
  inflam-radius

  sensing-efficiency
  eat-probability
  microglia-mobility-speed
  microglia-activation

  min-age ; minimum starting age considered for hormone changes
  max-age ; maximum age a person live

  day

  ad-progression-men
  ad-progression-women
  phagocytosis-rate-men
  phagocytosis-rate-women

  ;female region
  estrogen
  menopausal ; Boolean for female menopause
  min-menopausal-age; age at which menopause begin

  ;male region
  estrogen-male
  testosterone
  andropausal ; Boolean for male andropause
  min-andropausal-age; age at which andropause begin
  testosterone-microglia-initiation-point
  estrogen-male-microglia-initiation-point

  microglia-phagocytosis
  ad-progression

  damage-chance ; fixed percent chance that can damage a healthy neuron if there is a synapse between it and a damaged neuron.
  apoe-option;

  dNeuron-phagocytosis-success-counter-female
  dNeuron-phagocytosis-success-counter-male

  dNeuron-approach-count-female
  dNeuron-approach-count-male

  microglia-efficiency-male
  microglia-efficiency-female


]

breed [ dividers divider ]
breed [ microglia a-microglia ]
breed [ dNeurons dNeuron]
breed [ hNeurons hNeuron]
undirected-link-breed [ synapses synapse ]

microglia-own [
  wait-ticks     ; number of ticks a microglia will wait during surveillance/phagocytosis
]

patches-own[
  region
  sex ; male or female
  ; inflam-val is the actual inflammation value a current patch has, and is used for
  ; the direction microglia move towards. inflam-change is a separate variable used
  ; to calculate the diffusal and dismantling of inflammation for patches other than
  ; the current one.
  inflam-val
  inflam-change
  curr-spread  ; current radius that inflammation is spreading.
  residence?   ; is there a dNeuron on patch?
  dismantling? ; is the patch dismantling (a dNeuron just got eaten)?

  ;microglia-phagocytosis
  ;ad-progression

  ;define menstrual phases
  phase ; can be "menstrual", "follicular", "ovulation", "luteal", "menopause",
]

to startup ;User-defined procedure which will be called when a model is first loaded in the NetLogo application.
  setup-regions 2
end


;------------------------------------------------------------------
;------------------------- setup -------------------------------------
;------------------------------------------------------------------
to setup
  clear-all
  setup-regions 2

  set-default-shape dNeurons "circle"
  set-default-shape hNeurons "circle"
  setup-microglia
  setup-hNeurons
  setup-dNeurons

  set neuron-distance 5
  set inflam-radius 5

  set day 1
  set min-age 20
  set max-age 90

  set sensing-efficiency 50
  set microglia-mobility-speed 50 ; 50%
  set eat-probability 50 ; %

  set ad-progression-men 0
  set ad-progression-women 0
  set phagocytosis-rate-men 0
  set phagocytosis-rate-women 0

  set estrogen 50 ; Initial estrogen level
  set min-menopausal-age 51 ;

  ;male region
  set estrogen-male 10
  set testosterone 1000 ; Initial testosterone level
  set andropausal false; Boolean for male andropause
  set min-andropausal-age 50; age at which andropause begin
  set testosterone-microglia-initiation-point 500
  set estrogen-male-microglia-initiation-point 28

   set microglia-phagocytosis 0
   set ad-progression 0

  set apoe-option APOE
  set damage-chance 1 ; 5 percent chance that can damage a healthy neuron if there is a synapse between it and a damaged neuron.
  set dNeuron-phagocytosis-success-counter-female 0
  set dNeuron-phagocytosis-success-counter-male 0

  set dNeuron-approach-count-female 1
  set dNeuron-approach-count-male 1

  set microglia-efficiency-male 1
  set microglia-efficiency-female 1


  ask patches [
    set residence? false    ; boolean value for if inflammation is present
    set dismantling? false  ; boolean value for if inflammation is in the process of dismantling


    if pxcor < 0 [
      set sex "female"
      set menopausal false
      ;set testosterone 10 ; Initial testosterone level
    ]

    if pxcor >= 0 [
      set sex "male"
      set andropausal false


    ]
    set microglia-activation false
    ;set microglia-phagocytosis 0
    ;set ad-progression 0
  ]

  ask dNeurons [
    ask patch-here [
      set inflam-val 1     ; initial inflammation value for patches with damaged neurons
      set curr-spread 1    ; current radius of the inflammation spread
      set residence? true
    ]
  ]

  ; Creating synapses between nearby neurons of either type. If there's multiple
  ; neurons in the synapse radius, the neuron will create only one synapse with
  ; one other neuron.
  ask (turtle-set dNeurons hNeurons) [
    ; create agentset of nearby neurons for the current neuron
    let nearby-neurons other (turtle-set dNeurons hNeurons) in-radius neuron-distance
    if any? nearby-neurons [ create-synapse-with one-of nearby-neurons ]
  ]
  reset-ticks
end

to setup-microglia
  ; This procedure simply creates turtles in the different regions.
  ; The `foreach` pattern shown can be used whenever you
  ; need to do something for each different region.
  foreach (range 1 (length region-boundaries + 1)) [ region-number ->
    let region-patches patches with [ region = region-number ]
    create-microglia num-of-microglia [
      set color green
      set size 2
      set wait-ticks 0
      while [any? other turtles-here]
        [ move-to one-of region-patches ]
    ]
  ]
end

to setup-dNeurons
  ; This procedure simply creates turtles in the different regions.
  ; The `foreach` pattern shown can be used whenever you
  ; need to do something for each different region.
  foreach (range 1 (length region-boundaries + 1)) [ region-number ->
    let region-patches patches with [ region = region-number ]

    ;if age > 40 [
      create-dNeurons num-of-dNeurons [
        set color red
        set size 1.5
        while [any? other turtles-here]
        [ move-to one-of region-patches ]
      ]
   ; ]
  ]
end

to setup-hNeurons
  ; This procedure simply creates turtles in the different regions.
  ; The `foreach` pattern shown can be used whenever you
  ; need to do something for each different region.
  foreach (range 1 (length region-boundaries + 1)) [ region-number ->
    let region-patches patches with [ region = region-number ]
    create-hNeurons num-of-hNeurons [
      set color pink
      set size 1.5
      while [any? other turtles-here]
        [move-to one-of region-patches]
    ]
  ]
end


;------------------------------------------------------------------
;------------------------- go -------------------------------------
;------------------------------------------------------------------
to go
  ; This procedure simply creates turtles in the different regions.
  ; The `foreach` pattern shown can be used whenever you
  ; need to do something for each different region.
  foreach (range 1 (length region-boundaries + 1)) [ region-number ->
    let region-patches patches with [ region = region-number ]

    ;stopping condition for the program
    ;phagocytosis and microglia movement occurs until if a damaged neuron is found or age reaches 90 years
    ;if not any? dNeurons or age >= 90 [ stop ]
    if age >= 90 [ stop ]
    set apoe-option APOE

    ask patches [



     if sex = "female" [
        check-menopausal-based-on-age
        ifelse menopausal [
          update-hormones-menopause
          update-microglia-initiation-menopause
        ] [
          update-hormones-pre-menopause
          update-microglia-initiation-pre-menopause
        ]
     ]
     if sex = "male" [
        check-andropausal-based-on-age
        update-hormones-determinants-male
        update-microglia-activation-male
     ]
    ]

    if (ticks mod 50 = 0) ; 1 year = 50 ticks
    [
      set age age + 1
    ]

    set day day + 1
    if day > 28 [ set day 1 ] ; Reset cycle every 28 days

    update-ad-progression
    update-phagocytosis


    set ad-progression-men sum [ad-progression] of patches with [sex = "male"]
    set ad-progression-women sum [ad-progression] of patches with [sex = "female"]
    set phagocytosis-rate-men mean [microglia-phagocytosis] of patches with [sex = "male"]
    set phagocytosis-rate-women mean [microglia-phagocytosis] of patches with [sex = "female"]

    ask microglia [
      ; If wait-ticks is 0, take some action. Else, "wait" one tick and reduce wait-ticks by 1
      ifelse wait-ticks = 0
      [ set color green                                 ; microglia currently moving are green
        move


        if any? dNeurons-on patch-here [ eat-attempt ]  ; tries to eat if damaged neuron is on current patch



        if any? hNeurons-on patch-here [ survey ] ]     ; surveys if healthy neuron is on current patch
      [ set color yellow                                ; microglia currently waiting are yellow
        set wait-ticks wait-ticks - 1 ]
    ]

    ; If ticks is a multiple of 5, do following actions
    if (ticks mod 5 = 0)
    [
      ask dNeurons
      [
        ask patch-here
        [
          ; if curr-spread of inflammation is less than the set inflam-radius, diffuse inflammation
          if curr-spread < inflam-radius [ diffuse-inflam ]
        ]
      ]
      ask patches with [ dismantling? and (curr-spread <= inflam-radius) ] [ dismantle-inflam ]  ; dismantles inflammation over time
    ]

    ask hNeurons with [damage-link] [
     get-damaged
    ]

    ask patches with [sex = "female"][
          calculate-microglia-efficiency-female
    ]
    ask patches with [sex = "male"][
          calculate-microglia-efficiency-male
    ]



     ;display-results
   ; display-difference-in-ad-based-on-sex
    tick
   ]
end

;------------------------------------------------------------------
;------------------------- region 1 - 'female' -----------------------
;------------------------------------------------------------------

to check-menopausal-based-on-age
  ifelse (age >= min-age and age <= min-menopausal-age) [
      set menopausal false;
  ] [
      set menopausal true;
  ]
end


to update-hormones-pre-menopause
    (ifelse
      day <= 5 [
      set phase "menstrual"

      ;randomly assign estrogen level from 1 - 50 pg/ml of estrogen
      set estrogen (1 + random (50 - 1 + 1)) ;       estrogen random 50 < 1
      ;set testosterone testosterone
      set sensing-efficiency (1 + random (50 - 1 + 1)) ;
      set microglia-mobility-speed (1 + random (50 - 1 + 1)) ;
      set eat-probability (1 + random (50 - 1 + 1)) ;
    ]
      day > 5 and day <= 12 [
      set phase "follicular"
      set estrogen (19 + random (140 - 19 + 1)) ;             set estrogen random 140 < 19
      set sensing-efficiency (50 + random (60 - 50 + 1)) ;
      set microglia-mobility-speed (50 + random (60 - 50 + 1)) ;
      set eat-probability (50 + random (60 - 50 + 1)) ;
     ; set testosterone 10
      ;set testosterone testosterone
    ]
     day >= 13 and day <= 14 [
      set phase "ovulation"
      set estrogen (110 + random (410 - 110 + 1)) ;        set estrogen random 410 < 110
      set sensing-efficiency (80 + random (90 - 80 + 1)) ;
      set microglia-mobility-speed (80 + random (90 - 80 + 1)) ;
      set eat-probability (80 + random (90 - 80 + 1)) ;
      ;set testosterone testosterone
    ]
     day > 14 and day <= 28 [
      set phase "luteal"
      set estrogen (19 + random (160 - 19 + 1)) ;        set estrogen random 160 < 19
      set sensing-efficiency (60 + random (70 - 60 + 1)) ;
      set microglia-mobility-speed (60 + random (70 - 60 + 1)) ;
      set eat-probability (60 + random (70 - 60 + 1)) ;
      ;set testosterone testosterone
      ]
    )
end

to update-hormones-menopause
    set phase "menopause"
    set estrogen (35 + random (50 - 35 + 1)) ;  set estrogen random 50 < 35
    set sensing-efficiency (1 + random (30 - 1 + 1)) ;
    set microglia-mobility-speed (1 + random (30 - 1 + 1)) ;
    set eat-probability random (1 + random (30 - 1 + 1)) ;
  ;set testosterone testosterone
end

to update-microglia-initiation-pre-menopause
    (ifelse
      [phase] of one-of patches = "menstrual" or [phase] of one-of patches = "luteal" [
        set microglia-activation true
      ] [
        set microglia-activation false
    ])
end

to update-microglia-initiation-menopause
    ifelse estrogen < 40 [
      set microglia-activation true
    ] [
      set microglia-activation false
    ]
 ; ]
end

;------------------------------------------------------------------
;------------------------- region 2 - 'male' -----------------------
;------------------------------------------------------------------
to check-andropausal-based-on-age
  ifelse age >= 20 and age <= 50 [
      set andropausal false;
  ] [
      set andropausal true;
  ]
end



to update-hormones-determinants-male
 ; while [age < 9] [
    ;set age (age + 1)
    update-testosterone-estrogen-values
    ifelse age < 50 [
      update-determinants-pre-andropause
    ][
      update-determinants-post-andropause
    ]
 ; ]
end


to update-testosterone-estrogen-values
  ; Define testosterone and estrogen levels based on age
  ifelse age < 30 [
    set testosterone  random-float 51 + 950  ; 950 - 1000
    set estrogen-male random-float 3 + 10      ; 10 - 12
  ] [
    ifelse age < 40 [
      set testosterone random-float 51 + 850  ; 850 - 900
      set estrogen-male random-float 4 + 12      ; 12 - 16
    ] [
      ifelse age < 50 [
        set testosterone random-float 51 + 750  ; 750 - 800
        set estrogen-male random-float 4 + 16      ; 16 - 20
      ] [
        ifelse age < 60 [
          set testosterone random-float 51 + 650  ; 650 - 700
          set estrogen-male random-float 4 + 20      ; 20 - 24
        ] [
          ifelse age < 70 [
            set testosterone random-float 51 + 550  ; 550 - 600
            set estrogen-male random-float 4 + 24      ; 24 - 28
          ] [
            ifelse age < 80 [
              set testosterone random-float 51 + 450  ; 450 - 500
              set estrogen-male random-float 4 + 28      ; 28 - 32
            ] [
              ifelse age < 90 [
                set testosterone random-float 51 + 350  ; 350 - 400
                set estrogen-male random-float 4 + 32      ; 32 - 36
              ] [
                set testosterone random-float 51 + 300  ; 300 - 350
                set estrogen-male random-float 4 + 36      ; 36 - 40
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to update-testosterone-estrogen-values-orig
  ifelse age <= 30 [
    ; Decrease value by 10 each year until age 30

    ;set testosterone precision (testosterone - 10) 2

    ; Increase value by 0.2 each year until age 30
    ;set estrogen-male precision (estrogen-male + 0.2) 2
    set testosterone testosterone - 10

    ; Increase value by 0.2 each year until age 30
    set estrogen-male estrogen-male + 0.2

  ] [
    ; After age 30, decrease value by 10 each year, and increase by 0.4 each year
    ;set testosterone precision (testosterone - 10) 2
    ;set estrogen-male precision (estrogen-male + 0.4) 2

    set testosterone testosterone - 10
    set estrogen-male estrogen-male + 0.4
  ]
end

to update-determinants-pre-andropause
  set phase "pre-andropause"
  set sensing-efficiency (80 + random (90 - 80 + 1)) ; //survey
  set microglia-mobility-speed (80 + random (90 - 80 + 1)) ; //move
  set eat-probability (80 + random (90 - 80 + 1)) ;//eat
end

to update-determinants-post-andropause
  set phase "andropause"
  set sensing-efficiency (1 + random (30 - 1 + 1)) ;
  set microglia-mobility-speed (1 + random (30 - 1 + 1)) ;
  set eat-probability random (1 + random (30 - 1 + 1)) ;
end

to update-microglia-activation-male
 ; ask patches with [sex = "male"] [
    ifelse (testosterone < 500 ) and (estrogen-male > 28) [
      set microglia-activation true
    ] [
      set microglia-activation false
    ]
  ;]
end



to update-ad-progression
  ;ask patches [
    ifelse microglia-activation [
      set ad-progression ad-progression + 1
    ] [
      set ad-progression ad-progression - 0.5
      if ad-progression < 0 [ set ad-progression 0 ]
    ]
  ;]
end

to update-phagocytosis
  ;ask patches [
    ifelse microglia-activation [
      set microglia-phagocytosis microglia-phagocytosis + 0.1
    ] [
      set microglia-phagocytosis microglia-phagocytosis - 0.05
      if microglia-phagocytosis < 0 [ set microglia-phagocytosis 0 ]
    ]
  ;]
end



to move
  let current-region region
  rt random 50
  lt random 50
  ; only goes uphill with a % chance determined by sensing-efficiency. If all neighboring patches have the same
  ; inflammation, move normally instead
 ifelse (random 100 < sensing-efficiency) and (max [inflam-val] of neighbors) != (min [inflam-val] of neighbors)
    [ uphill inflam-val ]
    [ fd 1 ]

  keep-in-region current-region
end

; microglia procedure: stops movement to attempt phagocytosis on damaged neuron on current patch
to eat-attempt
  set color yellow
  set wait-ticks 5  ; microglia waits 5 ticks after an eat attempt, regardless of success
  let prey one-of dNeurons-here
  ;approach count here
    ; count of prey before die
  if sex = "female"[
    set dNeuron-approach-count-female dNeuron-approach-count-female + 1
  ]
  if sex = "male"[
      set dNeuron-approach-count-male dNeuron-approach-count-male + 1
  ]


  if random 100 < eat-probability [
    ask prey [ die ]
    if sex = "female"[
      set dNeuron-phagocytosis-success-counter-female dNeuron-phagocytosis-success-counter-female + 1
    ]
    if sex = "male"[
      set dNeuron-phagocytosis-success-counter-male dNeuron-phagocytosis-success-counter-male + 1
    ]

    ask patch-here [
      set residence? false    ; since patch no longer has a damaged neuron on it
      set dismantling? true   ; patch starts dismantling the inflammation it spread
    ]
  ]
end

; microglia procedure: stops movement to survey healthy neuron on current patch
to survey
  set wait-ticks 2
end

; hNeuron procedure: causes a healthy neuron to become damaged if it there is a
; synapse between it and a damaged neuron, with some fixed percent chance.
to get-damaged

  if APOE = "4d" and age > 55 [

     set damage-chance (2.7 * damage-chance)

  ]
  if APOE = "4s" and age > 55 [

    set damage-chance (1.5 * damage-chance)
  ]

   if APOE = "3" and age > 55 [

    set damage-chance (1.2 * damage-chance)
  ]
  if (APOE = "1" or APOE = "2")  and age > 55 [
    set damage-chance (1 * damage-chance)
  ]

  if precision (random-float 100) 2 < (damage-chance) [
    set breed dNeurons ; changes breed from healthy to damaged
    set color red
    ask patch-here [   ; update patch neuron is on to a resident with inflammation
      diffuse-inflam
      ask patches in-radius inflam-radius [ update-colors ]
    ]
  ]
end


to calculate-microglia-efficiency-male
 if sex = "male" [
    set microglia-efficiency-male 100 * (dNeuron-phagocytosis-success-counter-male / dNeuron-approach-count-male )
]

end

to calculate-microglia-efficiency-female
 if sex = "female" [
    set microglia-efficiency-female 100 * (dNeuron-phagocytosis-success-counter-female / dNeuron-approach-count-female )
]
end

; ==================
; patch procedures
; ==================

; diffuses inflammation over time until the max radius (inflam-radius)
; has been reached.
to diffuse-inflam
  ask patches in-radius curr-spread [
    set inflam-val inflam-val + 1  ; gives inflammation to patches within the current spreading radius
    update-colors
  ]
  set curr-spread curr-spread + 1  ; increases curr-spread to inflame farther on next diffusion cycle
end

; dismantles inflammation over time until all inflammation
; diffused from the eaten dNeuron is dismantled
to dismantle-inflam
  set curr-spread curr-spread - 1
  ask patches in-radius curr-spread [
    set inflam-val inflam-val - 1 ; remove inflammation
    update-colors
  ]
  if (curr-spread = 0) [  ; curr-spread will be zero when the area is at the origin of inflammation
    set dismantling? false
  ]
  update-colors
end

; updates patch colors after inflammation value changes, with a gradient
; illustrating different inflammation levels.
to update-colors
    set pcolor scale-color violet inflam-val 0 20
end

; =======================
; reporters and utility
; =======================

; checks if a link to a damaged neuron exists
to-report damage-link
  report any? link-neighbors with [breed = dNeurons]
end

to display-results
  ; Print results with 2 decimal precision
  ;ask patches with [sex = "male"] [
    ;print (word age " | " ( testosterone ) " | " ( estrogen-male))

    print (word microglia-efficiency-male )
 ; ]
 ; ask patches with [sex = "female"] [
    ;print (word age " | " ( testosterone ) " | " ( estrogen-male))

    print (word microglia-efficiency-female )
 ; ]
end


to display-difference-in-ad-based-on-sex
   ask patches with [sex = "male"] [


   ; print (word age " | " ( count(dNeurons ) )
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REGION MANAGEMENT CODE
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-regions [ num-regions ]
  ; Store our region definitions globally for faster access:
  set region-boundaries calculate-region-boundaries num-regions
  ; Set the `region` variable for all patches included in regions:
  let region-numbers n-values num-regions [ n -> n + 1 ]
  (foreach region-boundaries region-numbers [ [boundaries region-number] ->
    ask patches with [ pxcor >= first boundaries and pxcor <= last boundaries ] [
      set region region-number
    ]
  ])
  add-dividers
end

to add-dividers
  set-default-shape dividers "block"
  ask patches with [ region = 0 ] [
    sprout-dividers 1 [
      set color gray + 2
      set size 1.2
    ]
  ]
end

to-report calculate-region-boundaries [ num-regions ]
  ; The region definitions are built from the region divisions:
  let divisions region-divisions num-regions
  ; Each region definition lists the min-pxcor and max-pxcor of the region.
  ; To get those, we use `map` on two "shifted" copies of the division list,
  ; which allow us to scan through all pairs of dividers
  ; and built our list of definitions from those pairs:
  report (map [ [d1 d2] -> list (d1 + 1) (d2 - 1) ] (but-last divisions) (but-first divisions))
end

to-report region-divisions [ num-regions ]
  ; This procedure reports a list of pxcor that should be outside every region.
  ; Patches with these pxcor will act as "dividers" between regions.
  report n-values (num-regions + 1) [ n ->
    [ pxcor ] of patch (min-pxcor + (n * ((max-pxcor - min-pxcor) / num-regions))) 0
  ]
end

to keep-in-region [ which-region ] ; turtle procedure
  ; This is the procedure that make sure that turtles don't leave the region they're
  ; supposed to be in. It is your responsibility to call this whenever a turtle moves.
  if region != which-region [
    ; Get our region boundaries from the global region list:
    let region-min-pxcor first item (which-region - 1) region-boundaries
    let region-max-pxcor last item (which-region - 1) region-boundaries
    ; The total width is (min - max) + 1 because `pxcor`s are in the middle of patches:
    let region-width (region-max-pxcor - region-min-pxcor) + 1
    ifelse xcor < region-min-pxcor [ ; if we crossed to the left,
      set xcor xcor + region-width   ; jump to the right boundary
    ] [
      if xcor > region-max-pxcor [   ; if we crossed to the right,
        set xcor xcor - region-width ; jump to the left boundary
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
320
155
1165
587
-1
-1
9.0
1
10
1
1
1
0
1
1
1
-46
46
-23
23
1
1
1
ticks
30.0

BUTTON
18
36
125
69
setup
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
138
37
249
70
go/pause
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

INPUTBOX
141
153
248
213
num-of-microglia
3.0
1
0
Number

INPUTBOX
143
227
252
287
num-of-dNeurons
24.0
1
0
Number

INPUTBOX
23
228
130
288
num-of-hNeurons
12.0
1
0
Number

TEXTBOX
909
10
944
35
Male
14
105.0
1

TEXTBOX
729
10
765
157
 |\n |\n |\n |
30
5.0
0

TEXTBOX
523
10
587
34
Female
15
115.0
1

TEXTBOX
21
81
270
128
-------------
50
25.0
1

PLOT
323
593
740
863
populations: Female
ticks (age: 50 ticks = 1 year)
determinants
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"estrogen" 1.0 0 -8630108 true "" "plot first[estrogen] of microglia"
"d-neurons" 1.0 0 -2674135 true "" "plot count dNeurons"
"AD-risk" 1.0 0 -7500403 true "" "plot ad-progression"

PLOT
746
593
1166
863
populations: Male
ticks (age: 50 ticks = 1 year)
determinants
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"estrogen" 1.0 0 -8630108 true "" "plot first[estrogen-male] of microglia"
"d-neurons" 1.0 0 -2674135 true "" "plot count dNeurons"
"AD-risk" 1.0 0 -7500403 true "" "plot ad-progression"

CHOOSER
24
308
162
353
APOE
APOE
"1" "2" "3" "4s" "4d"
0

MONITOR
585
45
651
90
hNeurons
count hNeurons with [region = 1]
0
1
11

MONITOR
658
46
724
91
dNeurons
count dNeurons with [region = 1]
0
1
11

MONITOR
1023
44
1089
89
hNeurons
count hNeurons with [region = 2]
0
1
11

MONITOR
1100
43
1166
88
dNeurons
count dNeurons with [region = 2]
0
1
11

INPUTBOX
20
150
123
210
age
90.0
1
0
Number

MONITOR
399
45
533
90
Phase
first [phase] of patches with [sex = \"female\"]
0
1
11

MONITOR
916
44
1015
89
Phase
first [phase] of patches with [sex = \"male\"]
0
1
11

MONITOR
327
45
390
90
estrogen
estrogen
0
1
11

MONITOR
756
45
819
90
estrogen
estrogen-male
0
1
11

MONITOR
825
44
910
89
testosterone
testosterone
0
1
11

TEXTBOX
55
745
308
865
Legend\n\nGreen Arrow: Microglia (movement)\nPink Circles: Healthy Neurons (stationary)\nRed Circles : Damaged Neurons (stationary)\nRegion 1 (Left): Female\nRegion 2 (Right): Male\n
12
0.0
0

MONITOR
325
103
450
149
dNeuron-success-count
dNeuron-phagocytosis-success-counter-female
0
1
11

MONITOR
755
97
884
142
dNeuron-success-count
dNeuron-phagocytosis-success-counter-male
0
1
11

MONITOR
456
105
554
150
dNeuron-approach-count
dNeuron-approach-count-female
0
1
11

MONITOR
888
97
1020
142
dNeuron-approach-count
dNeuron-approach-count-male
0
1
11

PLOT
1184
472
1843
867
microglia-efficiency
ticks (age: 50 ticks = 1 year)
microglia-efficiency
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"m-efficiency-male" 1.0 0 -13345367 true "" "plot microglia-efficiency-male"
"m-efficiency-female" 1.0 0 -2064490 true "" "plot microglia-efficiency-female"

MONITOR
567
106
689
152
m-efficiency-female
microglia-efficiency-female
2
1
11

MONITOR
1032
98
1112
144
m-efficiency
microglia-efficiency-male
2
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model

1. Male:
)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

block
false
1
Rectangle -2674135 true true 0 0 135 300
Rectangle -7500403 true false 195 0 300 300
Rectangle -16777216 true false 135 0 180 300
Rectangle -1 true false 165 0 195 300

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
NetLogo 6.4.0
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
