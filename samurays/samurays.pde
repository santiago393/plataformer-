//                SAMURAY'S — JUEGO COMPLETO

int estado = 0;

float bxPlay = 400, byPlay = 250, bw = 200, bh = 60;
float bxCred = 400, byCred = 350;

// LISTAS DEL MAPA
ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<OneWayPlatform> oneWayPlatforms = new ArrayList<OneWayPlatform>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<HealOrb> heals = new ArrayList<HealOrb>();
ArrayList<Enemy> enemies = new ArrayList<Enemy>();

Player samurai;

int tile = 50;
int totalCoins = 0;
int coinsCollected = 0;

float cameraX, cameraY;

// Texturas
PImage healImg;
PImage spikeImg;
PImage coinImg;

// MAPA
String[] mapa = {
  "#################################################################################################################################################################################################################################################################################################################",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#............................................................................................................................................E...%........................O...................................######################............................................................................#",
  "#...............................................................E.........................................................................................................O...................................######################............................................................................#",
  "#.........................................&.....#####....................E..........O.........................E...................E........####...........................O...................................######################............................................................................#",
  "#..P..................................#...#.....................##..............#########.................................................#####...........................O.E.....E.....E.....E..E....E.E.....######################............................................................................#",
  "#........####...E........###.O.###...##.%.##...................##....########OOO#...E...$...##................##..............########OOO######.......E.......E...........O...................................######################............................................................................#",
  "#.....................................#OOO#.......E.......E.................#####%......$.......E....E.....&...........E..................................................O...................................######################............................................................................#",
  "#################################################################################################################################################################################################################################################################################################################",
};
// SETUP
void setup() {
  size(1000, 600);

  healImg  = loadImage("heal.png");
  spikeImg = loadImage("spikes.png");
  coinImg  = loadImage("coin.png");
}
// DRAW
void draw() {

  if (estado == 0) { dibujarMenu(); return; }
  if (estado == 2) { dibujarCreditos(); return; }
  if (estado == 3) { dibujarGameOver(); return; }
  if (estado == 4) { dibujarVictoria(); return; }
  // JUEGO
  background(70, 100, 150);

  actualizarCamara();
  translate(-cameraX, -cameraY);

  for (Platform p : platforms)       p.display();
  for (OneWayPlatform o : oneWayPlatforms) o.display();
  for (Spike s : spikes)             s.display();
  for (Coin c : coins)               c.display();
  for (HealOrb h : heals)            h.display();

  for (Enemy e : enemies) {
    e.update();
    e.display();
  }

  samurai.update();
  samurai.display();

  resetMatrix();
  dibujarHUD();

  if (coinsCollected >= 2) {
    for (Spike s : spikes) s.hidden = true;
  }
}
// MENÚ
void dibujarMenu() {
  background(30, 40, 80);

  textAlign(CENTER);
  fill(255);
  textSize(70);
  text("SAMURAY'S", width/2, 150);

  fill(100, 150, 255);
  rect(bxPlay, byPlay, bw, bh, 15);
  fill(0);
  textSize(32);
  text("JUGAR", bxPlay + bw/2, byPlay + bh/2 + 10);

  fill(255, 200, 100);
  rect(bxCred, byCred, bw, bh, 15);
  fill(0);
  text("CRÉDITOS", bxCred + bw/2, byCred + bh/2 + 10);
}
// CREDITOS
void dibujarCreditos() {
  background(20, 20, 30);

  fill(255);
  textAlign(CENTER);
  textSize(60);
  text("CRÉDITOS", width/2, 120);

  textSize(30);
  text("Santiago De Yta — Creador", width/2, 250);

  textSize(30);
  text("Saul ugalde vidal — Co-creator", width/2, 300);

  textSize(30);
  text("Emiliano fuentes — code fixer helper", width/2, 350);

  textSize(30);
  text("giovanni gael — code fixer master", width/2, 400);


  textSize(30);
  text("Santiago De Yta — Creador", width/2, 250);

  textSize(18);
  fill(180);
  text("Presiona ESC para volver al menú", width/2, 500);
}
// GAME OVER
void dibujarGameOver() {
  background(20, 0, 0);

  textAlign(CENTER);
  fill(255, 50, 50);
  textSize(90);
  text("GAME OVER", width/2, 200);

  fill(255);
  textSize(30);
  text("Tu samurai ha caído en batalla…", width/2, 300);

  textSize(26);
  text("Presiona R para reintentar", width/2, 380);
  text("Presiona ESC para volver al menú", width/2, 430);
}
// VICTORIA
void dibujarVictoria() {
  background(0, 40, 0);

  textAlign(CENTER);
  fill(100, 255, 100);
  textSize(80);
  text("¡HAS GANADO!", width/2, 200);

  fill(255);
  textSize(28);
  text("Recolectaste todas las monedas.", width/2, 280);

  textSize(24);
  text("Presiona R para jugar de nuevo", width/2, 360);
  text("Presiona ESC para volver al menú", width/2, 400);
}
// CLICK MOUSE
void mousePressed() {

  if (estado == 0) {

    if (mouseX > bxPlay && mouseX < bxPlay + bw &&
        mouseY > byPlay && mouseY < byPlay + bh) {
      cargarMapa();
      estado = 1;
    }

    if (mouseX > bxCred && mouseX < bxCred + bw &&
        mouseY > byCred && mouseY < byCred + bh) {
      estado = 2;
    }
  }
}
// TECLAS
void keyPressed() {
  // REINTENTAR 
  if ((estado == 3 || estado == 4) && key == 'r') {
    cargarMapa();
    estado = 1;
    return;
  }
  // VOLVER AL MENÚ
  if (key == ESC) {
    key = 0;
    estado = 0;
  }
}
// CARGA MAPA
void cargarMapa() {

  platforms.clear();
  oneWayPlatforms.clear();
  coins.clear();
  heals.clear();
  spikes.clear();
  enemies.clear();

  coinsCollected = 0;
  totalCoins = 0;

  for (int y = 0; y < mapa.length; y++) {
    for (int x = 0; x < mapa[y].length(); x++) {

      char c = mapa[y].charAt(x);

      if (c=='#') platforms.add(new Platform(x*tile, y*tile, tile, tile));
      if (c=='$') oneWayPlatforms.add(new OneWayPlatform(x*tile, y*tile, tile, tile));
      if (c=='P') samurai = new Player(x*tile, y*tile);
      if (c=='E') enemies.add(new Enemy(x*tile, y*tile));
      if (c=='O') spikes.add(new Spike(x*tile, y*tile, tile, tile));
      if (c=='%') {
        coins.add(new Coin(x*tile, y*tile, tile, tile));
        totalCoins++;
      }
      if (c=='&') heals.add(new HealOrb(x*tile, y*tile, tile, tile));
    }
  }
}
// CÁMARA
void actualizarCamara() {
  cameraX = samurai.x - width/2;
  cameraY = samurai.y - height/2;

  cameraX = max(0, cameraX);
  cameraY = max(0, cameraY);
}
// CLASES
class Platform {
  float x,y,w,h;
  Platform(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }
  void display() {
    fill(200);
    rect(x,y,w,h);
  }
}

