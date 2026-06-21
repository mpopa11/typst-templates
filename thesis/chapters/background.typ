#import "../prelude.typ": *

//    BACKGROUND / THEORETICAL FOUNDATION – WRITING GUIDE (paragraph by paragraph)

//    P1. Domain
//         - Describe the broad field of the thesis, why it matters,
//           and which aspects are important.
//         - Example (hardware): "Computer architecture is the foundation of all computing systems; advances in arithmetic units directly affect the performance, energy efficiency, and applicability of modern accelerators."
//         - Example (software): "Scientific computing underpins discoveries in physics, chemistry, climate modelling, and engineering; the fidelity and cost of numerical simulations determine how quickly science can progress."

//    P2. Context
//         - Zoom in on the specific setting where the problem appears and explain its relevance to the broader domain.
//         - Example (hardware): "Within computer architecture, the choice of number representation (fixed-point, floating-point, posit, etc.) determines the trade-off between accuracy, silicon area, and power consumption in hardware accelerators."
//         - Example (software): "In scientific-computing workflows, number-representation libraries are called repeatedly inside kernels; their precision and runtime influence the overall reliability and turnaround time of large simulations."

//    P3. Problem and Motivation
//         - State clearly the gap or deficiency that motivates your work and why solving it is important.
//         - Example (hardware):
//               "There is currently no unified hardware library that offers multiple number representations together with a common benchmark suite, making fair comparison and reuse across projects difficult."
//               "This gap forces designers to re-implement basic operators for each format, increasing development time and hindering reproducible evaluation."
//         - Example (software):
//               "Existing software libraries provide many number formats but lack integrated automated testing and continuous-integration support, which hinders reproducible evaluation in large scientific-computing projects."
//               "Consequently, developers must manually run correctness and benchmark tests, slowing down experimentation and increasing the risk of inconsistent results."

//    P4. Related Work
//         - Discuss existing solutions (libraries, tools, architectures) and point out their limitations with respect to your goal.
//         - Example hardware paragraph 1:
//               "FloPoCo provides a rich set of floating-point cores but focuses mainly on IEEE-754 and related formats, offering limited support for posit or unum."
//         - Example hardware paragraph 2:
//               "Several open-source Chisel libraries implement individual formats (e.g., a fixed-point package) but they do not share a common test harness, making cross-format benchmarking ad-hoc."
//         - Example hardware paragraph 3:
//               "Recent proposals for programmable arithmetic units (e.g., POSH) demonstrate flexibility but lack a standardized evaluation framework."
//         - Example software paragraph 1:
//               "General-purpose libraries such as NumPy (Python) and the Julia standard library supply many number formats, yet they are not coupled to automated CI pipelines, so developers must run correctness and benchmark tests manually."
//         - Example software paragraph 2:
//               "Some research prototypes (e.g., a posit package for Julia) provide the arithmetic but lack integration with build systems like Jenkins, which limits their usability in large, collaborative scientific-computing projects."
//         - Example software paragraph 3:
//               "Workflow tools like GitHub Actions or GitLab CI can run tests, but they do not provide a ready-made library of number representations for direct reuse."

//    P5. Research Question / Goal
//         - State the main question or engineering goal that your thesis will answer.
//         - Example (hardware):
//               "Which number-representation format(s) give the best trade-off between accuracy, area, and power for a given class of accelerator kernels?"
//         - Example (software):
//               "How can we provide a reusable, CI-integrated software library that lets scientific-computing teams evaluate and compare diverse number representations with minimal manual effort?"

//    P6. Thesis Contributions
//         - Summarize the main contributions of the thesis in prose (2-4 items).
//         - Example (hardware):
//               "The thesis contributes: (i) a reusable Chisel number-representation library; (ii) a common benchmark framework for fair cross-format comparison; (iii) quantitative evaluation of format trade-offs on FPGA targets; and (iv) guidance for hardware designers on selecting formats for accelerator design."
//         - Example (software):
//               "The thesis contributes: (i) a Scala software library with multiple number representations; (ii) a Jenkins-based CI workflow that automates testing and benchmarking; (iii) empirical results showing accuracy-runtime-energy trade-offs for scientific kernels; and (iv) a reusable template for integrating numerical experiments into CI pipelines."

//    Replace each block below (the text between _[ and ]_) with your own paragraph(s) following the order above.

// În contextul în care automatizarea reprezintă tendința dominantă a ultimilor ani, integrarea roboților autonomi devine o nevoie din ce în ce mai mare pentru diferite zone de activitate atât în industrie cât și în viața de zi cu zi a oamenilor. Astfel, oamenii se comfrontă cu tot felul de roboți de acest tip din ce în ce mai mult
== 2.1 Context
Un robot autonom reprezintă un sistem capabil să ia decizii, pe baza observațiilor din mediul în care se află în vederea îndeplinirii unor sarcini.
Față de sistemele autonome clasice, care execută sarcini stabilite încă din faza de proiectare, roboții autonomi trebuie să fie capabili să ia decizii singuri, în baza observațiilor din mediu.
În acest context, se remarcă roboții mobili care reprezintă obiectul acestei lucrări, apare și problematica unui mediu care nu este fix. 
Robotul se deplasează, observă noi caracteristici pe care trebuie să le gestioneze pentru a putea realiza sarcina cu succes.

