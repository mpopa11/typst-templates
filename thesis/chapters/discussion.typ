#import "../prelude.typ": *

  //  DISCUSSION CHAPTER - WRITING GUIDE (paragraph by paragraph)

  //  P1. Summary of key findings
  //       - Briefly recap the most important quantitative or qualitative outcomes
  //         of your evaluation (no new numbers, just a high-level summary).
  //       - Example (hardware):
  //             "Our evaluation showed that the posit-8 format consistently delivers
  //              the highest clock frequency and lowest LUT usage across DSP kernels,
  //              while posit-16 offers a modest accuracy improvement with a small
  //              area overhead."
  //       - Example (software):
  //             "The software evaluation revealed that posit-16 provides the best
  //              balance of numerical error, runtime, and energy consumption for
  //              the climate-advection and n-body kernels, whereas the unum-like
  //              format excels for the LU-decomposition kernel where dynamic range
  //              is critical."

  //  P2. Interpretation of results
  //       - Explain why you observed those outcomes, linking them to the underlying
  //         characteristics of the number representations (precision, range,
  //         encoding efficiency, etc.).
  //       - Example (hardware):
  //             "Posit-8's tapered accuracy and compact encoding reduce the amount
  //              of logic needed for arithmetic, whereas posit-16's larger fraction
  //              gives an extra bit of precision without a proportional increase
  //              in routing complexity."
  //       - Example (software):
  //             "Posit-16's use-of-regime encoding yields efficient representation
  //              of numbers near unity, which are common in scientific kernels,
  //              while the unum-like format's variable-size exponent avoids
  //              overflow/underflow in the LU decomposition's large intermediate
  //              values."

  //  P3. Comparison with existing work
  //       - Relate your findings to the related work discussed in the background
  //         chapter: do you confirm, extend, or contradict previous claims?
  //       - Example (hardware):
  //             "These results agree with earlier FloPoCo studies that posit-8
  //              achieves lower area than IEEE-754 for low-precision DSP[web:119],
  //              and they extend the observation to a broader set of kernels and
  //              to the posit-16 format."
  //       - Example (software):
  //             "Our findings corroborate recent HPC work that posit-based
  //              arithmetic can reduce time-to-solution in turbulent-flow
  //              simulations[web:121], and they add the insight that a CI-integrated
  //              library makes such experiments repeatable across large teams."

  //  P4. Implications for the domain
  //       - Discuss how the results affect practitioners or researchers in your
  //         broader domain (e.g., hardware designers, scientific-computing teams).
  //       - Example (hardware):
  //             "For hardware accelerators, the data suggest that posit-8 should be
  //              the default choice for throughput-oriented DSP blocks, while
  //              posit-16 is worth considering when a few extra LUTs are available
  //              and higher fidelity is needed."
  //       - Example (software):
  //             "Scientific-computing teams can now plug the number-representation
  //              library into their Jenkins pipelines and instantly see the
  //              trade-off between precision, runtime, and energy, enabling
  //              data-driven format selection for climate-modeling, n-body
  //              simulations, or linear-algebra workloads."

  //  P5. Limitations
  //       - Identify any threats to validity, assumptions, or constraints that
  //         could affect the generalizability of your results.
  //       - Example (hardware):
  //             "Our synthesis targets a single Artix-7 FPGA; results may differ on
  //              newer Ultrascale+ or ASIC technologies. The power numbers are
  //              estimates from XPE, not measured on silicon."
  //       - Example (software):
  //             "Benchmark kernels are synthetic proxies; real scientific
  //              applications may involve different memory access patterns or
  //              mixed-precision workflows that could shift the trade-offs."

  //  P6. Future work
  //       - Propose concrete, feasible extensions that build on your thesis
  //         (e.g., new formats, larger benchmarks, hardware-software co-design).
  //       - Example (hardware):
  //             "Future work could integrate the library into a full SoC with a
  //              RISC-V core, explore posit-32 for higher-dynamic-range kernels,
  //              and automate power measurement via on-chip sensors."
  //       - Example (software):
  //             "Future work could add support for stochastic rounding, extend the
  //              benchmark suite to include machine-learning inference kernels,
  //              and provide a GitHub Action template for broader CI adoption."

Soluția dezvoltată a înregistrat performanțe bune atât din punct de vedere structural cât și din perspectiva estimărilor traiectoriei.
În urma evaluării, în toate mediile de simulare, cu ambele configurări ale soluției s-au înregistrat erori reduse, atât la nivel local, între pozițiile înregistrate, valoare RMSE RPE fiind, procentual, mai mici de 0.09% pentru ambele variante ale sistemului.
Din punct de vedere global, potrivirea între traiectoriile estimate și referințe prezintă valori RMSE ATE mai mici de 0.1%.
Analizând hărțile obținute se poate afirma faptul că ambele variante produc hărți corespunzătoare ale mediului în care se află robotul.