class OneWayPlatform {
  float x,y,w,h;
  OneWayPlatform(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }
  void display() {
    fill(150,150,200);
    rect(x,y,w,h);
  }
}
// SPIKES 
class Spike {
  float x,y,w,h;
  boolean hidden = false;

  Spike(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {

    if (hidden) return;

    if (spikeImg != null) {
      imageMode(CENTER);
      image(spikeImg, x + w/2, y + h/2, w, h);
      imageMode(CORNER);
    } else {
      fill(255,0,0);
      triangle(x, y+h, x+w/2, y, x+w, y+h);
    }
  }
}
// COINS
class Coin {
  float x,y,w,h;
  boolean taken = false;

  Coin(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {
    if (taken) return;

    if (coinImg != null) {
      imageMode(CENTER);
      image(coinImg, x+w/2, y+h/2, w*0.9, h*0.9);
      imageMode(CORNER);
    } else {
      fill(255,255,0);
      ellipse(x+w/2, y+h/2, w*0.7, h*0.7);
    }

    // Colisión con el jugador
    if (rectsOverlap(samurai.x, samurai.y, samurai.w, samurai.h, x,y,w,h)) {
      taken = true;
      coinsCollected++;

      if (coinsCollected == totalCoins) {
        estado = 4;
      }
    }
  }
}
// HEAL ORB
class HealOrb {
  float x,y,w,h;
  boolean used = false;