Din această cauză, este necesar ca robotul să își cunoască atât mediul inconjurător, dar și unde se află în acesta.
Cunoașterea acestor două elemente este fundamentală pentru sarcina de bază a unui astfel de robot: navigația.
Robotul, indiferent de scopul său principal, fie că vorbim de roboți destinați sarcinilor industriale (roboți de sortare, transpalete automate), agriculturale sau de uz casnic sau comercial (roboți de curățenie, de livrare), trebuie să poată naviga eficient și în siguranță prin mediul în care se află.
Acest lucru presupune, de obicei, crearea unei hărți a mediului inconjurător, care ulterior poate fi folosită pentru a naviga.

Aceasta poartă numele, în literatura de specialitate, de Simultaneous Localization and Mapping (SLAM).
Prin localizare se întelege estimarea poziției și a orientării într-un sistem de referință.
Localizarea se poate realiza cu ajutorul a mai multor senzori fie cei interni (odometrici, inerțiali), care măsoară starea internă a robotului și cei externi (LiDAR, camere). 

Poate fi totuși puțin contraintuitiv faptul că senzorii GPS nu sunt la fel de folosiți ca cei enumerați mai sus. Deși aceștia aduc avantaje clare, în special în legătură cu ușurința de utilizare, precizia acestor senzori lasă de dorit pentru acest caz de utilizare. 
În plus, senzorii GPS sunt foarte sensibili la mediul înconjurător, astfel și în cele mai bune condiții senzorii GPS tot au erori de până la câțiva metri. Astfel, aceștia sunt folosiți în combinație cu senzorii menționați anterior.
Prin mapare se întelege construirea unei reprezentări a mediului în care se află robotul care va putea fi ulterior folosită și la localizare cât și la navigație, planificarea rutelor.

Astfel, apar sistemele SLAM, care indiferent de modul în care sunt proiectate, răspund inevitabil la aceleași două probleme: localizare și mapare.
Uzual, sistemele SLAM au o arhitectură împărțită în două module importante: un front-end și un back-end. @sh-p1-prelude
Modulul de front-end poate fi considerat ca fiind modulul de procesare și, de multe ori, oferă o prima estimare a poziției. 
Procesează fluxul de date de la senzori (inerțiali, odometrici, LiDAR, camere, Radar) și produce reprezentări care sunt mai ușor de gestionat.
Realizează extragerea caracteristicilor din mediu și de asemenea preprocesează datele obținute de la senzori.
Deseori, în cadrul acestui modul se incorporează componenta de detectare a buclelor, care apar în momentul în care robotul, în urma traiectoriei sale, ajunge într-un punct care a fost deja vizitat precedent. @sh-p1-prelude 

Modulul de back-end preia datele de la front-end și are sarcina de a calcula traiectoria robotului și să construiască harta, luând în calcul constrângerile trimise de către front-end.

Sistemele SLAM se pot clasifica după mai multe criterii: după dimensionalitatea mediului avem de a face cu SLAM 2D sau SLAM 3D. 
Practic, modul de reprezentare a mediului se realizează în funcție de caz, bidimensional sau tridimensional.
În cazul reprezentărilor 2D, acestea vin cu diferite avantaje precum eficiența din punct de vedere a resurselor utilizate sau simplitatea conceptuală.
În schimb, reprezentările 3D sunt folosite în momentul în care se doresc hărți cu un nivel de detaliu mult mai mare.
Acestea vin, totuși, cu un cost ridicat din punct de vedere al resurselor utilizate.

Spre exemplu, în cazul senzorilor LiDAR 2D, există o limitare cu privire la natura senzorului.
Fiind vorba de un Lidar 2D, acesta trimite fascicule de lumină doar la nivelul senzorului, astfel, orice obstacol care nu este direct la aceeași înălțime cu senzorul nu va fi înregistrat.
Din această cauză va fi nevoie de senzori adiționali pentru a putea asigura navigarea în siguranță.

În funcție de natura componentei de estimare pot fi împărțite în principal în: metode bazate pe filtre probabilistice, metode bazate pe scan matching și metode bazate pe optimizarea grafurilor. @rs17071214

