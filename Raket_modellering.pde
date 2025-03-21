//andet
boolean kør=true;
boolean faldskærmIGang=false;
int tal=0;
int nulHast=5;
int maxAccel=5;
int maxPoints = 5000; // Antal datapunkter, der vises ad gangen
ArrayList<Float> strækning = new ArrayList<Float>();
ArrayList<Float> hastighed = new ArrayList<Float>();
ArrayList<Float> accelration = new ArrayList<Float>();
float t = 0;
//raket parametre
float motorkraft=4.55; //N
float raketMasse=0.0917; //kg
float startBrændstofMasse=0.0083; //kg
float masse=raketMasse+startBrændstofMasse; //kg
int raketTid=1100; //ms
float Areal=0.000962; //m^2
float formFaktor=0.5;
boolean faldskærmSlåetTil=false;
float faldskærmAreal=0.1257; //m^2
float faldskærmFormFaktor=0.8;
//fysiske konstanter
float tyngdekraft=9.82; //N/kg
float densitetLuft=1.3; //kg/m^3
//simuleringsværdier
float delta=0.016/(maxPoints/500); //hvis de første 8 sekunder skal ses
//float delta=0.065/(maxPoints/500); //hvis hele grafen skal ses
float strækScale=6;
float hastScale=12;
float accelScale=6;


void setup() {
  fullScreen();
  simulate();
}

void simulate() {
  while (kør) {
    //tilføjer den nuværende accelration til arraylisten
    accelration.add(FRes() / masse);
    //opdatere variabel tal som holder styr på hvor langt programmet er kommet med datasættet
    tal = accelration.size();
    //kører kun hvis tal er større end en fordi tal-2 bruges og dette ikke må være under 0
    if (tal > 1) {
      //sætter den nuværende hastighed til den sidste hastighed plus den nuværende accelration ganget med tiden der er gået siden sidste hastighed
      hastighed.add(hastighed.get(tal - 2) + accelration.get(tal - 1) * delta);
      if (tal>20) {
        if (accelration.get(maxAccel)>accelration.get(tal-1)) {
          maxAccel=tal-1;
        }
        // opdatere værdien tiol bestemmelse af toppunktet ved at finde den værdi som ikke er i starten der ligger tættest på nul
        if (abs(hastighed.get(tal-1))<abs(hastighed.get(nulHast))) {
          nulHast=tal-1;
        }
      }
      // tænder faldskærmen når hastigheden bliver negativ hvis faldskærmen er slået til
      if(faldskærmSlåetTil && !faldskærmIGang){
      if (t>= 4+raketTid/1000 ) {
        Areal=faldskærmAreal;
        formFaktor=faldskærmFormFaktor;
      }
      }
      //sætter den nuværende højde til den sidste højde plus den nuværende hastighed ganget med tiden der er gået siden sidste højde
      strækning.add(strækning.get(tal - 2) + hastighed.get(tal - 1) * delta);
    } else {
      // hvis vi er ved første måling er hastighed og højde nul
      hastighed.add(float(0));
      strækning.add(float(0));
    }
    //opdatere tids variablen med det tidsskridt som variablerne er blevet opdateret med
    t += delta;
    //stopper simuleringen når højden er under 0
    if (strækning.get(tal - 1) < 0 && tal > 100) {
      kør = false;
    }
  }
  drawGraphScreen();
}

