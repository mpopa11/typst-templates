#import "../prelude.typ": *

//    EVALUATION CHAPTER - WRITING GUIDE (paragraph by paragraph)

//    P1. Evaluation strategy
//         - Explain how you will evaluate whether the solution addresses the original problem.
//         - List the qualities you will measure (accuracy, performance, energy, area, usability, etc.) and why they matter.
//         - Example (hardware):
//               "To assess whether the Chisel library provides a fair basis for comparing number representations, we measure functional correctness (bit-exact match with a high-precision software reference), resource usage (LUT/FF count, DSP-slice usage, BRAM), maximum clock frequency (Fmax) from synthesis, and estimated power from the Xilinx Power Estimator."
//         - Example (software):
//               "To evaluate the software library we verify numerical correctness (error versus a 128-bit decimal reference), runtime (wall-clock time per kernel), energy consumption (via Intel RAPL), and memory footprint (peak RSS)."

//    P2. Benchmarks & metrics
//         - Describe the benchmark suite you use, what each benchmark represents, and which metrics you collect for each.
//         - Example (hardware):
//               "We use a suite of DSP kernels: FIR filter (64-tap), 2-D 8x8 DCT, matrix-vector multiply (64-bit inputs), and a CORDIC-based phase-rotation block. For each kernel we record: area (LUT+FF), DSP-slice usage, BRAM, Fmax (MHz), and estimated dynamic power (mW)."
//         - Example (software):
//               "We evaluate three representative scientific-computing kernels: climate-model advection step, n-body gravitational simulation, and dense linear-algebra kernel. For each kernel we collect: mean absolute error (vs. 128-bit decimal reference), median runtime (seconds) over 30 runs, average socket power (watts) from RAPL, and peak resident memory (MiB)."

//    P3. Experimental setup
//         - Detail the hardware, software, and environmental conditions under which the benchmarks run.
//         - Include versions, configurations, and any steps taken to ensure fairness.
//         - Example (hardware):
//               "All designs are synthesized for a Xilinx Artix-7 XC7A200T FPGA (speedgrade -2) using Vivado 2023.2. Target clock is 200 MHz; we enforce a uniform IO-standard (LVCMOS18) and disable unnecessary optimizations (-no bufg). Power estimates are generated with the Xilinx Power Estimator (XPE) using default activity factors (0.1 for registers, 0.2 for logic)."
//         - Example (software):
//               "Benchmarks run on an Intel Core i7-12700K (Linux 6.8, Ubuntu 24.04) with Intel RAPL enabled for socket-level power measurement. The JVM is OpenJDK 17.0.12; sbt version is 1.9.8. Each benchmark is executed in a fresh Docker container (Ubuntu 22.04, OpenJDK 17) to isolate the build environment, while the benchmark binary itself runs on the host to access RAPL. We pin the CPU frequency to the base turbo boost (3.6 GHz) and disable hyper-threading to reduce variance."

//    P4. Results
//         - Present the outcome of each benchmark, preferably in tables or figures, and give a short, plain-language interpretation of what the numbers mean.
//         - You may split this into sub-paragraphs or sub-sections per benchmark.
//         - Example (hardware):
//               "Table 1 shows the synthesis results for the FIR filter: the posit-8 adder uses 112 LUTs and achieves a Fmax of 340 MHz, while the IEEE-754 binary32 adder needs 158 LUTs and tops out at 285 MHz. The posit-8 version therefore saves ≈ 30 % area and allows ≈ 20 % higher clock speed. Similar trends appear across the DCT and matrix-vector kernels, with posit-8 consistently delivering the best area-frequency product."
//               "Figure 2 plots estimated power versus accuracy (mean absolute error) for the CORDIC kernel; the posit-16 operating point lies on the lower-left corner, indicating lower power and lower error than binary32 at the same workload."
//         - Example (software):
//               "Table 2 summarizes the climate-advection kernel: the posit-16 implementation incurs a mean absolute error of 1.2 x 10⁻⁴ (vs. 3.5 x 10⁻⁴ for binary32) while running in 0.84 s (binary32: 0.96 s) and drawing 42 W average socket power (binary32: 48 W). This translates to a ≈ 12 % reduction in error, ≈ 13 % faster execution, and ≈ 13 % lower power."
//               "Figure 3 shows the energy-vs-error trade-off for the n-body benchmark; the unum-like format dominates the Pareto frontier, delivering the lowest error for a given energy budget."