Metodele bazate pe filtrarea probabilistică tratează problema de SLAM ca fiind o problemă de estimare a stării în timp real. 
Acestea încearcă să obțină doar locația curentă a robotului, spre deosebire de alte metode.
La baza acestei metode stă filtrarea Bayesiana, care vine cu o predicție a stării curente în baza stărilor precedente și a comenzilor curente.
Se bazează pe două relații fundamentale @rs17071214:
#set math.equation(numbering: "(1)")

  $ p(x_t | x_(1:t-1), z_(1:t), u_(1:t)) = p(x_t | x_(t-1), u_t) $ <eq:transition>

și

  $ p(z_t | x_(0:t), z_(1:t), u_(1:t)) = p(z_t | x_t) $ <eq:measurement>

unde:

- $x_t$ reprezintă starea sistemului la momentul de timp $t$;
- $u_t$ reprezintă comanda de control aplicată la momentul $t$;
- $z_t$ reprezintă măsurătoarea furnizată de senzori la momentul $t$;


@eq:transition ilustrează cum probabilitatea ca starea sistemului la un moment dat $t$, condiționată de istoricul de stări precedente, istoricul de comenzi și cel al măsurătorilor este echivalentă cu probabilitatea condiționată doar de starea precedentă și comanda actuală.
@eq:measurement ilustrează ca măsurătoarea curentă depinde doar de starea curentă, nu și de istoricul stărilor, comenzilor sau măsurătorilor.

Pe baza filtrării Bayesiene s-au dezvoltat ulterior 2 clase de soluții: soluțiile bazate pe Filtrul Kalman Extins (EKF) și cele bazate pe filtre de particule.

Conform @Thrun2008 EKF SLAM  menține o singură estimare a poziției robotului, cât și pentru reperele din mediu și o estimare a incertitudinii.
Robotul și mulțimea de repere sunt tratate ca fiind entități diferite.
Când robotul se deplasează prin spații noi, eroarea de poziție crește și noile repere moștenesc această eroare.
În momentul în care se revizitează un reper deja cunoscut, se produce ancorarea robotului și se corectează eroarea, corecție care este apoi propagată celorlalte repere anterioare.
Totuși abordările bazate pe EKF, nu mai sunt la fel de folosite actual, venind cu un cost foarte mare computațional față de alte metode, fiind nevoie de o matrice de dimensiuni foarte mari pentru a păstra informațiile despre relația dintre repere.

Tot în @Thrun2008 este descrisă și metoda de SLAM bazată pe filtre de particule.
Față de EKF, filtrele de particule calculează mai multe "particule", fiecare reprezentând o estimare despre drumul pe care l-a parcurs robotul.
Când robotul se află în mișcare, fiecare particulă simulează o mișcare diferită.
Când se întâlnește un obstacol, particulele ale căror hărți se potrivesc cu realitatea primesc un scor mai mare și se înmulțesc, în timp ce cele cu estimări greșite sunt eliminate.
Apare totuși o limitare în cazul deplasărilor de lungă durată și a hărților mai mari. 
Pe măsură ce se deplasează robotul, există riscul ca particulele șterse să fie de fapt bune și să fi fost șterse eronat.
În acel moment, se pierd ipotezele corecte și, în consecință harta își pierde coerența și corectitudinea.

Sistemele bazate pe scan matching se bazează pe identificarea transformării optime dintre 2 seturi de date, astfel estimându-se deplasarea dintre cele 2 poziții, adică distanța parcursă și direcția în care s-a deplasat robotul.
Pe măsură ce se deplasează, robotul captează mediul la diferite momente de timp.
Aceste căptări pot fi comparate, folosind diferiți algoritmi printre care: Iterative Closest Point (ICP) și Correlative Scan Matching (CSM). @rs17071214
Există mai multe abordări în cazul sistemelor de scan matching. 

Abordarea clasică este cea de scan to scan matching, în care se compară capturile senzorilor între două momente consecutive de timp, astfel încât se poate estima distanța parcursă între momentele captării.
O problema cu această metodă este faptul că această abordare este predispusă erorilor cumulative de calcule care pe termen lung vor duce la pierderea poziției.
O altă problemă este reprezentată de scenariul unui mediu fără prea multe repere, precum un hol lung.
În acest caz, potrivirea va fi perfectă, și nu se vor detecta mișcările.
O altă abordare este cea de scan to map matching, în care captura robotului este comparată cu o hartă construită pe parcurs de robot, practic, în cadrul careia se poziționează captura curentă.
Este o variantă mai stabilă dar pe măsură ce crește harta la dimensiuni foarte mari, pot apărea probleme legate de performanță.
Din această cauză, uneori este preferată extragerea unei bucăți din hartă, în jurul presupusei poziției a robotului, față de care este comparată captura. @sh-ch8-lidar

