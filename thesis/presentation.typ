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

- Navigatie autonoma, indiferent de scop.

- Unde se află robotul? Cum cunoaște mediul?

#speaker-note[
  De-a lungul timpului, tendința dominantă a fost mereu cea de automatizarea a activităților omului. În acest context, au fost dezvoltate diferite metode pentru a putea ușura munca omului, ajungând, în cele din urmă la dezolvoltarea sistemelor automate clasice. Spre deosebire de acestea, se remarcă roboții autonomi, care trebuie să fie capabili să ia decizii în baza informațiilor din mediu de unii singuri, fără intervenția operatorului uman. Indiferent de sarcina lor, aceștia trebuie să poată naviga în siguranță în mediul în care se află. Astfel se remarcă necesitatea ca robotul mobil autonom să cunoască mediul înconjurător și să se poată plasa în acesta.

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
  
]

== #slide-title("Importanța problemei", "Why Is This Important?")

- Hartă fidelă $+$ localizare precisă $arrow.r.double$ #text(weight: "bold", fill: rgb("#1f6feb"))[navigație în siguranță]

- Gmapping. 

- HectorSLAM.

- Cartographer. 

- SLAM Toolbox.

#speaker-note[
  This problem is important to solve because secure communication and data protection are critical in today's digital world, and efficient hardware accelerators can enable faster and more secure with higher throughput applications. Some hardware accelerators exist, but they are often proprietary, expensive, or not optimized for RISC-V. Solving this problem can have a significant impact on the performance and security of applications that rely on cryptographic functions, as well as on the adoption of RISC-V.
]

// ------------------------------------------------------------
//  Proposed Solution & Architecture
// ------------------------------------------------------------

= #slide-title("Soluția propusă", "Proposed Solution")

== #slide-title("Prezentare generală a soluției", "Solution Overview")

- SLAM bidemensional bazat pe *scan-matching*.

- LiDAR $+$ odometria roților $+$ IMU.

- Fără închiderea buclelor.

- Reprezentarea mediului sub formă de *occupancy grid*


#speaker-note[
  The proposed solution is a novel hardware accelerator design for symmetric cryptographic functions on RISC-V. The key components of the solution include a custom instruction set extension for cryptographic functions, a hardware module for accelerating specific functions, and a software library for interfacing with the hardware. The main goal of the solution is to achieve high performance, low latency, low power consumption, and security against side-channel attacks.
]

== #slide-title("Arhitectura sistemului", "System Architecture")

- Sistem distribuit dezvoltat în *ROS2*

- Comunicare prin *topic-uri* (model publisher-subscriber).

- Estimarea inițială a poziției (*date brute* sau *EKF*)

- Preprocesare măsurători LiDAR

- Scan-matching.

- Actualizare hartă.

#speaker-note[
  The architecture of the proposed solution consists of RISC-V Rocket CPU with a custom instruction set extension for cryptographic functions, a hardware module that implements the specific functions, and a software library that provides an API for applications to use the hardware accelerator. The C++ software library uses RoCC assembly inline instuction and compare it with the software implementation of the same functions. The two-approach are tested on the same hardware platform emulated thourgh Verilator and using Proxy kernel.
  ...
]

#slide(config: config-store(header: none))[
  #figure(
    image("figures/diagrama_abstracta.png", height: 10cm),
    caption: [Fluxul abstract al soluției de SLAM],
  )

  #speaker-note[
    The architecture of the proposed solution consists of RISC-V Rocket CPU with a custom instruction set extension for cryptographic functions, a hardware module that implements the specific functions, and a software library that provides an API for applications to use the hardware accelerator. The C++ software library uses RoCC assembly inline instuction and compare it with the software implementation of the same functions. The two-approach are tested on the same hardware platform emulated thourgh Verilator and using Proxy kernel.
    ...
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

- Scan-matching : *GICP*  $arrow$ #text(weight: "bold", fill: rgb("#1f6feb"))[small_gicp].

- EKF: *robot_localization*.

- Hartă: *occupancy grid* rezoluție de 0.05.

- Eliminarea distorsiuniilor LiDAR: interpolare liniară $+$ două etape de scan-matching.


