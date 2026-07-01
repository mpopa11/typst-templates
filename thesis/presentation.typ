// ============================================================
//  Thesis Presentation (Touying)
//  Uses config.typ from the thesis template
// ============================================================

#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.5" as fletcher: node, edge
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#import "config.typ": *

#show: show-theorion

// cetz and fletcher bindings for touying (optional, for diagrams)
#let cetz-canvas = touying-reducer.with(
  reduce: cetz.canvas,
  cover: cetz.draw.hide.with(bounds: true),
)
#let fletcher-diagram = touying-reducer.with(
  reduce: fletcher.diagram,
  cover: fletcher.hide,
)

// Helper: bilingual slide titles based on config.typ's `language`
#let slide-title(ro, en) = if language == "ro" { ro } else { en }

// Configure touying university theme
#show: university-theme.with(
  aspect-ratio: "16-9",
  align: left + top,
  config-common(
    frozen-counters: (theorem-counter,),
    show-notes-on-second-screen: right, 
  ),
  config-info(
    title: [#thesis_title],
    subtitle: [#doc_kind()],
    author: [#student],
    date: year,  // adjust to a specific defense date if needed
    institution: [
      #align(center)[
        // Top: one-column grid, two rows.
        #grid(
          columns: (1fr,),
          row-gutter: 0.5cm,
          align: (center,),


          // --- Lower row: original 3-column layout ---
          grid(
            columns: (2cm, 2cm, 4cm),
            column-gutter: 0.5cm,
            align: (center + horizon, center + horizon),
            // left logo: university
            image(university_logo_path(), height: 2cm, fit: "contain"),

            // center logo: faculty logo (fixed)
            image("../logos/fac_acs/acc_logo.svg", height: 2cm, fit: "contain"),

            // right logo: department-specific, language-specific
            image(department_logo_path(), width: 4cm, fit: "contain"),

          ),

          // Center text: department, faculty, university
          align(center + horizon)[
            #set par(leading: 0.4em, spacing: 0em)
            #text(size: 10pt, weight: "bold")[#department_name()] \
            #text(size: 10pt, weight: "bold")[#t("label_faculty")] \
            #text(size: 10pt, weight: "bold")[#t("label_university")] \
            #text(size: 10pt, weight: "bold")[#t("label_university_short")]
          ],
        )
      ]
    ],
    // Replace with your preferred logo (e.g., central university logo)
    logo: box(
      image(department_logo_path(), height: 1em),
      height: 1em,
    ),
  ),
)

// Heading numbering for slides (simple, or set to `none`)
#set heading(numbering: numbly("{1}.", default: "1.1"))

// ------------------------------------------------------------
//  Title & Outline
// ------------------------------------------------------------

#title-slide()

== #slide-title("Cuprins", "Outline") <touying:hidden>

#components.adaptive-columns(
  outline(title: none, indent: 1em, depth: 1),
)

// ------------------------------------------------------------
//  Domain and Context
// ------------------------------------------------------------

= #slide-title("Domeniu și context", "Domain and Context")

== #slide-title("Domeniu și context", "Domain and Context")

- Grad din ce în ce mai ridicat de automatizare.

- Roboți mobili autonomi.

- Navigație autonomă, indiferent de scop.

- Unde se află robotul? Cum cunoaște mediul?

#speaker-note[
  De-a lungul timpului, tendința dominantă a fost cea de automatizare a activităților omului. În acest context, au fost dezvoltate diferite metode, ajungând, în cele din urmă, la dezvoltarea sistemelor automate clasice.
  Spre deosebire de acestea, se remarcă roboții autonomi, care trebuie să fie capabili să ia decizii în baza informațiilor din mediu de unii singuri, fără intervenția operatorului uman. Indiferent de sarcina lor, aceștia trebuie să poată naviga în siguranță în mediul în care se află. Astfel se remarcă necesitatea ca robotul să cunoască mediul înconjurător și să se poată plasa în acesta.

]

// ------------------------------------------------------------
//  Problem and Importance
// ------------------------------------------------------------

= #slide-title("Problema abordată", "Problem and Motivation")

== #slide-title("Problema abordată", "Problem Statement")

- Localizarea robotului. Reprezentarea mediului.

- Probleme interdependente.

- Acumularea erorilor.

- Resurse limitate?