Nu în ultimul rând, cea mai folosită la momentul actual metodă, dintre cele menționate, de soluțiile comerciale este cea bazată pe optimizarea grafurilor.
Dacă metodele bazate pe filtre probabilistice caută să estimeze poziția corectă, abordările bazate pe grafuri analizează tot istoricul traiectoriei robotului.
Uzual, sistemul este transformat într-un graf în care nodurile reprezintă o poziție a robotului la un anumit moment de timp.
Opțional, nodul poate stoca și reperele observate pe parcurs.
Arcele grafului sunt constrângerile dintre noduri, adică date extrase de componenta de front-end, de exemplu distanța.
Acestea conțin de asemenea închiderile de buclă și o matrice de incertitudine.
Construirea grafului revine în principal front-end-ului, iar back-end-ul se ocupă cu minimizarea erorii dintre măsurători. @grisetti-tutorial

În @Thrun2008 modul de funcționare al unui astfel de sistem este asemănat cu un sistem resort-masă.
Modelul propune ca nodurile grafului să fie asociate cu inele metalice, în timp ce arcele sunt resorturi care conectează inelele.
Pe măsură ce se obțin noi măsurători, se adaugă un nou inel, care este ulterior conectat cu un resort de inelul precedent.
Din moment ce măsurătorile nu sunt perfecte, nici resorturile nu vor fi perfect și vor conține erori, astfel lanțul va devia de la adevărul fizic.
Dacă robotul se intoarce într-un loc deja vizitat, un inel precedent, se adaugă un nou resort, între inelul vizitat și inelul curent.
Din cauza erorilor acumulate, resortul va fi întins la maxim, ceea ce va face ca fiecare inel din buclă să se miște pentru a echilibra sistemul la o stare de energie minimă, practic eliminând erorile de măsurare de până în acel moment. @Thrun2008

O variantă foarte folosită a acestui tip de sistem este cel bazat pe grafurile de factori (factor graphs). @sh-ch1-fg4slam
În cazul acestor grafuri, există mai multe tipuri de noduri: variabilele, care reprezintă ceea ce dorim să aflam, de exemplu pozițiile robotului, și, factorii, constrângerile observate pe traiectorie.
Fiecare factor este practic o ecuație care leagă variabile între ele.
Scopul este cel de a realiza inferența probabilistică, anume maximizare a posteriori.
Rezolvarea grafului presupune aflarea configurației variabilelor care maximizează produsul factorilor din rețea.
Considerând faptul că măsurătorile sunt modelate folosind zgomotul Gaussian, această problemă devine, în practică, o problemă de minimizare celor mai mici pătrate neliniare.
Se caută valorile variabilelor pentru care suma erorilor pătratice este minimizată.
Din cauza caracterului bipartit și a faptului că fiecare factor depinde doar de un mic număr de variabile, rezolvarea problemei este eficientă chiar și pentru cele mai lungi traiectorii. @sh-ch1-fg4slam

== 2.2 Probleme

Cu acestea fiind spuse, problema fundamentală a unui sistem SLAM este reprezentată de estimarea corectă a poziției robotului, folosind datele furnizate de către senzori, în același timp în care se construiește harta mediului înconjurător.
Aceste două părți ale problemei fundamentale sunt dependente una de cealaltă.
Astfel, pentru o estimare cât mai bună a poziției este nevoie de o hartă corectă și coerentă a mediului în interiorul căreia să se plaseze robotul, iar, pentru o hartă corectă și pentru reprezentarea corectă a elementelor întâlnite este nevoie ca robotul să își cunoască poziția cu un grad suficient de mare de acuratețe.

Din această cauză, s-au dezvoltat mai multe modalități de a rezolva problema impusă de SLAM, unele dintre care au fost descrise anterior.
În continuare, vor fi dezvoltate problemele uzuale, precum și unele metode de a gestiona aceste probleme, întâlnite în cadrul unui sistem SLAM bidimensional, care folosește senzori LiDAR, IMU și senzori odometrici, care utilizează scan matching și un filtru Kalman pentru estimarea poziției.

În primul rând, fiind bazat pe scan matching, sistemul este deosebit de sensibil la mediul înconjurător, de exemplu: un mediu fără prea multe repere precum un hol lung va duce la imposibilitatea detectării mișcării.
Un sistem de tip scan to scan matching este de asemenea vulnerabil la acumularea erorilor între capturi, motiv pentru care este de preferat o abordare de tip scan to map matching.
Abordarea scan to map introduce complexitatea unei alte componente care reconstruiește harta pentru a putea fi comparată cu noua captură.
Altă problemă este reprezentată de momentele în care robotul intră în încăperi total noi, moment în care alinierea capturilor senzorului nu va mai produce rezultate.
În acel moment va fi nevoie să se utilizeze datele de la senzori și să fie considerate ca fiind corecte.
Datele preluate de senzori, IMU și odometrici nu sunt perfecte însă, în special cei odometrici sunt mult mai sensibili.
Aceștia pot fi influențați de suprafața pe care se află, dacă este mai alunecoasă, distanța parcursă estimată va fi greșită.
În plus, abordarea de tip dead-reckoning, în care se integrează vitezele pentru a obține distanța va acumula inevitabil mici erori de calcul care în timp vor crea drift-ul poziției.