void drawGraphScreen() {
  background(240);
  strokeWeight(2);

  // Tegn akser
  stroke(0);
  line(width / 25, height / 2, width - width / 25, height / 2);
  line(width - width / 25, height / 10*9, width - width / 25, height / 10);
  line(width - width / 25, height / 10, width - width / 25 + width / 100, height / 10 + height / 50);
  line(width - width / 25, height / 10, width - width / 25 - width / 100, height / 10 + height / 50);
  line(width / 25, height / 10*9, width / 25, height / 10);
  line(width / 25, height / 10, width / 25 + width / 100, height / 10 + height / 50);
  line(width / 25, height / 10, width / 25 - width / 100, height / 10 + height / 50);

  // Tegn akseværdier
  fill(255, 0, 0);
  text("Strækning (m)", width - width / 7, height / 4 * 3 + 50);
  fill(0, 255, 0);
  text("Hastighed (m/s)", width - width / 7, height / 4 * 3 + 100);
  fill(0, 0, 255);
  text("Acceleration (m/s²)", width - width / 7, height / 4 * 3 + 150);

  // Vis numeriske værdier på y-aksen
  for (int i = 0; i <= 8; i++) {
    float y = height / 2 - i * 50;
    stroke(0);
    line(width/25 - 5, y, width/25 + 5, y);
    fill(255, 0, 0);
    text(nf(i*50/strækScale, 1, 1) + " m", width/25 - 40, y);
  }

  for (int i = -8; i <= 8; i++) {
    float y = height / 2 - i * 50;
    stroke(0);
    line(width - width/25 - 5, y, width - width/25 + 5, y);
    fill(0, 255, 0);
    text(nf(i * 50/hastScale, 1, 1) + " m/s", width - width/25 - 60, y);
  }

  for (int i = -8; i <= 8; i++) {
    float y = height / 2 - i * 50;
    fill(0, 0, 255);
    text(nf(i * 50/accelScale, 1, 1) + " m/s²", width - 60, y);
  }

  for (int i=1; (i/delta)<maxPoints; i++) {
    line(map(i/delta, 0, maxPoints, width / 25, width - width/25), height/2+5, map(i/delta, 0, maxPoints, width / 25, width - width/25), height/2-5);
  }

  // Tegn grafer
  drawGraph(strækning, color(255, 0, 0), strækScale);
  drawGraph(hastighed, color(0, 255, 0), hastScale);
  drawGraph(accelration, color(0, 0, 255), accelScale);

  //skriver værdierne for det punkt tættest på det realle toppunkt
  fill(0);
  text("Strækning: " + strækning.get(nulHast), width / 4, height / 4 * 3);
  text("Hastighed: " + hastighed.get(nulHast), width / 4, height / 4 * 3 + height / 50);
  text("Acceleration: " + accelration.get(nulHast), width / 4, height / 4 * 3 + height / 25);
  text("Max acceleration: " + accelration.get(maxAccel),width / 4, height / 4 * 3 +height*3 / 50);
}

void drawGraph(ArrayList<Float> data, color c, float scaler) {
  stroke(c);
  noFill();
  beginShape();
  for (int i = 0; i < data.size(); i++) {
    float x = map(i, 0, maxPoints, width / 25, width - width/25);
    float y = height / 2 - data.get(i) * scaler;
    vertex(x, y);
  }
  endShape();
}

float FRes() {
  //sørger for at rakketen kun accelere opad når den stadig skal
  if (t * 1000 < raketTid) {
    //opdatere massen til at reflektere den brugte mængde brændstof
    masse=raketMasse+startBrændstofMasse-startBrændstofMasse/(raketTid/(t*1000));
    //beregner den resulterende kraft på rakketen når den brænder motor som F_motor-g*m+F_luft
    return (motorkraft() - tyngdekraft * masse+luftModstand());
  } else {
    //beregner den resulterende kraft på rakketen når den ikke brænder motor som -g*m+F_luft
    return (0 - tyngdekraft * masse+luftModstand());
  }
}

float luftModstand() {
  //tilføjer kun luftmodstand anden gang accelration beregnes
  if (tal>1) {
    //sørger for at luftmodstanden påvirker i den modsatte retning af hastigheden
    if (hastighed.get(tal-1)<0) {
      //beregner luftmodstand som v^2*A*cw*\rho_luft
      return(pow(hastighed.get(tal-1), 2)*Areal*formFaktor*densitetLuft);
    } else {
      //beregner luftmodstand som v^2*A*cw*\rho_luft
      return(-pow(hastighed.get(tal-1), 2)*Areal*formFaktor*densitetLuft);
    }
  } else {
    return 0;
  }
}

float motorkraft(){
  if(t<0.4){
    return(-33.73*sin(0.57*t)+6.398*sin(8.67*t-0.955)+5.71);
  }
  else{
    return(165.25 - 1496.212*t + 5511.22*pow(t,2) - 10398.265*pow(t,3) + 10634.75*pow(t,4) - 5602.6*pow(t,5) + 1189.255*pow(t,6));
  }
}