#speaker-note[
  În acest context, putem defini problema principală care a fost adresată, anume cea de SLAM. Putem spune că este compusă din două subprobleme: localizarea robotului și cartografierea mediului. Aceste probleme sunt profund interdependente, lucru care aduce un alt grad de dificultate.
  Soluțiile evidente, precum utilizarea GPS nu sunt viabile în majoritatea cazurilor, unde este nevoie de o precizie ridicată, indiferent de condiții.
  Un alt aspect care trebuie luat în considerare este că un robot autonom nu dispune de multe resurse de calcul, deci orice soluție trebuie să gestioneze și acest aspect.
]

== #slide-title("Importanța problemei", "Why Is This Important?")

- Hartă fidelă $+$ localizare precisă $arrow.r.double$ #text(weight: "bold", fill: rgb("#1f6feb"))[navigație în siguranță]

- Gmapping. 

- HectorSLAM.

- Cartographer. 

- SLAM Toolbox.

#speaker-note[
  Obținerea unei hărți fidele mediului este profund dependentă de estimarea corectă a poziției în care se află robotul, deoarece toate măsurătorile vor depinde de locația robotului la acel moment. 
  Pentru asta au fost dezvoltate mai multe soluții de-a lungul timpului, de la soluții bazate pe filtrare probabilistică precum Gmapping, la cele bazate pe scan matching precum HectorSLAM sau cele bazate pe optimizarea grafurilor, cea mai folosită clasă de soluții la momentul actual, precum Cartographer și SLAM Toolbox.
  Primele două clase de soluții sunt mai simple conceptual dar nu pot corecta ulterior estimările deja făcute pentru o precizie mai mare, în timp ce cele bazate pe optimizarea grafurilor vin cu un cost computațional și o complexitate mult mai ridicate.
]

// ------------------------------------------------------------
//  Proposed Solution & Architecture
// ------------------------------------------------------------

= #slide-title("Soluția propusă", "Proposed Solution")

== #slide-title("Prezentare generală a soluției", "Solution Overview")

- SLAM bidimensional bazat pe *scan-matching*.

- LiDAR $+$ odometria roților $+$ IMU.

- Fără închiderea buclelor.

- Reprezentarea mediului sub formă de *occupancy grid*


#speaker-note[
  Pentru aceasta propun o soluție bazată pe scan-matching, folosind senzorii de LiDAR, encoderele roților și IMU.
  Pentru a păstra un cost redus de resurse nu se va integra componenta de închidere a buclelor. Potrivirea e scan-to-map cu GICP, iar harta e un occupancy grid. Opțional am adăugat un EKF pentru prima estimare.
]

== #slide-title("Arhitectura sistemului", "System Architecture")

- Sistem distribuit dezvoltat în *ROS2*

- Comunicare prin *topic-uri* (model publisher-subscriber).

- Estimarea inițială a poziției (*date brute* sau *EKF*)

- Preprocesare măsurători LiDAR

- Scan-matching.

- Actualizare hartă.

#speaker-note[
 Sistemul a fost dezvoltat ca un sistem distribuit în ROS 2, comunicarea între componente, implementate în noduri se realizează folosind topic-uri, după un model de publisher-subscriber.
]

#slide(config: config-store(header: none))[
  #figure(
    image("figures/diagrama_abstracta.png", height: 10cm),
    caption: [Fluxul abstract al soluției de SLAM],
  )

  #speaker-note[
    Aici putem vedea fluxul abstract al soluției. Pentru estimarea inițială a poziției, se vor folosi fie datele brute de la senzorii odometrici și IMU, fie o estimare primită de la EKF. Măsurătorile de la LiDAR trebuie să treacă printr-o etapă de procesare înainte să fie folosibile: se elimină măsurătorile din afara plajei de valori a senzorului, se construiește setul de puncte în baza unghiului și distanței la care se găsește un obstacol. Acest set de puncte trebuie după trecut printr-o etapă de eliminare a distorsiunii cauzate de mișcarea robotului. După acestea, se poate face etapa de scan matching, în urma căreia se obține estimarea finală a poziției și harta mediului.
  ]
]

//// Exemplu de placeholder pentru o diagramă (comentează/înlocuiește după nevoie):
// #figure(
//   cetz-canvas[
//     // your cetz diagram here
//   ],
//   caption: [#slide-title("Arhitectura sistemului", "System Architecture Diagram")],
// )

// ------------------------------------------------------------
//  Implementation Decisions
// ------------------------------------------------------------

= #slide-title("Implementare", "Implementation")

== #slide-title("Decizii de implementare", "Implementation Decisions")

- ROS2 în Python.

- Scan-matching: *GICP*  $arrow$ #text(weight: "bold", fill: rgb("#1f6feb"))[small_gicp].

- EKF: *robot_localization*.

- Hartă: *occupancy grid* rezoluție de 0.05.