//    P5. Data analysis
//         - Interpret the patterns across benchmarks. Discuss trade-offs, outliers, and what the results imply for the choice of number representation in different scenarios.
//         - Example (hardware):
//               "Across all four DSP kernels, the posit-8 format consistently yields the highest Fmax and lowest LUT count, making it attractive for throughput-oriented designs. The posit-16 format, while slightly larger, provides a noticeable accuracy gain (≈ 1 bit extra precision) at a modest area cost (< 10 % increase). The IEEE-754 binary32 format is never optimal on either axis for these kernels, suggesting it is over-engineered for the targeted precision range."
//         - Example (software):
//               "For memory-bound kernels (climate advection, n-body) the compact posit-8 and posit-16 formats win because they reduce memory bandwidth and cache pressure, leading to lower runtime and energy. For compute-intensive kernels with high dynamic range (LU decomposition), the unum-like format 's ability to represent very large and very small numbers without overflow/underflow gives it an accuracy edge, even though it uses more bits."

//    P6. Evaluation conclusion
//         - Summarize what the evaluation tells you about the original problem and how your solution addresses it.
//         - Link back to the research question or goal stated in the background chapter.
//         - Example (hardware):
//               "The evaluation confirms that a parameterizable hardware library enables fair, reproducible comparison of number representations. Posit-8 emerges as the best choice for low-latency, low-area accelerator kernels, while posit-16 offers a useful accuracy boost when a few extra LUTs are affordable. This answers our research question: which format(s) give the best accuracy-area-power trade-off for accelerator kernels?"
//         - Example (software):
//               "The evaluation shows that our Jenkins-integrated software library lets scientific-computing teams swap number representations with a single configuration change and instantly see the impact on correctness, runtime, and energy. Posit-16 provides the best balance for the kernels we tested, confirming that a CI-friendly library can accelerate experimentation with alternative formats in large-scale projects."


== 5.1 Structura experimentului
Evaluarea soluției se realizează prin evaluarea a celor două componente principale ale oricărei soluții de SLAM: localizarea și cartografierea.
În alte cuvinte, o soluție bună trebuie să fie capabilă să urmărească traiectoria reală cât mai bine și să construiască hărți de calitate care să reprezinte cât mai fidel posibil mediul de lucru al robotului.
Din aceste considerente au fost folosite metricile discutate anterior în lucrare, anume valorile RMSE ale RPE (@eq:rpe-rmse) și ATE (@eq:ate-rmse).
Calitatea hărților rezultate este măsurată folosind metricele de proporție, numărul de colțuri din hartă și numărul de spații închise.

Pentru evaluarea traiectoriei este necesară și existența unei traiectorii reale, față de care să se facă comparațiile între acestea.

Pentru a avea un mediu controlat în care să se poată obține și traiectoriile reale, testarea soluției a fost făcută în cadrul simulatorului Gazebo pentru a putea înregistra secvența de mesaje cu poziția reală, de referință precum și estimarea, sau datele obținute de la senzori.
Astfel, experimentul poate fi recreat pe același set de date, indiferent de schimbările eventuale aduse oricărei componente a sistemului.
Acestea au fost înregistrate sub forma unor ROS Bags.

Pe lângă aceste metrici, a fost ales și studiul impactului introducerii unui EKF, care fuzionează datele provenite de la odometria roților și IMU, față de o soluție bazată pur pe scan matching.

În @tbl:setup sunt trecute specificațiile sistemului pe care au fost realizate experimentele, precum și versiunile tehnologiilor importante.

#figure(
  table(
    columns: (5cm, auto),
    align: (left, left),
    [*Componentă*], [*Specificație*],
   [CPU], [AMD Ryzen 7 7735HS, 8 nuclee / 16 fire de execuție, cache L3 16 MiB],
    [RAM], [16 GiB DDR5],
    [GPU], [NVIDIA GeForce RTX 4050 Laptop GPU],
    [Sistem de operare], [Ubuntu 24.04.4 LTS (WSL2)],
    [ROS 2], [Jazzy Jalisco],
    [Simulator], [Gazebo Harmonic],
    [Python], [3.12.3],
    [Evo], [1.36.5],
    [OpenCV], [4.6.0],
    [NumPy], [1.26.4]
  ),
  caption: ["Specificațiile sistemului pe care au fost realizate experimentele"]
) <tbl:setup>

