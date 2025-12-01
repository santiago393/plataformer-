// ===================================================
//     PLATAFORMERO SAMURAI — OBJETOS + FIX FINAL
// ===================================================

int tile = 40;

ArrayList<Platform> platforms = new ArrayList<Platform>();
ArrayList<OneWayPlatform> oneWayPlatforms = new ArrayList<OneWayPlatform>();
ArrayList<Spike> spikes = new ArrayList<Spike>();
ArrayList<Coin> coins = new ArrayList<Coin>();
ArrayList<HealOrb> heals = new ArrayList<HealOrb>();

ArrayList<Enemy> enemies = new ArrayList<Enemy>();
Player samurai = null;

float cameraX = 0;
float cameraY = 0;

int totalCoins = 0;
int coinsCollected = 0;

// ===================================================
//       MAPA ASCII — NUEVOS SÍMBOLOS
// ===================================================
// # = bloque solido
// . = aire
// P = jugador
// E = enemigo
// O = picos
// % = moneda
// & = curación (+50 hp)
// $ = plataforma atravesable SOLO para el jugador
String[] mapa = {
  "#################################################################################################################################################################################################################################################################################################################",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#.........................................................................................................................................................................O...................................######################............................................................................#",
  "#................................................................................................................................................%........................O...................................######################............................................................................#",
  "#............................................................................................................................................E............................O...................................######################............................................................................#",
  "#.........................................&.....#####...........E...................O......................................................####...........................O...................................######################............................................................................#",
  "#.........P...........................#...#.....................##.......E......#########........................................E........#####...........................O...................................######################............................................................................#",
  "#........####............###.O.###...##.%.##...................##....########OOO#.......$.....................##..............########OOO######...........................O...................................######################............................................................................#",
  "#................E....................#OOO#.......E.......E.................#####%.E....$.......E....E.....&...........E..........................E......E................O..E...E...E...E..E.................######################............................................................................#",
  "#################################################################################################################################################################################################################################################################################################################",
};


// ===================================================
// SETUP
// ===================================================
void setup() {
  size(1000, 600);
  cargarMapa();
}

// ===================================================
// DRAW
// ===================================================
void draw() {

  background(70, 100, 150);

  actualizarCamara();
  translate(-cameraX, -cameraY);

  // plataformas sólidas
  for (Platform p : platforms) p.display();

  // plataformas atravesables
  for (OneWayPlatform o : oneWayPlatforms) o.display();

  // picos
  for (Spike s : spikes) s.display();

  // monedas
  for (Coin c : coins) c.display();

  // curaciones
  for (HealOrb h : heals) h.display();

  // enemigos
  for (Enemy e : enemies) {
    e.update();
    e.display();
  }

  // jugador
  samurai.update();
  samurai.display();

  resetMatrix();
  dibujarHUD();
}

// ===================================================
// CARGA DEL MAPA
// ===================================================
void cargarMapa() {

  for (int y = 0; y < mapa.length; y++) {
    for (int x = 0; x < mapa[y].length(); x++) {
      char c = mapa[y].charAt(x);

      if (c=='#')
        platforms.add(new Platform(x*tile, y*tile, tile, tile));

      if (c=='$')
        oneWayPlatforms.add(new OneWayPlatform(x*tile, y*tile, tile, tile));

      if (c=='P')
        samurai = new Player(x*tile, y*tile);

      if (c=='E')
        enemies.add(new Enemy(x*tile, y*tile));

      if (c=='O')
        spikes.add(new Spike(x*tile, y*tile, tile, tile));

      if (c=='%') {
        coins.add(new Coin(x*tile, y*tile, tile, tile));
        totalCoins++;
      }

      if (c=='&')
        heals.add(new HealOrb(x*tile, y*tile, tile, tile));
    }
  }
}

// ===================================================
// CÁMARA
// ===================================================
void actualizarCamara() {
  cameraX = samurai.x - width/2;
  cameraY = samurai.y - height/2;
}

// ===================================================
// BLOQUES SÓLIDOS
// ===================================================
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

// ===================================================
// PLATAFORMAS ATRAVESABLES ($)
// ===================================================
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

// ===================================================
// TRAMPAS — PICOS (O)
// ===================================================
class Spike {
  float x,y,w,h;
  Spike(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {
    fill(255,0,0);
    triangle(x, y+h, x+w/2, y, x+w, y+h);
  }
}

// ===================================================
// COIN (%) — MONEDA
// ===================================================
class Coin {
  float x,y,w,h;
  boolean taken = false;

  Coin(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {
    if (taken) return;
    fill(255,255,0);
    ellipse(x+w/2, y+h/2, w*0.7, h*0.7);

    if (rectsOverlap(samurai.x, samurai.y, samurai.w, samurai.h, x,y,w,h)) {
      taken = true;
      coinsCollected++;
    }
  }
}

// ===================================================
// ORBE DE CURACIÓN (&)
// ===================================================
class HealOrb {
  float x,y,w,h;
  boolean used = false;

  HealOrb(float x,float y,float w,float h){
    this.x=x; this.y=y; this.w=w; this.h=h;
  }