Din acest motiv, dacă se folosește un filtru Kalman, se pot combina mai mulți senzori pentru a obține o estimare care să nu fie atât de vulnerabilă la slăbiciunile unui singur senzor.

Altă problemă este reprezentată de deformarea datelor primite de la LiDAR.
Datele sunt preluate în același timp în care robotul se deplasează, astfel fasciculele trimise la un moment de timp, sunt măsurate din altă poziție a robotului.
Acest efect este mult mai pronunțat în momentul în care vitezele de deplasare și rotație sunt mai mari.
Pentru a evita această problemă, trebuie introdus un pas înainte de etapa de scan-matching care să compenseze pentru mișcarea din timpul scanării pentru a corecta pozițiile obstacolelor lovite de către fasciculele emise.

== 2.3 Soluții alternative

Gmapping descris în detaliu în @gmapping este cea mai veche metodă care va fi prezentată în această secțiune.
Din punct de vedere al senzorilor, este necesar un senzor LiDAR precum și o sursă de odometrie a roților.
Este o metodă bazate pe filtrele de particule, mai anume folosește un filtru de particule Rao-Blackwellized.
O particulă reprezintă o traiectorie potențială  a robotului și o hartă, construită pe baza observațiilor și a traiectoriei, asociată fiecărei particule. @gmapping
Problema tradițională a abordărilor pe baza filtrelor de particule este faptul că este necesar un număr foarte mare de particule, mai ales in cadrul mediilor mari și a traiectoriilor complexe.

Pentru a evita această problemă, Gmapping vine cu mai multe îmbunătățiri.
În primul rând, ultima măsurătoare a senzorilor este luată în calcul la momentul în care se generează noile particule.
Pentru aceasta, pornind de la odometrie, se realizează o etapă de scan matching intre harta asociată particulei și ultima captură de la LiDAR.
În felul acesta se găsește cea mai probabilă poziție a robotului, în jurul căreia se generează noile particule.
În cazul in care etapa de scan matching eșuează, se revine la abordarea clasică, bazată exclusiv pe odometrie. @gmapping

Cealaltă adiție are legătură cu reeșantionarea, când particulele cu ponderi mici sunt eliminate, lucru care poate duce la eliminarea unor particule care sunt de fapt folositoare.
În cadrul Gmapping, se calculează un coeficient, dimensiunea efectivă a eșantionului, care măsoară cât de bine setul de particule modelează distribuția dorită. @gmapping
În momentul in care acest indice scade sub un anumit prag, de obicei jumătate din numărul particulelor, cele cu o pondere mică sunt eliminate.

Prin aceste două măsuri, Gmapping reușește să reducă semnificativ numărul de particule necesare, comparativ cu alte metode anterioare bazate pe filtre de particule.

Un alt sistem SLAM este reprezentat de HectorSLAM detaliat în @hectorslam.
Acesta este o soluție bazată pe scan matching și spre deosebire de alte soluții, acesta nu se folosește de senzori odometrici.
Este mult mai simplu față de alte opțiuni, și este destinat roboților fără mari capabilități de calcul.

Modul de funcționare poate fi descris in felul următor: măsurătorile LiDAR, o dată preluate și preprocesate sunt comparate cu hărțile precedente, folosind o optimizare de tip Gauss-Newton pentru a obține transformarea aferentă.
Folosirea unei optimizări Gauss-Newton, față de alte variante precum ICP este justificată de costul mai mic de putere computațional și posibilitatea de a compara cu mai multe hărți.
Acest lucru este important deoarece, pentru a evita blocarea intr-un minim local, sunt stocate mai multe reprezentări ale hărții, cu rezoluții care cresc cu fiecare reprezentare, estimându-se poziția prin compararea cu hărți din ce in ce mai precise, harta rezultată la final fiind adăugată la vârful structurii piramidale. @hectorslam

Un dezavantaj adus de structura simplă este faptul că HectorSLAM este în mod special sensibil la acumularea erorilor și apariția drift-ului când se confruntă cu traiectorii lungi.
Acest aspect este exacerbat de lipsa unui mecanism de loop closure, specific abordărilor de tip scan matching.

Cartographer prezentat în @cartographer este o soluție bazată pe grafuri, capabilă de reprezentare atât bidimensională cât și tridimensională a mediului înconjurător.
Spre deosebire de metodele menționate înainte, aceasta este o variantă mult mai complexă și completă.
Acesta este împărțit în două module separate: unul care realizează un SLAM local, în front-end, și unul care realizează un SLAM global, în back-end.
Principiul de funcționare constă în realizarea de subhărți care apoi sunt suprapuse între ele  și se realizează etapa de SLAM global.
Mai exact, sistemul aliniază scanări consecutive pentru a construi subhărți. 
O măsurătoare este inserată conform alogritmului de optimizare nonliniar Ceres scan matching, care caută poziția optimă care maximizează probabilitatea ca punctele detectate de LiDAR să se potrivească cu structurile subhărții. @cartographer
Acesta este un proces precis când este vorba de distanțe scurte, dar acumulează erori pe termen lung.

