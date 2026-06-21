#import "../prelude.typ": *

//    CONCLUSIONS CHAPTER - WRITING GUIDE (paragraph by paragraph)

//    P1. Problem & solution recap
//         - Briefly restate the original problem and your solution in one or two sentences.
//         - Example (hardware):
//               "We addressed the lack of a unified hardware library for comparing multiple number representations by delivering a parameterizable Chisel library with a shared test-and-benchmark framework."
//         - Example (software):
//               "We solved the missing reproducible evaluation of diverse number representations in scientific-computing projects by providing a Scala-based library integrated into a Jenkins CI pipeline."

//    P2. Key results summary
//         - Highlight the 2-4 most important quantitative or qualitative outcomes of your evaluation
//           (no new details, just the take-away numbers).
//         - Example (hardware):
//               "Posit-8 gave the highest Fmax and lowest LUT usage across DSP kernels; posit-16 offered a noticeable accuracy gain with < 10 % area overhead."
//         - Example (software):
//               "Posit-16 yielded the best balance of error, runtime, and energy for climate-advection and n-body kernels; the unum-like format excelled for LU decomposition where dynamic range is critical."

//    P3. Comparison with existing work
//         - Explain how your results and approach improve upon or differ from the related work discussed
//           in the background chapter.
//         - Example (hardware):
//               "Unlike FloPoCo, which focuses mainly on IEEE-754 formats, our library supports posit and
//                unum-like formats and provides a common benchmark suite for fair cross-format comparison."
//         - Example (software):
//               "Compared to general-purpose libraries such as NumPy, our solution adds automated testing,
//                CI integration, and a ready-made benchmark suite, enabling rapid experimentation in large teams."

//    P4. Limitations
//         - Acknowledge any threats to validity, assumptions, or constraints that affect the
//           generalizability of your findings.
//         - Example (hardware):
//               "Results are based on synthesis for a single Artix-7 FPGA; power numbers are estimates
//                from XPE, not silicon measurements."
//         - Example (software):
//               "Benchmarks use synthetic kernels; real scientific applications may involve different I/O
//                patterns or mixed-precision workflows that could shift the trade-offs."

//    P5. Future work
//         - Propose concrete, feasible extensions that build directly on your thesis (keep this list
//           shorter than the conclusions).
//         - Example (hardware):
//               "Future work could integrate the library into a full SoC with a RISC-V core, explore
//                posit-32 for higher-dynamic-range kernels, and automate on-chip power measurement."
//         - Example (software):
//               "Future work could add stochastic-rounding support, extend the benchmark suite to include
//                machine-learning inference kernels, and provide a GitHub-Action template for broader CI adoption."

//    P6. Closing take-away
//         - End with one memorable sentence that captures the core contribution and its impact.
//         - Example (hardware):
//               "This work gives hardware designers a practical, reproducible way to select the most
//                efficient number representation for their accelerators."
//         - Example (software):
//               "This work equips scientific-computing teams with a CI-friendly toolbox to experiment
//                with and quantify the impact of alternative number representations on correctness and cost."

În concluzie, a fost abordată problema localizării și cartografierii mediului înconjurător pentru un robot care operează în spații închise.
În scopul acesta a fost dezvoltată o soluție de SLAM bidimensional, bazată pe principiul de scan matching implementat în Python folosind ROS 2.
Sistemul utilizează măsurători provenite de la senzorii odometrici ai roților robotului, unitatea inerțială a acestuia și de la un senzor de LiDAR.
Soluția dezvoltată se bazează pe o arhitectură ce conține doar componenta de front-end a unui sistem de SLAM, nedispunând de o componentă de detectare și închidere a buclelor.
S-a integrat, de asemenea, o componentă de filtrare pe baza unui EKF, pentru estimarea poziției.

Pe parcursul implementării au fost întâlnite mai multe probleme asociate tematicii.
Începând cu apariția drift-ului datorat estimării de tip dead-reckoning care provoca acumularea erorilor, la cele legate de abordarea în cadrul componentei de scan matching și găsirea unui algoritm care să permită obținerea rezultatelor dorite, până la cele legate de integrarea unui EKF și cele aduse de distorsiunile provocate de mișcarea robotului.

Comparând cu alte sisteme consacrate, de diferite tipuri, soluția vine cu anumite avantaje dar și dezavantaje.
Față de o soluție precum HectorSLAM, soluția propusă folosește mai mulți senzori și nu se bazează exclusiv pe scan matching.
Cel mai mare avantaj față de soluțiile bazate pe optimizarea grafurilor precum Cartographer și SLAM Toolbox sau cele bazate pe filtre probabilistice precum Gmapping, este reprezentat de complexitatea mai scăzută a algoritmului.
Pe de altă parte, față de soluțiile bazate pe optimizarea grafurilor, apare un dezavantaj clar reprezentat de lipsa unei componente de închiderea buclelor, care face imposibilă reglarea traiectoriei până la momentul în care se detectează o buclă pentru o robustețe pe termen lung și rezultate mai bune în cazul traiectoriilor mai lungi, unde prezența erorilor se acumulează semnificativ.

Cât despre rezultate, s-au înregistrat bune performanțe pentru ambele configurări ale sistemului testate, cu sau fără estimarea poziției bazată pe EKF.
Astfel s-au înregistrat erori mai mici de 0.1 % între traiectoriile globale și erori sub 0.09% la nivel local între poziții succesive.
Hărțile obținute au demonstrat o calitate bună a reprezentării mediului înconjurător, menținând caracteristicile acestuia și păstrând o consistență structurală adecvată.

Efectul obținut de adăugarea unui nod de EKF pentru a estima o primă poziție nu a avut efecte consistente de la care să se poată trage concluzii clare cu privire la calitatea traiectoriilor estimate; în schimb, a avut efect la nivelul hărților rezultate, acestea fiind mai solide structural și reducând distorsiunile cauzate de rotațiile excesive ale robotului.

Ca direcții viitoare de dezvoltare, se poate viza implementarea unei componente de detectare a buclelor și închiderea acestora pentru a putea corecta traiectoria retrospectiv.
Acest aspect presupune o complexitate de calcul mai ridicată, ceea ce deschide discuția cu privire la importanța unor decizii de implementare care își pot pierde din impact în cazul integrării unui graf de poziții în cadrul soluției.
Ar trebui analizat impactul asupra resurselor necesare în acest caz pentru a putea stabili dacă este o decizie bună menținerea celor două etape de scan matching și de eliminare a distorsiunii în contextul unei soluții care integrează grafurile de poziție, care sunt din start mai costisitoare.
Se poate studia și impactul pe care paralelizarea componentelor îl poate avea în cazul soluției actuale în vederea unor performanțe mai bune într-un cadru de timp real.

În concluzie, soluția propusă reprezintă o primă versiune solidă și robustă în direcția dezvoltării unei soluții de SLAM cu adevărat complete, care să răspundă nevoilor de bază de localizare și cartografiere pentru navigarea în siguranță în spații închise.