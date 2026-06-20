#import "../prelude.typ": *

//    ARCHITECTURE CHAPTER - WRITING GUIDE (paragraph by paragraph)

//    P1. Solution overview
//         - Describe the overall system you are proposing in one or two sentences.
//         - State what it does, who uses it, and where it runs.
//         - Example (hardware):
//               "We propose a parameterizable Chisel library that implements multiple number-representation formats together with a shared test-and-benchmark framework, targeting FPGA-based accelerators."
//         - Example (software):
//               "We propose a Scala-based software library integrated into a Jenkins CI pipeline that provides the same set of number representations and automatically runs correctness and performance benchmarks for scientific-computing workloads."

//    P2. Functional decomposition
//         - Break the solution into major functional blocks (black boxes).
//         - For each block, state its responsibility and what it exposes (interfaces, APIs, ports).
//         - Do NOT describe internal algorithms yet.
//         - Example (hardware):
//               "The library consists of:
//                 • Arithmetic cores (add, multiply, divide, sqrt) for each supported format;
//                 • Conversion utilities (between formats and to/from IEEE-754);
//                 • Test harness that drives the cores with stimulus vectors and checks results against a reference model;
//                 • Benchmark controller that configures the cores, collects area/frequency/power reports from synthesis tools."
//         - Example (software):
//               "The software solution comprises:
//                 • Number-representation module (immutable data classes + arithmetic ops for each format);
//                 • Test suite (unit tests using ScalaCheck / JUnit that compare results against a high-precision decimal reference);
//                 • Benchmark module (runs representative kernels, measures wall-clock time, energy via RAPL, and memory usage);
//                 • Jenkins pipeline (checks out code, builds the library, runs the test suite, executes the benchmark module, and publishes results)."

//    P3. Interfaces & communication
//         - Explain how the blocks talk to each other (buses, function calls, messages, data files, etc.) and what contracts they obey.
//         - Example (hardware):
//               "Arithmetic cores expose a parameterized Chisel interface (generic data-width, ready/valid handshake). The test harness drives each core via this interface and compares the output to a software reference model using scoreboard-style checking. The benchmark controller writes configuration registers on the cores and reads back performance counters from the synthesis tool’s reports."
//         - Example (software):
//               "The number-representation module offers a pure-functional API (methods like `add`, `mul`, `toDouble`). The test suite calls this API directly in Scala. The benchmark module invokes the same API inside the scientific kernels and logs timing/energy data. Jenkins orchestrates everything via shell steps that invoke `sbt test` and `sbt run`."

//    P4. Non-functional considerations
//         - Discuss any quality attributes you considered when designing the architecture (e.g., modularity, extensibility, resource usage, latency, fault tolerance, reproducibility).
//         - Example (hardware):
//               "Modularity lets us add a new number format by creating a new arithmetic core without touching existing ones. The design targets low latency (single-cycle where possible) and area efficiency (parameterizable width). The test harness ensures functional correctness before any synthesis, and the benchmark controller enables repeatable power/area estimation across formats."
//         - Example (software):
//               "The architecture emphasizes reproducibility (same source, same JVM, same Docker image), extensibility (new formats are added by extending the trait and adding test cases), and performance transparency (benchmark results are stored as JSON artifacts for later comparison). Fault isolation is achieved because each test runs in its own JVM process."

//    P5. Mapping to implementation & evaluation (optional, 1 paragraph)
//         - Briefly note how the architectural blocks will be realized in the implementation chapter and what experiments will validate them in the evaluation chapter.
//         - Example (hardware):
//               "In Chapter 4 we will show the Chisel code for each arithmetic core and the test-harness Scala code; in Chapter 5 we will synthesize the cores on a Xilinx Artix-7 FPGA and report area, Fmax, and power for a set of DSP kernels."
//         - Example (software):
//               "In Chapter 4 we detail the Scala implementation of the number-representation traits and the Jenkinsfile; in Chapter 5 we run the library against three scientific kernels (climate advection, n-body, dense linear algebra) and present runtime, error, and energy numbers."