- Eliminarea distorsiunilor LiDAR: interpolare liniară $+$ două etape de scan-matching.


#speaker-note[
  #text(size: 20pt)[
  Pentru implementare a fost aleasă varianta implementării în Python în detrimentul C++ pentru a putea integra mai multe biblioteci și pentru un proces de dezvoltare mai simplu.
  Pentru Scan-matching a fost aleasă biblioteca small_gicp care implementează mai mulți algoritmi de tip point cloud registration. A fost ales GICP în urma experimentelor cu mai mulți algoritmi.
  Pentru  EKF, s-a folosit pachetul robot_localization care oferă posibilitatea de configurare a acestuia.
  Harta este reprezentată sub forma de occupancy grid, care este o matrice, în care fiecare celulă este asociată unei suprafețe din mediu și stochează probabilitatea ca o celulă să fie ocupată.
  Pentru compensarea distorsiunilor se interpolează liniar poziția între două estimări succesive, iar fiecare punct este corectat în funcție de momentul achiziției.
  Se folosesc două etape de scan matching, o dată pornind de la estimarea primită inițial și după folosind poziția obținută după prima etapă pentru a obține un rezultat mai precis.
  ]
]

// ------------------------------------------------------------
//  Evaluation and Results
// ------------------------------------------------------------

= #slide-title("Evaluare și rezultate", "Evaluation and Results")

== #slide-title("Setup de evaluare", "Evaluation Setup")

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.2em,
  align: (left + top, left + top),

  [
    - Simulator *Gazebo* + *TurtleBot3 Burger*.
    - 3 medii: World (≈26 m), House (≈87 m), Amazon (≈108 m).
    - Date salvate ca *ROS Bags*.
    - Metrici traiectorie: *ATE*, *RPE*.
    - Metrici hartă: proporția de celule ocupate, numărul de colțuri și numărul de spații închise.
    - Comparație: *cu EKF* vs. *fără EKF*.
  ],

  [
    #text(weight: "bold")[Hardware]
    #text(size: 18pt)[
      - AMD Ryzen 7 7735HS (8C/16T)
      - 16 GiB DDR5
      - NVIDIA RTX 4050
    ]

    #v(0.4em)
    #text(weight: "bold")[Software]
    #text(size: 16pt)[
      #table(
        columns: (auto, auto),
        align: (left, left),
        stroke: 0.5pt + gray.lighten(40%),
        inset: 6pt,
        [*Componentă*], [*Versiune*],
        [Ubuntu], [24.04 (WSL2)],
        [ROS 2], [Jazzy],
        [Gazebo], [Harmonic],
        [Python], [3.12],
        [Evo], [1.36],
        [OpenCV], [4.6.0],
        [NumPy], [1.26.4],
      )
    ]
  ],
)

#speaker-note[
  Experimentul a fost desfășurat în simulatorul Gazebo, folosind robotul TurtleBot3, un robot diferențial pe sistemul descris pe slide.
  Datele din urma unei sesiuni au fost înregistrate pentru posibilitatea de reproducere a experimentului și pentru alte configurări ale soluției.
  Se testează folosind 3 hărți de dimensiuni din ce în ce mai mari, cu din ce în ce mai multe obstacole și provocări și traiectorii care cresc în lungime.
  Se evaluează calitatea estimării traiectoriei atât global (ATE) cât și local între 2 estimări consecutive (RPE) comparând cu traiectoria reală preluată din simulator.
  Se evaluează calitatea structurală a hărții și prin metricile de proporție, număr de colțuri și spații închise, care cu cât sunt mai mici cu atât este mai bună o soluție în mod uzual.
  Se studiază și impactul estimării inițiale provenite de la EKF.
]

== #slide-title("Rezultate I", "Results I")
=== Traiectorii
#grid(
  columns: 2,
  gutter: 1cm,
  [
    #figure(
      table(
        columns: 3,
        align: center,
        table.header([*Mediu*], [*Fără EKF*], [*EKF*]),
        [World], [0.0228], [0.0231],
        [House], [0.0486], [0.0401],
        [Amazon House], [0.0278], [0.0299],
      ),
      caption: [RPE RMSE (m)],
    )
  ],
  [
    #figure(
      table(
        columns: 3,
        align: center,
        table.header([*Mediu*], [*Fără EKF*], [*EKF*]),
        [World], [0.0196], [0.0174],
        [House], [0.1472], [0.1005],
        [Amazon House], [0.0427], [0.0543],
      ),
      caption: [ATE RMSE (m)],
    )
  ],
)