Cu aceste considerente, experimentele au fost realizate în Gazebo, fiind folosit robotul TurtleBot3 Burger.
Au fost alese pentru testare trei hărți, care oferă posibilitatea unei testări progresive a capacităților soluției elaborate.
Două dintre acestea au fost preluate din pachetul corespunzător robotului TurtleBot3, anume harta World (@fig:world-maps a) și harta House (@fig:house-maps a).

De asemenea a fost preluată și o hartă dezvoltată pentru o versiune mai veche de Gazebo și pentru integrare cu ROS1, anume AWS RoboMaker Small House World #footnote[Disponibil în cadrul repository-ului AWS RoboMaker Small House World:
  https://github.com/aws-robotics/aws-robomaker-small-house-world
] (@fig:amazon-maps a)

Prima hartă reprezintă un mediu cu o complexitate mică, închis, de mici dimensiuni cu doar câteva obstacole.
Prima hartă are asociată o traiectorie scurtă, de aproximativ 26 m, și validează funcționalitatea de bază pentru o posibilă soluție.

A doua hartă reprezintă o casă de dimensiuni mai mici, fără multe obstacole în interior, cu excepția unor mese, a unor rafturi și a unor coșuri.
Îi este asociată o traiectorie mai complexă, de aproximativ 87 m, care vizitează toate camerele și introduce problema impusă de trecerea dintr-o cameră în alta, adică în zone care nu se pot compara prea bine cu harta deja înregistrată.

Nu în ultimul rând, a treia hartă reprezintă cel mai complex mediu, practic este un apartament cu mai multe camere, de dimensiuni mai mari, cu mult mai multe alte obstacole, care permite o traiectorie mai lungă, de aproximativ 108 m, dar un timp de funcționare mai mare, pe parcursul procesului de cartografiere, care permite în plus și observarea acumulării drift-ului.
Din considerente de performanță în mediul de simulare Gazebo, au fost eliminate unele texturi, umbre și obiecte care nu influențează harta rezultată.
== 5.2 Rezultate

În @fig:world-traj sunt prezentate traiectoriile înregistrate de către cele două configurări ale sistemului, comparate cu traiectoria referință.
În ambele cazuri se pot observa potriviri bune, fără prea mari diferențe între cele două variante.
Acest lucru era un rezultat de așteptat, fiind vorba de un mediu prea mic, care oferea destule repere în spațiu pentru a funcționa scan matching-ul și având o traiectorie mai mică era de așteptat că nu va apuca să intervină drift-ul acesteia.

#figure(
  grid(
    columns: 2,
    gutter: 0.7cm,

    [
      #align(center)[
        #image("../figures/tb3_world_no_ekf_trajectories.png", 
        height: 5cm)
        #v(0.2em)
        (a) Configurația fără EKF
      ]
    ],

    [
      #align(center)[
        #image("../figures/tb3_world_ekf_trajectories.png", height: 5cm)
        #v(0.2em)
        (b) Configurația cu EKF
      ]
    ],
  ),
  caption: [
    Traiectoriile estimate pentru prima hartă în configurațiile fără și cu filtru EKF.
  ]
) <fig:world-traj>

În @fig:house-traj sunt expuse traiectoriile pentru cea de-a doua hartă.
În cazul acesteia, se observă anumite devieri de la referință, în ambele configurări.
Totuși a doua configurație, cea cu EKF, prezintă o potrivire mai bună, mai ales în partea dreaptă și la mijlocul ilustrației, precum și spre finalul traiectoriei, unde drift-ul total se ameliorează.

#figure(
  grid(
    columns: 2,
    gutter: 0.7cm,

    [
      #align(center)[
        #image("../figures/tb3_house_no_ekf_trajectories.png", width: 100%)
        #v(0.2em)
        (a) Configurația fără EKF
      ]
    ],

    [
      #align(center)[
        #image("../figures/tb3_house_ekf_trajectories.png", width: 100%)
        #v(0.2em)
        (b) Configurația cu EKF
      ]
    ],
  ),
  caption: [
    Traiectoriile estimate pentru a doua hartă în configurațiile fără și cu filtru EKF.
  ]
) <fig:house-traj>