//    P6. Diagram (optional)
//         - If you like, you can insert a simple block diagram here (using cetz, fletcher, or just an ASCII-art placeholder) to visualize the blocks and their interfaces.
//         - Example (hardware):
//               *[You may replace this comment with a figure generated by cetz or fletcher showing the arithmetic cores, test harness, and benchmark controller.]*
//         - Example (software):
//               *[You may replace this comment with a figure showing the Scala library, test suite, benchmark module, and Jenkins pipeline.]*
// 
== 3.1 Soluție abstractă
Este propusă o soluție de scan matching SLAM bazată pe utilizarea senzorilor de odometrie, IMU și LiDAR, destinată roboților autonomi care sunt folosiți în spații închise.
Soluția este concepută ca o aplicație distribuită în ROS 2, în care nodurile create îndeplinesc funcțiile unuia sau a mai multor module din aplicație.
Sistemul propus este unul care se bazează mult mai mult pe componenta de front-end a unui sistem SLAM, fără o componentă de graph optimization sau închiderea buclelor.
Componentele de optimizare a grafurilor și de închidere a buclelor au nevoie de resurse semnificative de procesare și de memorie, cost care crește pe măsură ce traiectoria crește și ea în lungime.
Din acest motiv, aceste elemente nu au fost incluse în soluție, pentru a putea veni cu o variantă care să nu necesite prea multe resurse de la robotul pe care va fi utilizată soluția.
Fluxul abstract al soluției este ilustrat în figura următoare:

#figure(
  image("../figures/diagrama_abstracta.png", height: 6cm), 
  caption: ["Reprezentare abstractizată a fluxului soluției de SLAM"]
) <fig1>

Principial, cu ajutorul datelor preluate de la senzorii odometrici ai roților și de la IMU se face o primă estimare cu privire la poziția robotului.
Datele de la LiDAR sunt supuse unei etape de preprocesare: eliminare a valorilor din afara gamei de măsurare și eliminarea distorsiunii provocate de către mișcarea robotului.
Se calculează coordonatele punctelor pentru a obține setul de puncte pe care se face scan matching.

Partea de scan matching este de tip scan to map matching, și astfel se obține poziția reală a robotului, pornind de la cea estimată și în continuare se poate completa harta mediului, pornind de la acea poziție.

Ulterior a fost adăugat un EKF pentru estimarea poziției, astfel încât prima predicție este cea calculată de EKF, nu cea rezultată din preluarea directă a datelor senzorilor.

#pagebreak()

== 3.2 Comunicarea între componente

Fiecare componentă este membră a unui nod din ROS 2 care implementează funcționalitățile necesare.

Astfel, în soluție există un nod imu_odom care se ocupă cu preluarea primei predicții a poziției, fie folosind direct datele preluate de la senzori, fie preluând poziția estimată de EKF, care a fost adăugat ulterior.

Adăugarea unui nod de EKF a necesitat adăugarea unui nod care să preia mesajul cu măsurătorile odometrice și să adauge covarianțele în noul mesaj care e trimis mai departe la nodul de EKF.

Apoi există nodul map_node care preia măsurătorile de la LiDAR și prima estimare a poziției, fie că este cea preluată direct din datele brute ale senzorului sau cea preluată de la nodul de EKF, care combină informațiile de la ambii senzori, odometrici și IMU.
În cadrul acestui nod, se realizează prelucrarea datelor de la LiDAR, eliminarea valorilor din afara marjei de funcționare, după care se elimină efectul mișcării robotului.
În acest moment poate fi creat noul set de puncte care reprezintă ultima măsurătoare a LiDAR-ului, adus în sistemul de referință global.