  HealOrb(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {
    if (used) return;

    if (healImg != null) {
      imageMode(CENTER);
      image(healImg, x+w/2, y+h/2, w*0.9, h*0.9);
      imageMode(CORNER);
    } else {
      fill(0,255,0);
      ellipse(x+w/2, y+h/2, w*0.7, h*0.7);
    }

    if (rectsOverlap(samurai.x, samurai.y, samurai.w, samurai.h, x,y,w,h)) {
      samurai.vida = min(100, samurai.vida + 50);
      used = true;
    }
  }
}
// PLAYER
class Player {
  float x, y, vy;
  float oldX, oldY;
  float w = 20, h = 45;

  boolean onGround = false;
  boolean invulnerable = false;
  int invTimer = 0;
  boolean facingRight = true;

  int vida = 100;

  Animation idle, run, attackAnim, hurtAnim;
  Animation current;

  boolean attacking = false;
  int attackTimer = 0;

  float scale = 1.3;
  float footOffset = 15 * scale;

  Player(float x,float y){
    this.x=x; this.y=y;

    idle       = new Animation(loadFrames("samurai/idle", 10));
    run        = new Animation(loadFrames("samurai/run", 16));
    attackAnim = new Animation(loadFrames("samurai/attack", 7));
    hurtAnim   = new Animation(loadFrames("samurai/hurt", 4));

    current = idle;
  }

  void update() {

    oldX = x;
    oldY = y;

    float speed = 4;
    boolean moving = false;

    if (keyPressed) {
      if (key=='a'){ x -= speed; moving=true; facingRight=false; }
      if (key=='d'){ x += speed; moving=true; facingRight=true; }
    }

    if (keyPressed && key=='w' && onGround)
      vy = -12;

    vy += 0.5;
    y += vy;

    onGround = false;

    for (Platform p : platforms)       corregirColision(p);
    for (OneWayPlatform o : oneWayPlatforms) corregirOneWay(o);

    for (Spike s : spikes)
      if (!s.hidden && rectsOverlap(x,y,w,h, s.x,s.y,s.w,s.h))
        vida = 0;

    if (keyPressed && key=='e' && !attacking) {
      attacking = true; attackTimer = 10;
      current = attackAnim; hacerDaño();
    }

    if (attacking) {
      attackTimer--;
      if (attackTimer <= 0) attacking = false;
    }

    if (!attacking)
      current = moving ? run : idle;

    if (invulnerable) {
      invTimer--;
      if (invTimer <= 0) invulnerable = false;
    }

    current.update();

    if (vida <= 0) estado = 3;
  }

  void corregirColision(Platform p){
    if (!rectsOverlap(x,y,w,h, p.x,p.y,p.w,p.h)) return;

    if (oldY + h <= p.y && vy > 0) {
      y = p.y - h; vy = 0; onGround = true; return;
    }

    if (oldY >= p.y + p.h && vy < 0) {
      y = p.y + p.h; vy = 0; return;
    }

    if (oldX + w <= p.x) { x = p.x - w; return; }
    if (oldX >= p.x + p.w) { x = p.x + p.w; return; }
  }

  void corregirOneWay(OneWayPlatform o){
    if (vy > 0 && y + h <= o.y + 2)
      if (rectsOverlap(x,y,w,h, o.x,o.y,o.w,o.h)) {
        y = o.y - h;
        vy = 0;
        onGround = true;
      }
  }

  void recibirDaño(int dmg) {
    if (invulnerable) return;
    vida -= dmg; if (vida < 0) vida = 0;
    vy = -6; x += facingRight ? -8 : 8;
    invulnerable = true; invTimer = 30;
  }

  void hacerDaño() {
    float hitX = facingRight ? x + w : x - 20;
    float hitY = y;
    float hitW = 30;
    float hitH = h;

    for (Enemy e : enemies)
      if (!e.muerto && rectsOverlap(hitX,hitY,hitW,hitH, e.x,e.y,e.w,e.h))
        e.recibirDaño(35);
  }