Nu în ultimul rând, în @fig:amazon-traj sunt prezentate traiectoriile în cea de-a treia hartă, în care performanțele sunt bune în ambele cazuri, cu câteva excepții.
Totuși pentru prima oară se observă o potrivire puțin mai proastă în cazul configurării cu un EKF.
În schimb, se observă ca problema drift-ului nu este la fel de accentuată spre finalul traiectoriei, ceea ce sugerează că etapa de scan matching are o influență mult mai mare pentru reducerea acestuia, mai ales pe măsură ce se construiește o hartă mai detaliată.

#figure(
  grid(
    columns: 2,
    gutter: 0.7cm,

    [
      #align(center)[
        #image("../figures/tb3_amazon_no_ekf_trajectories.png", width: 100%)
        #v(0.2em)
        (a) Configurația fără EKF
      ]
    ],

    [
      #align(center)[
        #image("../figures/tb3_amazon_ekf_trajectories.png", width: 100%)
        #v(0.2em)
        (b) Configurația cu EKF
      ]
    ],
  ),
  caption: [
    Traiectoriile estimate pentru a treia hartă în configurațiile fără și cu filtru EKF.
  ]
) <fig:amazon-traj>

În @tbl:rpe și @tbl:ate se găsesc valorile RMSE pentru RPE și respectiv ATE.
RPE evaluează potrivirea pe termen scurt, și măsoară drift-ul între poziții consecutive, în timp ce ATE are caracter global și cuantifică corectitudinea pe întreaga traiectorie.
Rezultatele conturează o concluzie care începea să se formeze încă din analiza graficelor cu traiectoriile comparate.

Astfel, introducerea unui EKF vine cu rezultate inconcludente cu privire la efectul real al acestuia.
La nivel local (@tbl:rpe) ajută minimal în cazul unor traiectorii scurte (pe harta World).
În cazul unor traiectorii mai lungi pare să aibă cel mai bun efect, însă erorile tind să crească pe măsură ce lungimea traiectoriei crește.

// #grid(
//   columns: 2,
//   gutter: 1cm,

//   [
//     #figure(
//       table(
//         columns: 3,
//         align: center,

//         [*Environment*], [*Fără EKF*], [*EKF*],
//         [World], [0.022820], [0.023064],
//         [House], [0.048605], [0.040132],
//         [Amazon House], [0.027761], [0.029875],
//       ),
//       caption: [RPE RMSE (m) pentru fiecare hartă]
//     ) <tbl:rpe>
//   ],

//   [
//     #figure(
//       table(
//         columns: 3,
//         align: center,

//         [*Environment*], [*Fără EKF*], [*EKF*],

//         [World], [0.019572], [0.017394],
//         [House], [0.147214], [0.100453],
//         [Amazon House], [0.042731], [0.054339],
//       ),
//       caption: [ATE RMSE (m) pentru fiecare hartă]
//     ) <tbl:ate>
//   ]
// )

#figure(
      table(
        columns: 3,
        align: center,

        [*Environment*], [*Fără EKF*], [*EKF*],
        [World], [0.022820], [0.023064],
        [House], [0.048605], [0.040132],
        [Amazon House], [0.027761], [0.029875],
      ),
      caption: [RPE RMSE (m) pentru fiecare hartă]
    ) <tbl:rpe>

#figure(
      table(
        columns: 3,
        align: center,

        [*Environment*], [*Fără EKF*], [*EKF*],

        [World], [0.019572], [0.017394],
        [House], [0.147214], [0.100453],
        [Amazon House], [0.042731], [0.054339],
      ),
      caption: [ATE RMSE (m) pentru fiecare hartă]
    ) <tbl:ate>