#speaker-note[
  The main implementation decisions I made include choosing RISC-V as the target architecture for the hardware accelerator, using Chisel as the hardware description language, and implementing the software library in C++. I chose RISC-V because it is an open and flexible architecture that allows for custom extensions. I chose Chisel because it is a powerful and expressive language for hardware design that integrates well with the RISC-V ecosystem (Rocket Chip + Chipyard). I implemented the software library in C++ because it is a widely used language for performance-critical applications and has good support for interfacing with hardware.
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
  The evaluation was conducted on a RISC-V Rocket CPU with the custom hardware accelerator implemented in Chisel. The software library was tested on the same hardware platform emulated through Verilator and using Proxy kernel. The benchmarks used for testing include a set of symmetric cryptographic functions and hash functions, such as AES and SHA-256, which were selected based on their relevance and common use in secure applications. The methodology for testing involved running each benchmark 1000 times under controlled conditions to ensure consistency and reliability of the results. The metrics used for evaluation include throughput (requests per second), latency (milliseconds), and resource utilization (CPU usage).
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
  The main experimental results show that the proposed hardware accelerator achieves a significant improvement in latency and throughput compared to the software implementation. For example, in Scenario 1, the latency was reduced from TODO ms to TODO ms, which is a TODO% improvement. In Scenario 2, the throughput increased from TODO req/s to TODO req/s, which is a TODO% improvement. These results are consistent with our expectations based on the design of the hardware accelerator and demonstrate the effectiveness of our solution.
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
  In addition to the quantitative results, we also conducted a qualitative evaluation through a case study of how easy it is to integrate the proposed hardware accelerator into existing applications. The case study involved working with developers to understand their experiences and challenges when adopting the new technology. The insights gained from this evaluation include feedback on the integration process, performance improvements observed in real-world scenarios, and suggestions for further enhancements. These insights complement the quantitative results by providing a more holistic view of the solution's impact. ...
  For other subjects, we could have conducted user studies or interviews to gather qualitative feedback on the usability and effectiveness of the solution on X people. The main results are ...
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

== #slide-title("Hărți rezultate — House", "Resulting Maps — House")
#map-slide(
  "figures/tbe_house_no_ekf_1.png",
  "figures/tbe_house_ekf_1.png",
)

== #slide-title("Hărți rezultate — Amazon", "Resulting Maps — Amazon")
#map-slide(
  "figures/tbe_amazon_no_ekf_1.png",
  "figures/tbe_amazon_ekf_1.png",
)

// ------------------------------------------------------------
//  Conclusions and Key Results
// ------------------------------------------------------------

= #slide-title("Concluzii", "Conclusions")

== #slide-title("Concluzii", "Conclusions")

- Sistem SLAM bidemensional bazat pe scan matching.

- Integrare EKF pentru predicția inițială.

- Erori < 0.1% din lungimea traiectoriei.

- Hărți fidele.

- Impact EKF scăzut la estimarea traiectoriei.

- Impact EKF vizibil la calitatea structurală a hărților.

#speaker-note[
  In conclusion, this thesis presents a novel hardware accelerator design for symmetric cryptographic functions on RISC-V, which achieves significant improvements in performance and security compared to existing solutions. The key contributions include the design of a custom instruction set extension, the implementation of a hardware module for accelerating specific functions, and the development of a software library for interfacing with the hardware. The results demonstrate that our solution can significantly enhance the performance of cryptographic applications while maintaining security against side-channel attacks, thus advancing the state of the art in hardware accelerators for RISC-V.
]

== #slide-title("Lucrări viitoare", "Future Work")

- Componentă de închiderea buclelor.

- Paralelizarea componentelor.

- Optimizarea în continuare a procesului.

#speaker-note[
  While this thesis makes significant contributions to the design of hardware accelerators for symmetric cryptographic functions on RISC-V, there are some limitations that can be addressed in future work. For example, the current implementation focuses on a specific set of cryptographic functions, and future research could explore extending the accelerator to support a wider range of functions or algorithms. Additionally, further optimization techniques could be investigated to enhance performance and reduce power consumption even further. 
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
  - Etapa 2 : corespondență max. 0.1 m, max. 10 iterații; respins dacă $Delta_"translație"$ > > 0.1 m sau $Delta_"unghi"$ > ~3°.
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