  void display() {
    if (invulnerable && frameCount % 6 < 3) return;

    PImage frame = current.frames[current.index];
    float dibW = frame.width * scale;
    float dibH = frame.height * scale;

    float drawX = x - dibW/2;
    float drawY = y + h - dibH + footOffset;

    if (!facingRight) {
      pushMatrix();
      translate(drawX + dibW, drawY);
      scale(-1,1);
      image(frame,0,0,dibW,dibH);
      popMatrix();
    } else {
      image(frame,drawX,drawY,dibW,dibH);
    }
  }
}
// ENEMIGO
class Enemy {
  float x,y,vy;
  float oldX, oldY;

  float w = 25;
  float h = 55;

  int vida = 100;
  boolean muerto = false;

  boolean facingRight = true;

  Animation idle, run;
  Animation current;

  float scale = 0.7;
  float footOffset = 42 * scale;

  Enemy(float x,float y){
    this.x=x; this.y=y;

    idle = new Animation(loadFrames("nightborne/idle",9));
    run  = new Animation(loadFrames("nightborne/run",6));

    current = idle;
  }

  void update() {

    oldX = x; oldY = y;

    if (muerto) return;

    float dist = samurai.x - x;

    facingRight = (samurai.x > x);

    if (abs(dist) < 300) {
      if (dist > 0) x += 1.1;
      else x -= 1.1;
      current = run;
      run.update();
    } else {
      current = idle;
      idle.update();
    }

    vy += 0.5;
    y += vy;

    for (Platform p : platforms) corregirColision(p);
    for (Spike s : spikes)     corregirColisionSpike(s);

    if (!muerto && rectsOverlap(x,y,w,h, samurai.x,samurai.y,samurai.w,samurai.h))
      samurai.recibirDaño(10);
  }

  void corregirColisionSpike(Spike s) {
    if (s.hidden) return;
    if (!rectsOverlap(x,y,w,h, s.x,s.y,s.w,s.h)) return;

    if (oldX + w <= s.x)      { x = s.x - w; return; }
    if (oldX >= s.x + s.w)    { x = s.x + s.w; return; }
    if (oldY + h <= s.y)      { y = s.y - h; vy = 0; return; }
  }

  void corregirColision(Platform p){
    if (!rectsOverlap(x,y,w,h, p.x,p.y,p.w,p.h)) return;

    if (oldY + h <= p.y && vy > 0) {
      y = p.y - h; vy = 0; return;
    }

    if (oldX + w <= p.x) { x = p.x - w; return; }
    if (oldX >= p.x + p.w) { x = p.x + p.w; return; }
  }

  void recibirDaño(int dmg){
    vida -= dmg;
    if (vida <= 0) muerto = true;
  }

  void display() {

    if (muerto) return;

    PImage frame = current.frames[current.index];
    float dibW = frame.width * scale;
    float dibH = frame.height * scale;

    float drawX = x - dibW/2;
    float drawY = y + h - dibH + footOffset;

    if (!facingRight) {
      pushMatrix();
      translate(drawX + dibW, drawY);
      scale(-1,1);
      image(frame,0,0,dibW,dibH);
      popMatrix();
    } else {
      image(frame, drawX, drawY, dibW, dibH);
    }
  }
}
// ANIMACIÓN
class Animation {
  PImage[] frames;
  int index=0, speed=6, counter=0;

  Animation(PImage[] frames){
    this.frames=frames;
  }

  void update(){
    counter++;
    if (counter > speed){
      counter=0;
      index = (index+1) % frames.length;
    }
  }
}
// LOAD FRAMES
PImage[] loadFrames(String folder, int total) {
  PImage[] arr = new PImage[total];
  for (int i=0; i<total; i++)
    arr[i] = loadImage(folder + "/" + i + ".png");
  return arr;
}
// HUD
void dibujarHUD() {
  fill(0,150);
  rect(20,20,250,60);

  fill(255,0,0);
  rect(25,25, samurai.vida * 1.5, 20);

  fill(255);
  textSize(16);
  text("Vida: "+samurai.vida+"/100", 25, 60);

  text("Monedas: " + coinsCollected + " / " + totalCoins, 160, 60);
}
// UTILS
boolean rectsOverlap(float x1,float y1,float w1,float h1,
                     float x2,float y2,float w2,float h2){
  return x1 < x2+w2 && x1+w1 > x2 &&
         y1 < y2+h2 && y1+h1 > y2;
}