  void display() {
    if (used) return;
    fill(0,255,0);
    ellipse(x+w/2, y+h/2, w*0.7, h*0.7);

    if (rectsOverlap(samurai.x, samurai.y, samurai.w, samurai.h, x,y,w,h)) {
      samurai.vida = min(100, samurai.vida + 20);
      used = true;
    }
  }
}

// ===================================================
//                  PLAYER (SAMURAI)
// ===================================================
class Player {
  float x, y, vy;

  float w = 20;
  float h = 96;

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

  // offset exacto del samurai (medido): 15 px
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

    // MOVIMIENTO
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

    // COLISIÓN CON PISO
    onGround = false;

    // plataformas sólidas
    for (Platform p : platforms)
      corregirColision(p);

    // plataformas atravesables
    for (OneWayPlatform o : oneWayPlatforms)
      corregirOneWay(o);

    // PICOS (insta kill)
    for (Spike s : spikes) {
      if (rectsOverlap(x,y,w,h, s.x,s.y,s.w,s.h)) {
        vida = 0; // muerte instantánea
      }
    }

    // ATAQUE
    if (keyPressed && key=='e' && !attacking) {
      attacking = true;
      attackTimer = 10;
      current = attackAnim;
      hacerDaño();
    }

    if (attacking) {
      attackTimer--;
      if (attackTimer <= 0)
        attacking = false;
    }

    if (!attacking)
      current = moving ? run : idle;

    // INVULNERABILIDAD
    if (invulnerable) {
      invTimer--;
      if (invTimer <= 0) invulnerable = false;
    }

    current.update();
  }

  // -------- COLISIÓN PLATAFORMA SÓLIDA ------
  void corregirColision(Platform p){
    if (!rectsOverlap(x,y,w,h, p.x,p.y,p.w,p.h)) return;

    if (vy > 0) {
      y = p.y - h;
      vy = 0;
      onGround = true;
    }
  }

  // -------- COLISIÓN ONE-WAY ($) ------
  void corregirOneWay(OneWayPlatform o){
    // el jugador debe estar cayendo Y estar arriba para colisionar
    if (samurai.y + samurai.h <= o.y + 5 && vy > 0) {
      if (rectsOverlap(x,y,w,h, o.x,o.y,o.w,o.h)) {
        y = o.y - h;
        vy = 0;
        onGround = true;
      }
    }
  }

  // -------- DAÑO --------
  void recibirDaño(int dmg) {
    if (invulnerable) return;
    vida -= dmg;
    if (vida < 0) vida = 0;

    invulnerable = true;
    invTimer = 30;
  }

  // -------- ATAQUE --------
  void hacerDaño() {
    float hitX = x + (facingRight ? w : -40);
    float hitY = y;
    float hitW = 40;
    float hitH = h;

    for (Enemy e : enemies) {
      if (!e.muerto && rectsOverlap(hitX,hitY,hitW,hitH, e.x,e.y,e.w,e.h)) {
        e.recibirDaño(35);
      }
    }
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
      translate(drawX+dibW, drawY);
      scale(-1,1);
      image(frame,0,0,dibW,dibH);
      popMatrix();
    } else {
      image(frame,drawX,drawY,dibW,dibH);
    }
  }
}

// ===================================================
// ENEMIGO FIX
// ===================================================
class Enemy {
  float x,y,vy;

  float w = 40;
  float h = 70;

  int vida = 100;
  boolean muerto = false;

  Animation idle, run;

  float scale = 0.7;

  // OFFSET exacto del enemigo (calculado): 42 px
  float footOffset = 42 * scale;

  Enemy(float x,float y){
    this.x=x; this.y=y;

    idle = new Animation(loadFrames("nightborne/idle",9));
    run  = new Animation(loadFrames("nightborne/run",6));
  }

  void update() {
    if (muerto) return;

    float dist = samurai.x - x;

    if (abs(dist) < 300) {
      if (dist > 0) x += 1.1;
      else x -= 1.1;
      run.update();
    } else idle.update();

    vy += 0.5;
    y += vy;

    for (Platform p : platforms) {
      if (rectsOverlap(x,y,w,h, p.x,p.y,p.w,p.h)) {
        y = p.y - h;
        vy = 0;
      }
    }

    if (!muerto && rectsOverlap(x,y,w,h, samurai.x,samurai.y,samurai.w,samurai.h))
      samurai.recibirDaño(10);
  }

  void recibirDaño(int dmg){
    vida -= dmg;
    if (vida <= 0) muerto = true;
  }

  void display() {
    if (muerto) return;

    PImage frame = idle.frames[idle.index];
    float dibW = frame.width * scale;
    float dibH = frame.height * scale;

    float drawX = x - dibW/2;
    float drawY = y + h - dibH + footOffset;

    image(frame, drawX, drawY, dibW, dibH);
  }
}

// ===================================================
// ANIMACIÓN
// ===================================================
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

// ===================================================
// LOAD FRAMES
// ===================================================
PImage[] loadFrames(String folder, int total) {
  PImage[] arr = new PImage[total];
  for (int i=0; i<total; i++)
    arr[i] = loadImage(folder + "/" + i + ".png");
  return arr;
}

// ===================================================
// HUD COMPLETO
// ===================================================
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

// ===================================================
// UTILS
// ===================================================
boolean rectsOverlap(float x1,float y1,float w1,float h1,
                     float x2,float y2,float w2,float h2){
  return x1 < x2+w2 && x1+w1 > x2 &&
         y1 < y2+h2 && y1+h1 > y2;
}
