PrintWriter output; //<>//
PImage img;
int count_screenshot = 1;
boolean binarization_done=false, fill_area_done = false, search_done = false;
color black = color(0, 0, 0);
color white = color(255, 255, 255);
color red = color(204, 0, 10), blue=color(25, 135, 220), yellow = color(251, 236, 53), green = color(88, 191, 63);
color[] colorset = new color[4];
final int RANGE = 256;
int sx, sy;

final int MAX_LINE = 64;
final int MAX_CUE = 2;
final int PREFECTURE = 33;
final int MAX_AJCT = 10;
int[][] cdnt = new int[MAX_LINE][MAX_CUE];
int[][] adjacent = new int[PREFECTURE][MAX_AJCT];
int[] whatcolor = new int[PREFECTURE];

void setup() {
  img = loadImage("kanagawa_outline.png");
  size(640, 500);

  String[] datalines = loadStrings("coordinate.csv");
  if (datalines != null) {
    for (int i = 0; i < datalines.length; i ++) {
      if (datalines[i].length() != 0) {
        String[] values = datalines[i].split(",", -1);
        for (int j = 0; j < MAX_CUE; j ++) {
          if (values[j] != null && values[j].length() != 0) {
            cdnt[i][j] = int(values[j]);
            //print(cdnt[i][j] + "\t");
          }
        }
        //print("\n");
      }
    }
    println(datalines.length );
  }

  datalines = loadStrings("adjacent.csv");
  if (datalines != null) {
    for (int i = 0; i < datalines.length; i ++) {
      if (datalines[i].length() != 0) {
        String[] values = datalines[i].split(",", -1);
        for (int j = 0; j < values.length; j ++) {
          if (values[j] != null && values[j].length() != 0) {
            adjacent[i][j] = int(values[j]);
          }
          if (values[j] != null) {
            adjacent[i][j+1]= -1;
          }
        }
      }
    }
  }

  colorset[0] = color(#375E97);
  colorset[1] = color(#FB6542);
  colorset[2] = color(#FFBB00);
  colorset[3] = color(#3F681C);
  for (int i=0; i<PREFECTURE; i++) {
    if (i<0 || i>=PREFECTURE) {
      return;
    }
    whatcolor[i] = -1;
  }
}

void draw() {
  if (!binarization_done) {
      binarization();
      binarization_done=true;
  }
  if (!search_done) {
    search(0);
    for (int i=0; i<PREFECTURE; i++) {
      println(whatcolor[i]);
    }
    search_done=true;
  }
  if (!fill_area_done) {
    for (int i=0; i<PREFECTURE; i++) {
      fill_area(cdnt[i][0], cdnt[i][1], colorset[whatcolor[i]]);
    }
    fill_area_done=true;
  }
  fill(30);
  text("Press 'a' to change color", 10, 35);
}

void keyPressed() {
  if (key == 'p' || key == 'P') {
    String path  = System.getProperty("user.home") + "/Desktop/screenshot" + count_screenshot + ".png";
    save(path);
    count_screenshot++;
    println("screen saved." + path);
  }
  if (key == 'a' || key == 'A') {
    binarization_done=false;
    //search_done=false;
    fill_area_done=false;
    colorset[0] = color(random(0, 255), random(0, 255), random(0, 255));
    colorset[1] = color(random(0, 255), random(0, 255), random(0, 255));
    colorset[2] = color(random(0, 255), random(0, 255), random(0, 255));
    colorset[3] = color(random(0, 255), random(0, 255), random(0, 255));
  }
}

void binarization() {
  color bzn;
  image(img, 0, 0);
  for (int y=0; y<img.height; y++) {
    for (int x=0; x<img.width; x++) {
      bzn = get(x, y);
      if (red(bzn)<200 || green(bzn)<200 || blue(bzn)<200) {
        bzn = black;
      } else {
        bzn = white;
      }
      set(x, y, bzn);
    }
  }
}

void fill_area(int x, int y, color target) {
  int ll, rr, uu, dd;
  ll=rr=x;
  uu=dd=y;
  while (get(ll-1, y)!=black) {
    ll--;
  }
  while (get(rr+1, y)!=black) {
    rr++;
  }
  while (get(x, uu-1)!=black) {
    uu--;
  }
  while (get(x, dd+1)!=black) {
    dd++;
  }
  strokeWeight(1);
  stroke(black);
  line(ll, y, rr, y);
  line(x, uu, x, dd);
  explore_area(x+1, y-1, target);
  explore_area(x-1, y-1, target);
  explore_area(x-1, y+1, target);
  explore_area(x+1, y+1, target);
  strokeWeight(1);
  stroke(target);
  line(ll, y, rr, y);
  line(x, uu, x, dd);
}

void explore_area(int x, int y, color target) {
  if (get(x, y)!=white ) {
    return;
  }
  set(x, y, target);

  explore_area(x, y-1, target);
  explore_area(x+1, y, target);
  explore_area(x, y+1, target);
  explore_area(x-1, y, target);
}

void search(int s) {
  if (s<0 || s>=PREFECTURE) {
    return;
  }

  for (int i = 0; i<4; i++) {
    if (is_able_to_fill(s, i)) {
      whatcolor[s]=i;
      search(s+1);
    }
  }
}

boolean is_able_to_fill(int i, int c) {
  int j=0;
  while (adjacent[i][j]!=-1) {
    if (whatcolor[adjacent[i][j]] == c) {
      return false;
    }
    j++;
  }
  return true;
}