Harta este stocată sub formă de occupancy grid pe tot parcursul funcționării și din aceasta se pot extrage punctele ocupate pentru a se face scan matching între hartă și măsurătoare.
Astfel rezultă noua poziție, în relație cu care se modifică harta din occupancy grid.

Pentru evaluare există un nod, metrics care păstrează harta transmisă de map_node până în momentul în care nu se mai publică o nouă hartă, când se calculează metricile discutate anterior.
Tot pentru evaluare, a fost adăugat și nodul ground_truth care are rolul de a selecta transformările care au legătură cu robotul din toate transformările publicate de către simulator și republică această transformare pentru a fi vizibilă sistemului și pentru a putea fi înregistrată pentru compararea ulterioară cu poziția estimată.

Cu privire la comunicare, aceasta este bazată pe topic-uri, nodurile având rolul de abonat și distribuitor.
Comunicația între componente este ilustrată în @fig2.
În aceasta nodurile sunt ovalurile și dreptunghiurile reprezintă topic-urile.

În consecință, topic-ul /odom preia datele de la senzorii odometrici ai roților robotului și trimite un mesaj standard de tip nav_msgs/Odometry care conține un câmp de tip Pose, de poziție și Twist, de viteză.
Câmpul de poziție conține datele cu privire la translația, orientarea, oferită sub formă de quaternioni, și matricea de covarianță aferentă senzorului.
Similar câmpul Twist conține informații cu privire la vitezele unghiulare și liniare, precum și covarianțele.
Nodul odom_cov preia datele de la /odom și le adaugă componenta de covarianță cu valori realiste.

Topic-ul /imu transmite datele obținute de la unitatea inerțială care conține orientarea sub formă de quaternioni, viteza unghiulară și accelerația liniară.

Acestea sunt folosite de nodul de EKF /ekf_filter_node, care apoi transmite pe topic-ul /odometry/filtered prima estimare a poziției, tot sub formă de mesaj nav_msgs/Odometry.
Aceasta este preluată de alt nod, /imu_odom care trimite un mesaj simplu care conține poziția și orientarea, yaw, pe topic-ul /robot_data.

De la /scan se preiau datele de LiDAR oferite sub forma unui mesaj de tip sensor_msgs/LaserScan, din care, de interes sunt câmpurile de ranges, care  mențin un șir al distanțelor reperate, precum și limitele de detecție ale senzorului, incrementele de unghi și timp.

#figure(
  image("../figures/communications.png", height: 14cm),
  caption: ["Fluxul de comunicație al sistemului"]
) <fig2>

În urma scan-matching-ului din interiorul nodului /map_node, se calculează estimarea finală a poziției care e publicată pe topic-ul /slam_pose, transformarea între odom și map conform @eq:map-odom este publicată pe /tf, care conține toate transformările din lume, și în ultimul rând, pe topic-ul /map este publicată harta sub formă de occupancy grid.

Nodul care calculează metricile este metrics, iar acesta este abonat la topic-ul /map pentru a-și actualiza harta, până când poate calcula metricile stabilite, în momentul în care cartografierea se oprește.

Nu în ultimul rând, nodul /ground_truth preia poziția reală conform simulatorului și o publică mai departe sub forma unui mesaj de tip nav_msgs/Odometry.

Acest stil de dezvoltare impus de un sistem bazat pe ROS 2 duce la soluții modulare care pot fi modificate fără prea multe alte intervenții, în care nodurile pot fi înlocuite.
Din această cauză, a fost creată și o versiune care are scopul de a analiza impactul estimării produse de către nodul EKF, comparativ cu datele brute obținute direct de la senzori.

În capitolul următor va fi detaliat procesul de implementare și comportamentul detaliat al fiecărei componente prezentate anterior, pornind de la procesarea datelor, componenta de scan matching și actualizarea hărții.
Pe lângă implementarea propriu zisă vor fi explicate problemele întâlnite pe parcurs, precum și soluțiile și compromisurile care au fost luate pe parcursul dezvoltării soluției.