Din acest motiv, are loc etapa de SLAM global, care presupune optimizarea unui graf format din pozițiile și subhărțile estimate la faza locală. @cartographer
Când se finalizează crearea unei subhărți, devine disponibilă pentru închiderea buclelor.
În timpul în care se realizează partea locală, în paralel se verifică dacă o captură a senzorilor se potrivește cu una dintre hărțile deja cunoscute, ceea ce ar însemna că s-a vizitat un loc deja cunoscut, deci se poate închide o buclă.
În acel moment se introduce o nouă constrângere în graf, și se rezolvă erorile acumulate pe parcurs.


SLAM Toolbox, prima dată introdus în @Macenski2021 este una dintre cele mai recente și a fost larg adoptat în anii de după introducere.
Precum majoritatea soluțiilor recente, SLAM Toolbox este o soluție de tip de optimizare a grafurilor.
Vine cu mai multe avantaje față de alte metode.
În primul rând, este o metodă concepută cu ideea de a putea continua o hartă în cursul a mai multor sesiuni.
Acest lucru se realizează prin salvarea atât a datelor brute, cât și a grafului de poziții.
Acestea pot sa fie serializate și deserializate pentru a putea continua cartografierea pe parcursul mai multor sesiuni.
SLAM Toolbox introduce și o componentă care permite utilizatorului să intervină asupra nodurilor din graf, lucru care poate ajuta, de exemplu la inchideri de bucle.

Vine cu mai multe moduri de utilizare @Macenski2021: unul asincron care este conceput pentru a crea hărți cât mai corecte, fără considerente de timp, având un buffer care stochează toate măsurătorile pentru a fi procesate în totalitate, un mod sincron care prioritizează performanțele în timp real în detrimentul calității mai ridicate a hărții și un mod destinat navigării în cadrul unei hărți deja cunoscute, fără a mai interveni permanent asupra acesteia.
Pentru a realiza ultimul mod, se folosește un buffer rotativ care menține măsurătorile curente, care sunt adăugate grafului permanent, în forma unor noi constrângeri și poziții. 
La îndepărtare aceste măsurători sunt eliminate, graful revenind la forma originală, salvată precedent.

== 2.4 Tehnologii folosite

ROS 2 este, la momentul actual, una dintre cele mai folosite platforme pentru dezvoltarea aplicațiilor de robotică, în special cele din zona de open-source.
ROS 2 are o structură descentralizată bazată pe Data Distribution Service (DDS) și o arhitectură de tip peer to peer.
În acest mod, componentele unui sistem dezvoltat în ROS 2 pot acționa complet independent unul față de celălalt.
Comunicarea este realizată cu ajutorul a trei tipuri de comunicare: topic, service și action. @ros2
Topic-urile sunt cele mai folosite și au un comportament de tip subscriber-publisher.
Service-urile sunt un mecanism de tip request-reply, iar action-urile sunt orientate spre rezultat, și oferă feedback constant.

Într-un sistem dezvoltat pe ROS 2 există trei sisteme de referință importante pentru localizare în cadrul roboților autonomi.
Primul dintre acestea base_link, care este atașat bazei robotului, și poate fi văzut ca fiind un cadru local.
Celelalte două sunt sisteme de referință globale, odom și map.
Poziția unui robot în cadrul odom trebuie să fie mereu continuă, motiv pentru care acesta va suferi de drift-uri ale poziții, adică estimarea poziției robotului va acumula erori.
Pentru a rezolva această problemă, există sistemul map care acceptă salturi ale poziției cu scopul de a corecta localizarea robotului.
Datorită structurii arborescente în care un cadru poate avea un singur sistem părinte, nu există o legătură directă între map și odom.
Din acest motiv, pentru a obține transformarea între sistemele de referință care permite vizualizarea corectă a rezultatelor, trebuie calculată următoarea transformare între map și odom:

$ H_("map")^("odom") = H_("map")^("base") (H_("odom")^("base"))^(-1) $ <eq:map-odom>

unde $H_("map")^("base")$ reprezintă poziția rezultată după SLAM, în planul de referință map și $(H_("odom")^("base"))$ reprezintă poziția robotului în planul odom.
Matricile $H$ sunt matrici de transformare omogene, având o translație cu $(x, y)$ și o rotație în jurul axei $z$ cu unghiul $theta$ și sunt de forma:

$
H(x, y, theta) = mat(
  cos theta, -sin theta, 0, x;
  sin theta,  cos theta, 0, y;
  0,        0,       1, 0;
  0,        0,       0, 1
)
$ <eq:htm>