- Erori *globale (ATE) sub 0.1%* din lungimea traiectoriei.

- Erori *locale (RPE) 2–5 cm* (< 0.09%).


#speaker-note[
 Aici avem erorile traiectoriilor în cele 3 medii de testare. Se pot observa valori în general mai mici ale erorilor în cazul configurației cu EKF, însă doar în cazul celei de-a doua traiectorii se văd diferențe substanțiale.
 Acest lucru denotă faptul că estimarea este dominată de scan-matching, nefiind la fel de influentă sursa primei estimări.
 Erorile sunt de sub 0.1% ceea ce reprezintă o performanță bună.
]

== #slide-title("Rezultate II", "Results II")
=== Hărți

#align(center)[
  #figure(
    text(size: 19pt)[
      #table(
        columns: (auto, auto, auto, auto, auto),
        align: (left, left, center, center, center),
        inset: (x: 12pt, y: 8pt),
        // stroke: none,
        table.header(
          [*Mediu*], [*Config.*], [*Proporție*], [*Colțuri*], [*Sp. închise*],
        ),
        table.hline(stroke: 1pt),
        table.cell(rowspan: 2)[World], [fără EKF], [0.0624], [27], [7],
        table.hline(start: 1, stroke: 0.5pt + gray.lighten(30%)),
        [cu EKF], [0.0609], [27], [6],
        table.hline(stroke: 1pt),
        table.cell(rowspan: 2)[House], [fără EKF], [0.0362], [83], [5],
        table.hline(start: 1, stroke: 0.5pt + gray.lighten(30%)),
        [cu EKF], [0.0364], [81], [1],
        table.hline(stroke: 1pt),
        table.cell(rowspan: 2)[Amazon], [fără EKF], [0.0304], [123], [2],
        table.hline(start: 1, stroke: 0.5pt + gray.lighten(30%)),
        [cu EKF], [0.0302], [109], [1],
        table.hline(stroke: 1pt),
      )
    ],
    caption: [Calitatea structurală a hărților],
  )
]

#speaker-note[
  În acest tabel sunt prezentate metricile structurale ale hărților care vizează să detecteze instabilitatea poziției sau apariția erorilor, care vor duce la deplasarea reperelor din hartă, creând colțuri noi sau zone închise noi.
  Performanțele tind să fie mai bune în cazul configurațiilor cu EKF, lucru care este din ce în ce mai evident pe măsură ce crește complexitatea și lungimea traiectoriei.
]

// ------------------------------------------------------------
//  Resulting maps (one slide per environment)
// ------------------------------------------------------------

// Helper: un slide de hărți (vedere de sus + rezultat fără/cu EKF)
#let map-slide(no-ekf, ekf, h: 10cm) = align(center + horizon)[
  #grid(
    columns: 2,
    column-gutter: 1cm,
    align: bottom + center,
    [ #rotate(-90deg, reflow: true)[#image(no-ekf, width: h)] #v(0.3em) Fără EKF ],
    [ #rotate(-90deg, reflow: true)[#image(ekf, width: h)] #v(0.3em) Cu EKF ],
  )
]

== #slide-title("Hărți rezultate — World", "Resulting Maps — World")
#map-slide(
  "figures/tbe_world_no_ekf_1.png",
  "figures/tbe_world_ekf_1.png",
)

#speaker-note[
  Aici sunt hărțile obținute pentru primul mediu de testare. 
  Se observă rezultate bune în ambele cazuri, lucru care era de așteptat, deoarece harta este mai mică, cu puține provocări, fiind de asemenea vorba de o traiectorie mai scurtă pentru a testa performanțele de bază ale sistemului.
]

== #slide-title("Hărți rezultate — House", "Resulting Maps — House")
#map-slide(
  "figures/tbe_house_no_ekf_1.png",
  "figures/tbe_house_ekf_1.png",
)

#speaker-note[
  În acest caz sunt prezentate hărțile obținute pentru cel de-al doilea mediu, care vine cu o suprafață mai mare, și cel mai important, treceri între camere, care vin cu o dificultate mult mai mare în cazul sistemelor de scan matching, făcându-se trecere de la o zonă cunoscută unde există repere, la o nouă zonă care nu poate fi comparată la fel de bine cu restul hărții.
  Se observă că EKF aduce o stabilitate mai mare din punct de vedere al orientării, fiind ameliorată eroarea din partea de jos a hărții.
]

== #slide-title("Hărți rezultate — Amazon", "Resulting Maps — Amazon")
#map-slide(
  "figures/tbe_amazon_no_ekf_1.png",
  "figures/tbe_amazon_ekf_1.png",
)