Cel mai surprinzător rezultat este legat de impactul relativ scăzut pe care l-a avut componenta de EKF în performanța sistemului, cu referire la impactul asupra erorilor traiectoriilor estimate.
În schimb, impactul este vizibil când se analizează hărțile rezultate și metricile structurale.
Hărțile care folosesc o primă estimare realizată de EKF au pereți mai drepți, mai bine definiți.
Nu apar distorsiuni la fel de pronunțate precum în cazul variantei mai simple, care se bazează direct pe datele primite de la senzorii robotului.

Rezultatele au fost, bineînțeles, afectate de caracteristicile traiectoriilor și ale mediului în sine.
Lungimea unei traiectorii va influența negativ acuratețea din moment ce drift-ul acumulat de la măsurători se va aduna și în timp va afecta negativ performanța algoritmului.
Această creștere a erorii este evidentă privind datele din @tbl:ate și @tbl:rpe, cu toate că este mai puțin pronunțată în cadrul local de la poziție la poziție.
Se observă totuși în ambele cazuri un comportament la prima vedere ciudat pentru cea de-a doua traiectorie, ambele erori cresc ca valori semnificativ.

Rotațiile sunt mult mai periculoase pentru acuratețea sistemului față de translațiile normale.
Acest lucru se datorează faptului că o eroare oricât de mică duce la distorsiuni foarte mari cu cât crește distanța.
Acest lucru este exacerbat dacă rotațiile se petrec cu o viteză unghiulară mai mare.
Specific soluției prezentate, rotațiile pure nu oferă foarte multe informații cu privire la translație.
Astfel in urma scan matching-ului apar nealinieri care produc rezultate greșite, fie cu privire la orientare sau poate chiar la poziție. 
Acest aspect a dus și la defectele prezentate de hărțile celui de-al doilea mediu.
Adaugarea unui EKF pare să fi ameliorat această problemă, dând o primă estimare mult mai adecvată și robustă față de datele brute.

Cea mai mare limitare a sistemului este legată de lipsa unui back end care să permită și corecția traiectoriei din trecut.
Decizia de a exclude aceasta componentă de detecție a buclelor și de optimizarea grafurilor a fost luată pentru a aduce o soluție care prezintă o complexitate mai mică, pentru a putea fi rulată pe mai multe sisteme.
Bineînțeles, această decizie a dus inevitabil la imposibilitatea de a corecta traiectoria pe parcursul explorării, deși abordarea de scan-to-map matching ajută la ameliorarea efectului.

Alte limitări vizează mediul de testare din simulator.
Un prim factor este reprezentat de faptul că hărțile nu au foarte multe zone care să nu aibă mult spațiu gol, în care robotul să nu poată să preia informații prin senzorul de LiDAR, ceea ce nu a testat suficient cazurile în care etapa de scan matching nu convergea, moment în care poziția estimată primea valoarea primei estimări.
De asemenea, fiind vorba de un mediu simulat, senzorii nu prezentau un zgomot foarte realist pentru a putea analiza comportamentul într-o manieră mai apropiată de condițiile reale de funcționare.

Pe viitor, o direcție firească de îmbunătățire a soluției este adăugarea unei modalități de detectare a buclelor și închiderea acestora.
Această modificare va ajuta la estimarea mai bună a traiectoriei, mai ales pe termen lung, când acumularea drift-ului devine o problemă extraordinar de serioasă, care altfel aduce probleme semnificative soluției actuale.
Această modificare va presupune o nevoie de mai multă putere de calcul și mult mai multă memorie pentru a putea rula o metodă care integrează pe lângă soluția deja prezentată și o componentă de optimizarea grafurilor.
Din această cauză, optimizarea soluției actuale este, de asemenea, o altă direcție de dezvoltare.
O posibilă problemă viitoare este reprezentată de faptul că soluția bazată pe simpla aplicare a algoritmului lui Bresenham pentru trasarea liniilor libere nu este cea mai eficientă când vorbim despre o variantă care necesită mai multă putere de calcul.
Aceasta poate fi înlocuită sau măcar calculul poate fi vectorizat pentru a eficientiza această etapă și de a nu crea blocaje în sistem.
De asemenea, în cazul în care se implementează o componentă de detecție și închidere a buclelor, va trebui analizat impactul real al celor 2 treceri prin scan-matching pentru a corecta și reduce distorsiunile provenite de la senzorul de LiDAR.
Această componentă poate deveni redundantă într-un astfel de sistem și este posibil să reprezinte o execuție în plus care doar consumă resurse fără un câștig prea mare.

Altă direcție care poate fi explorată este paralelizarea unor componente, pentru obținerea unor performanțe mai bune in timp real. 
În acest fel, soluția va răspunde mai bine la medii mai mari, cu mai multe trăsături și traiectorii complexe.
Componenta de scan matching este potrivită pentru paralelizare, fiind relativ izolată de celelalte componente și in aceasta nu se riscă apariția unor probleme de sincronizare care să duca la rezultate eronate.