Pentru componenta de scan matching a fost folosită biblioteca small_gicp @small_gicp care pune la dispoziție mai multe implementări eficiente de algoritmi precum ICP, Point to Plane ICP, GICP din punct de vedere al timpului de execuție.

Pentru implementare a fost ales GICP @gicp în detrimentul altor variante tip ICP.
Aceasta înglobează atât cazul point to point și cel point to plane în același cadru probabilistic, efectiv devenind o abordare plan to plane.
GICP oferă mai multă robustețe și acuratețe în alinierea mulțimilor de puncte față de ICP.
Dacă ICP caută sa minimizeze distanța între punctele corespunzătoare, GICP utilizează informații legate de structura suprafețelor, având asociate matrici de covarianță pentru fiecare punct.
Algoritmul devine mai rezistent la zgomot și oferă rezultate mai precise. @gicp

În urma măsurătorilor obținute de la LiDAR, se obțin mai multe distanțe, fiecare corespunzătoare unui unghi în care a fost trimis fasciculul de lumină.
Aceste puncte pot fi aduse în sistemul de referință a robotului după formulele:

$
x_i = r_i dot cos(theta_i)\
y_i = r_i dot sin(theta_i)
$ <eq:point_cloud>
unde:

- $r_i$ este distanța la care s-a observat un obstacol
- $theta_i$ este unghiul la care s-a observat obstacolul

Totuși, un senzor LiDAR nu achiziționează datele în același moment de timp, ci măsoară distanțele pe parcursul unei rotații complete, intr-un interval de timp.
Din această cauză, dacă robotul se deplasează, fasciculele trimise vor fi capturate dintr-o poziție și orientare deplasate față de locația originală. @Zhang-RSS-14
Dacă punctele sunt tratate ca și când au fost măsurate in același timp, atunci setul de puncte va fi puțin distorsionat de mișcarea robotului, lucru care va duce la hărți mai puțin precise și care nu corespund in totalitate cu realitatea.
O metodă folosită pentru eliminarea distorsiunii este interpolarea liniară de poziții. @Zhang-RSS-14

Pentru a corecta distorsiunea, fiecărui fascilul îi este asociat momentul de timp de achiziție $t_i$.
Poziția se poate obține prin interpolarea liniară între cele două estimări, de la momentele de timp $t_a$ și $t_b$, momentele de timp estimării de dinaintea fascilului și a celei de după: 
$
x_i = x_a + alpha (x_b - x_a), \
y_i = y_a + alpha (y_b - y_a), \
theta_i = theta_a + alpha thin Delta theta
$ <eq:deskew-interp>

unde:

- $alpha = (t_i - t_a) \/ (t_b - t_a)$ este factorul de interpolare
- $Delta theta = "atan2"(sin(theta_b - theta_a), cos(theta_b - theta_a))$ este diferența unghiulară

Având poziția fiecărui fascicul, punctele se pot readuce în același sistem de coordonate prin:
$ p_i^"corectat" = H(t_"ref")^(-1) H(t_i) p_i $ <eq:deskew>

unde:
- $H(t_i)$ este transformarea corespunzătoare poziției din momentul $t_i$,
- $H(t_"ref")$ cea de la momentul de referință.

Având punctele unde se află obstacolele, se poate folosi o tehnică ray casting pentru a trasa o linie până la acel punct, care reprezintă celulele goale.
Pentru aceasta s-a ales algoritmul lui Bresenham.

// Din cauza naturii robotului și a senzorului LiDAR, distanțele primite nu sunt întocmai corecte, și trebuie eliminată o deformare cauzată de  deplasarea robotului. 
// Pentru a compensa această mișcare se execută 4 pași


Pentru reprezentarea hărții a fost aleasă reprezentarea sub forma unui occupancy grid, o matrice care reprezintă mediul în care se află robotul.
S-a ales o rezoluție a hărții de 5 cm, ceea ce înseamnă ca o celula a matricii reprezintă 25 $"cm"^2$.

Pentru a găsi celula corespunzătoare unei anumite poziții se folosesc relațiile:
$
c_x = floor((x - x_"origin") / delta),
c_y = floor((y - y_"origin") / delta)
$ <eq:grid-mapping>
unde:
- $(c_x, c_y)$ sunt coordonate corespunzătoare în cadrul matricei
- $(x, y)$ sunt coordonatele globale la care s-a găsit obstacolul
- $(x_"origin", y_"origin")$ sunt coordonatele originii matricei
- $delta$ este rezoluția hărții

Dacă în urma unei scanări se detectează o celulă ca fiind liberă se scade o anumită valoare, iar dacă este ocupată de un obstacol se adaugă o valoare.
Valorile obținute sunt transformate în probabilități folosind log odds:
$ p = 1 - 1 / (1 + e^l) $ <eq:log-odds>