#speaker-note[
   Nu în ultimul rând, rezultatele pentru cea de a treia hartă, unde se pot observa din nou performanțe bune în cazul ambelor variante, cu ceva mai multe artefacte în cazul configurării fără EKF. Structura pereților este mai solidă în cazul celei de-a doua configurații, păstrând integritatea unghiulară a acestora mai bine.
]

// ------------------------------------------------------------
//  Conclusions and Key Results
// ------------------------------------------------------------

= #slide-title("Concluzii", "Conclusions")

== #slide-title("Concluzii", "Conclusions")

- Sistem SLAM bidimensional bazat pe scan matching.

- Integrare EKF pentru predicția inițială.

- Erori < 0.1%.

- Hărți fidele.

- Impact EKF scăzut la estimarea traiectoriei.

- Impact EKF vizibil la calitatea structurală a hărților.

#speaker-note[
  În concluzie, a fost realizat un sistem de SLAM bidimensional bazat pe scan matching care se folosește de LiDAR, IMU și encoderele roților pentru a estima poziția și a cartografia mediul.
  S-au înregistrat erori mai mici de 0.1%, iar hărțile generate reprezintă mediul într-o manieră fidelă.
  EKF-ul nu are un impact prea mare la estimarea traiectoriei, însă integrarea acestuia aduce beneficii clare cu privire la calitatea hărților produse.
]

== #slide-title("Lucrări viitoare", "Future Work")

- Componentă de închidere a buclelor.

- Paralelizarea componentelor.

- Optimizarea în continuare a procesului.

#speaker-note[
  Pe viitor se poate dezvolta o componentă de detecție și închidere a buclelor, ceea ce presupune trecerea la o abordare tip optimizarea grafurilor, caz în care trebuie studiat impactul pe care îl va avea cea de a doua etapă de scan matching din arhitectura curentă.
  Pentru performanțe mai bune se va urmări optimizarea procesului (folosirea algoritmului lui Bresenham poate fi vectorizată de exemplu) și paralelizarea componentelor (scan matching).
]

// ------------------------------------------------------------
//  Backup / Appendix slides
// ------------------------------------------------------------

#show: appendix

= #slide-title("Anexe", "Appendix")

// ------------------------------------------------------------
//  Appendix — trajectories (one slide per environment)
// ------------------------------------------------------------

// Helper: un slide de traiectorii (estimat vs. referință, fără/cu EKF)
#let traj-slide(no-ekf, ekf, h: 8.5cm) = align(center + horizon)[
  #grid(
    columns: 2,
    column-gutter: 1cm,
    align: bottom + center,
    [ #image(no-ekf, height: h) #v(0.3em) Fără EKF ],
    [ #image(ekf, height: h) #v(0.3em) Cu EKF ],
  )
]

== #slide-title("Detalii: scan matching și hartă", "Details: Scan Matching")

- Scan-matching în două etape:
  - Etapa 1: corespondență max. 0.2 m, max. 15 iterații; respins dacă $Delta_"translație"$ > 0.2 m sau $Delta_"unghi"$ > ~5°.
  - Etapa 2: corespondență max. 0.1 m, max. 10 iterații; respins dacă $Delta_"translație"$ > 0.1 m sau $Delta_"unghi"$ > ~3°.
- Occupancy grid *log-odds*: +0.2 (ocupat), −0.1 (liber), trunchiat în $[-6, 6]$.
- Vizualizare: $p > 70%$ → ocupat, $p < 20%$ → liber, restul → necunoscut.

== #slide-title("Detalii: configurarea EKF", "Details: EKF Configuration")

- Surse fuzionate: $v_x$ și $v_"yaw"$ de la odometrie + $v_"yaw"$ de la IMU.

- Excluse: accelerațiile și yaw-ul absolut de la IMU (impact negativ experimental).

- Respingere valori în funcție de distanța *Mahalanobis* (prag 15 σ).


== #slide-title("Traiectorii — World", "Trajectories — World")
#traj-slide(
  "figures/tb3_world_no_ekf_trajectories.png",
  "figures/tb3_world_ekf_trajectories.png",
)

== #slide-title("Traiectorii — House", "Trajectories — House")
#traj-slide(
  "figures/tb3_house_no_ekf_trajectories.png",
  "figures/tb3_house_ekf_trajectories.png",
)

== #slide-title("Traiectorii — Amazon", "Trajectories — Amazon")
#traj-slide(
  "figures/tb3_amazon_no_ekf_trajectories.png",
  "figures/tb3_amazon_ekf_trajectories.png",
)