La nivel global (@tbl:ate), tendința este asemănătoare, însă erorile au valori mai mari, ceea ce este de așteptat, considerând că nu există o componentă de detectare și închidere a buclelor.
Se observă că erorile scad pentru configurația cu EKF pentru primele două traiectorii, cea scurtă și cea medie.
Cea medie are chiar o scădere impresionantă față de cealaltă configurație de 4 cm.
Cu toate acestea, pentru traiectoria cea mai lungă, rezultatele sunt mai proaste.


#figure(
  table(
    columns: 4,
    align: center,

    [*Configurație*],
    [*Proporție*],
    [*Colțuri*],
    [*Spații Închise*],

    [World fără EKF], [0.0624], [27], [7],
    [World cu EKF], [0.0609], [27], [6],

    [House fără EKF], [0.0362], [83], [5],
    [House cu EKF], [0.0364], [81], [1],

    [Amazon House fără EKF], [0.0304], [123], [2],
    [Amazon House cu EKF], [0.0302], [109], [1],
  ),
  caption: [
    Rezultatele metricilor de calitate a hărților, proporția de celule ocupate, numărul de colțuri și numărul de spații închise
  ]
) <tbl:map-metrics>

În @tbl:map-metrics se regăsesc rezultatele metricilor legate de calitatea structurală a hărții. 
Acestea trebuie însă puse în relație cu hărțile obținute pentru a obține o înțelegere mai profundă cu privire la rezultate.

În cadrul primei hărți (@fig:world-maps) se observă similarități ridicate între cele 2 hărți rezulate.
Ambele au reușit să ilustreze fidel mediul, precum și coloanele, fără distorsiuni ale reperelor.

În cazul acesta, numărul de  spații închise nu este relevant, deoarece coloanele din interiorul hărții sunt detectate ca fiind acele spații închise care ar fi în plus. 
Din acest punct de vedere prima configurație a completat mai bine harta.
Pe de altă parte, proporția de celule ocupate este considerabil mai mică comparativ, la cea de-a doua configurație, ceea ce înseamnă că pereții sunt mai fini, deci și poziția a fost mai stabilă în cea de-a doua configurație.

#figure(
  [
    #align(center)[
      #rotate(0deg)[
        #image("../figures/world.png", height: 6cm)
      ]
      #v(0.2em)
      (a) Harta World privită de sus
    ]

    #grid(
      columns: 2,
      gutter: 0.7cm,

      [
        #align(center)[
          #rotate(-90deg)[
            #image("../figures/tbe_world_no_ekf_1.png", height: 5cm)
          ]
          #v(0.2em)
          (b) Harta rezultată în urma configurației fără EKF
        ]
      ],

      [
        #align(center)[
          #rotate(-90deg)[
            #image("../figures/tbe_world_ekf_1.png", height: 5cm)
          ]
          #v(0.2em)
          (c) Harta rezultată în urma configurației cu EKF
        ]
      ],
    )

    #v(1cm)
  ],

  caption: [
    Hărțile obținute în urma SLAM pe harta World.
  ]
)<fig:world-maps>

În cazul celei de-a doua hărți (@fig:house-maps) se observă că diferențele între numărul de colțuri și proporția de celule ocupate sunt neglijabile.
Diferența majoră între rezultate este numărul de spații închise.
Acestea sunt rezultate în urma artefactelor produse între ziduri, ceea ce duce la crearea unor spații închise de mici dimensiuni.

Acest lucru sugerează din nou o instabilitate a poziției estimate în cadrul primei configurări, care duce la acele artefacte în jurul pereților.
Însă cea mai mare problemă cu rezultatele obținute în cadrul acestei traiectorii este, fără îndoială, distorsiunea clară prezentă în partea de jos a hărții.
Aceasta este prezentă în ambele configurații, însă este mult mai pronunțată, în cazul primei configurări.
În cazul primei, se observă cum peretele ultimei camere este deplasat și nu se suprapune cu linia trasă din exteriorul casei, din zona de unde a început traiectoria robotului.
Astfel rezultă și un nou spațiu închis care nu ar fi trebuit să fie prezent în mod normal.
Se observă mai multe artefacte în jurul intrării camerei de jos față de varianta cu EKF.
În schimb, varianta cu EKF a produs niște celule ocupate care nu se află în realitate, cel mai probabil rămase de dinainte ca orientarea robotului să fie supracompensată din cauza driftului, ceea ce a dus la distorsiunea prezentă.