unde: 
- $p$ este probabilitatea ca celula să fie ocupată
- $l$ este valoarea din celulă

În urma unei comparații cu praguri stabilite experimental, unul pentru a considera o celulă ca fiind ocupată și altul pentru a considera o celulă ca fiind liberă, se înlocuiesc probabilitățile cu următoarele valori, pentru a putea fi după reprezentată harta: 
 - -1 dacă starea este necunoscută
 - 0 dacă celula este detectată ca fiind liberă
 - 100 dacă celula este detectată ca fiind ocupată

== 2.5 Metodologie de evaluare

Pentru a evalua rezultatele obținute vor fi analizate atât traiectoria obținută în urma componentei de localizare cât și calitatea hărților generate.
În cadrul fiecărei hărți, pentru fiecare versiune a soluției au fost salvate atât hărțile rezolvate, cât și pozițiile estimate (împreună cu ground truth din Gazebo) în ROS Bag-uri pentru a putea fi testate ulterior.

Pentru evaluarea traiectoriilor și pozițiilor obținute a fost folosit utilitarul Evo @grupp2017evo care permite trasarea și compararea celor 2 traiectorii, cea estimată și cea reală.
Pentru această comparație se vor folosi două metrici Relative Pose Error (RPE) și Absolute Trajectory Error (ATE).
Acestea sunt definite în @sturm2012 in felul următor:

- $"RPE"$:

$ E_i := (Q_i^(-1) Q_(i + Delta))^(-1) (P_i^(-1) P_(i + Delta)) $ <eq:rpe>
unde:

- $Delta$ reprezintă intervalul de timp pe care se dorește
- $P_i$ reprezintă poziția estimată la momentul de timp $i$
- $Q_i$ reprezintă referința la momentul de timp $i$
- $E_i$ reprezintă RPE la momentul $i$

RPE este o metrică care măsoară acuratețea la nivel local a traiectoriei în intervalul de timp $Delta$.
Mai exact evaluează drift-ul între două poziții consecutive.
Pentru a agrega erorile între $m$ poziții se va folosi valoarea RMSE (Root Mean Square Error): 

$ "RMSE"(E_(1:n), Delta) := (
  1 / m sum_(i=1)^m || "trans"(E_i) ||^2
)^(1/2) $ <eq:rpe-rmse>

unde: 

- $"trans"(E_i)$ este componenta de translație a erorii

și

- $"ATE"$:

$ F_i := Q_i^(-1) S P_i $ <eq:ate>

unde:

- $P_i$ reprezintă poziția estimată la momentul de timp $i$
- $Q_i$ reprezintă referința la momentul de timp $i$
- $S$ reprezintă transformarea între sistemele de coordonate ale referinței și a estimării
- $F_i$ reprezintă ATE la momentul $i$

ATE reprezintă o metrică globală care măsoară acuratețea intre traiectoria estimată și cea de referință.
Pentru a măsura ATE pentru $n$ momente de timp, se va folosi valoarea RMSE:

$ "RMSE"(F_(1:n)) := (
  1 / n sum_(i=1)^n || "trans"(F_i) ||^2
)^(1/2) $ <eq:ate-rmse>

unde: 

- $"trans"(F_i)$ este componenta de translație a erorii

Evaluarea calității hărții este o problemă mai mare față de evaluarea traiectoriei (în cazul în care există o referință a traiectoriei cu care să se facă comparația). 
Unui om îi este ușor să aleagă între două hărți care este mai potrivită, dar acest lucru nu poate fi înglobat la fel de ușor într-o metrică.
Astfel, pentru evaluarea hărților produse, au fost preluate metricile descrise în @benchmark2017, anume: proporția de celule ocupate, numărul de colțuri și numărul de spații închise.
Proporția se referă la procentul de celule ocupate din hartă. 
Între 2 hărți ale aceluiași mediu, cea cu o proporție mai mare de celule ocupate va fi de o calitate mai scăzută deoarece obstacolele detectate vor fi mai groase pe hartă, semn că au existat fluctuații cu privire la poziția robotului.
Similar, o hartă cu mai multe colțuri va fi probabil de o calitate mai mică deoarece acele colțuri suplimentare au fost probabil rezultatul unor artefacte din procesul de cartografiere.
În final, o hartă cu mai multe spații închise va fi, de asemenea, cel mai probabil de o calitate mai mică deoarece acele spații detectate pot fi cauzate de erori de orientare sau poziționare sau chiar închideri deficitare de bucle. @benchmark2017
Pentru implementarea acestei componente a fost folosită biblioteca OpenCV @opencv_library care pune la dispoziție implementări consacrate ale operațiilor descrise în @benchmark2017 pentru o efieciență maximă.
Aceastea se aplică hărții obținute care este după tratată ca o imagine și se pot extrage trăsăturile dorite din aceasa.