#figure(
  [
    #align(center)[
      #rotate(0deg)[
        #image("../figures/house.png", height: 6cm)
      ]
      #v(0.2em)
      (a) Harta House privită de sus
    ]

    #grid(
      columns: 2,
      gutter: 0.7cm,

      [
        #align(center)[
          #rotate(-90deg, reflow: true)[
            #image("../figures/tbe_house_no_ekf_1.png", height: 4cm)
          ]
          #v(0.2em)
          (b) Harta rezultată în urma configurației fără EKF
        ]
      ],

      [
        #align(center)[
          #rotate(-90deg, reflow: true)[
            #image("../figures/tbe_house_ekf_1.png", height: 4cm)
          ]
          #v(0.2em)
          (c) Harta rezultată în urma configurației cu EKF
        ]
      ],
    )

    #v(1cm)
  ],

  caption: [
    Hărțile obținute în urma SLAM pe harta House.
  ]
)<fig:house-maps>

Nu în ultimul rând, pentru ultima hartă analizată (@fig:amazon-maps) se observă o diferență semnificativă cu privire la numărul de colțuri între cele două variante.
Într-adevăr, se observă vizual faptul că pereții par să fie reprezentați mai groși în prima configurație, ceea ce ar explica apariția unor mai multe colțuri.

O altă problemă, deși de data aceasta mai subtilă, este reprezentată de o distorsiune a hărții, în partea stângă a acesteia.
Varianta cu EKF reușește să producă o hartă care ilustrează mai bine mediul înconjurător în acest caz.

Per total, considerând toate rezultatele obținute, atât legate de metricile structurale, cât și cele legate de traiectoriile estimate, cât și, poate cel mai important, hărțile rezultate, se pot trage anumite concluzii unele așteptate, altele mai puțin așteptate.


#figure(
  [
    #align(center)[
      #rotate(0deg)[
        #image("../figures/amazon.png", height: 6cm)
      ]
      #v(0.2em)
      (a) Harta Amazon Small House privită de sus
    ]

    #grid(
      columns: 2,
      gutter: 0.7cm,

      [
        #align(center)[
          #rotate(-90deg, reflow: true)[
            #image("../figures/tbe_amazon_no_ekf_1.png", height: 4cm)
          ]
          #v(0.2em)
          (b) Harta rezultată în urma configurației fără EKF
        ]
      ],

      [
        #align(center)[
          #rotate(-90deg, reflow: true)[
            #image("../figures/tbe_amazon_ekf_1.png", height: 4cm)
          ]
          #v(0.2em)
          (c) Harta rezultată în urma configurației cu EKF
        ]
      ],
    )

    #v(1cm)
  ],

  caption: [
    Hărțile obținute în urma SLAM pe harta Amazon Small House.
  ]
)<fig:amazon-maps>

În primul rând, erorile obținute, la nivel global, la momentul potrivirii traiectoriei estimate cu cea reală sunt semnificativ de mici: între 1.7-1.9 cm pentru o traiectorie de 26 m, 10-14 cm pentru o traiectorie de 87 m și 4.2-5.4 cm la o traiectorie de 108m.
Aceste rezultate sunt impresionante, indicând o ameliorare bună a drift-ului.
Erorile locale sunt între 2 și 5 cm indiferent de traiectorie și configurație, ceea ce înseamnă erori de sub 0.1%.

Totuși un efect neașteptat este faptul că introducerea unui nod EKF pentru estimarea poziției nu a venit cu avantaje considerabile în majoritatea cazurilor, fiind diferențe de sub un centimetru pentru majoritatea traiectoriilor testate.
Acest lucru indică faptul că componenta de scan matching are caracter dominant în cadrul sistemului.
Aceasta nu este atât de mult influențată de componenta de estimare inițială, atâta timp cât oferă o poziție stabilă de la care să plece estimarea finală.

În schimb, impactul nodului de EKF se poate vedea în caracteristicile structurale ale hărților create, mult mai mult decât în cazul traiectoriilor, care prezentau mici îmbunătățiri la nivel local și global pentru traiectorii mici și medii.
Hărțile rezultate pe de altă parte prezintă obstacole mai bine definite și cu mai puține distorsiuni ale mediului în reprezentare.