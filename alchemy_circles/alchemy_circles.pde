/*
    Alchemy Circles
    ---------------
    This program procedurally generates alchemy circles using recursion.
    
    written by Adrian Margel, Summer 2018
*/


//-----------------------
//    General/Main
//-----------------------

//the list of alc circles to be drawn to screen
ArrayList<Node> spells;
//how large things are drawn to screen
float zoom;

void setup(){
  //----------------SAFE TO MODIFY THESE VARIABLES----------------
  
  //setup size of window
  size(1600,800);
  
  //set number of alc circles to be drawn
  int spellCount=2;
  
  //set how detailed those circles will be
  int complexity=6;
  
  //---------------------------------------------
  
  //calculate number of rows and columns needed to neatly display all alc circles on screen
  float columns=((float)height/width);
  float temp=sqrt(spellCount/columns);
  temp=ceil(temp);
  int rCount=(int)(temp);
  int cCount=ceil(spellCount/temp);
  
  //set zoom to fit all columns and rows
  zoom=min(width/rCount,height/cCount);
  
  //init spells array
  spells=new ArrayList<Node>();
  for(int i=0;i<spellCount;i++){
    spells.add(new Node());
  }
  //generate spells
  for(Node n:spells){
    //this boolean will be changed only be changed to true by the mutate method if the circle was able to generate at the desired depth
    //if the boolean does not change to true then it mean the alc circle must be generated again
    boolean[] finished={false};
    while(!finished[0]){
      n.create(1);
      mutate(n,complexity,finished,true);
    }
  }
}
void draw(){
  //draw background
  background(0);
  
  //set color of the alc circles
  stroke(200,100,100);
  //set how thick the lines are with the alc circles
  strokeWeight(1);
  //set a fill for the alc circles.
  //fill will mean that higher levels of alc circle will cover up lower ones
  //it generally looks best with a semi-transparent fill
  fill(0,150);
  
  //display spells
  int row=0;
  int column=0;
  for(int i=0;i<spells.size();i++){
    if(zoom*(column+1)>width){
      row++;
      column=0;
    }
    spells.get(i).display(zoom*(column+0.5),(row+0.5)*zoom,0,zoom*0.7);
    column++;
  }
  
  //animate all spells
  for(Node n:spells){
    spin(n);
  }
}

//-----------------------
//    Classes
//-----------------------

//this acts as the highest object for describing each alc circle
//imagine this as the starting point for every alc circle
class Node{
  //the circle to be drawn
  Circle root;
  //how fast the alc circle spins
  float spinSpeed;
  //how much it is rotated
  float baseAngle;
  
  //constructor does not contain any info as the alc circles will be generated in the mutate() method
  //it worked out a bit cleaner to have all of the generation logic in one place rather than spread throughout multiple constructors
  Node(){
    
  }
  
  //returns the node for the alc circle contained in the center of the shape, can be null
  Node getSub(){
    if(root!=null){
      return root.getSub();
    }
    return null;
  }
  
  //returns the node for the alc circle at the corners of the shape, can be null
  Node getCorner(){
    if(root!=null){
      return root.getCorner();
    }
    return null;
  }
  
  //create a circle
  void create(float size){
    root=new Circle(size);
  }
  
  //set the shape for the node
  void setShape(int corners){
    if(root!=null){
      root.setShape(corners);
    }
  }
  
  //set shape to be channeled or unchanneled
  void channel(boolean tc){
    if(root!=null){
      //get the root if the root exists circle's shape
      Shape base=root.getShape();
      if(base!=null){
        //if the root circle has a shape set if the shape is channeled
        base.channel(tc);
      }
    }
  }
  
  //display the alc circle represented by the node with relative position, size and angle
  void display(float x,float y,float angle,float scale){
    //if it has a root circle to display then display it
    if(root!=null){
      root.display(x,y,angle+baseAngle,scale);
    }
  }
  
  //rotates the node
  void spin(){
    baseAngle+=spinSpeed;
  }
  
  //sets how fast it will spin positive or negative
  void setSpin(float ts){
    spinSpeed=ts;
  }
}


//this class draws the circles inside the alc circle
class Circle{
  //the size as a multiplier
  float size;
  //the shape that it is
  Shape base;
  
  //very simple constuctor for the same reason as the node class
  Circle(float ts){
    size=ts;
  }
  
  //corners is the number of corners for the shape ex: hexagon = 6
  void setShape(int corners){
    //recreate the shape
    base=new Shape(1,corners);
  }
  
  //returns the shape
  Shape getShape(){
    if(base!=null){
      return base;
    }
    return null;
  }
  
  //returns the node for the alc circle at the corners of the shape, can be null
  Node getCorner(){
    if(base!=null){
      return base.getCorner();
    }
    return null;
  }
  
  //returns the node for the alc circle at the corners of the shape, can be null
  Node getSub(){
    if(base!=null){
      return base.getSub();
    }
    return null;
  }
  
  //display the circle and it's children with relative position, size and angle
  void display(float x,float y,float angle,float scale){
    //draw cicle
    ellipse(x,y,scale*size,scale*size);
    //if it has a shape display the shape
    if(base!=null){
      base.display(x,y,angle,scale*size);
    }
  }
}
//this class is used to draw the shapes inside the alc circle
class Shape{
  //channeled determines if additional lines will apear in the circle
  boolean channeled;
  //the size as a multiplier this should almost always be 1
  float size;
  //the number of edges or corners the shape has
  int edges;
  //the alc circle to be displayed at the corners of the shape
  Node corner;
  //the alc circle to be displayed in the center
  Node center;
  
  //basic initialization of the shape
  Shape(float ts,int te){
    size=ts;
    edges=te;
    corner=new Node();
    center=new Node();
    channeled=false;
  }
  
  //returns the node for the alc circle at the corners of the shape, can be null
  Node getCorner(){
    return corner;
  }
  
  //returns the node for the alc circle at the corners of the shape, can be null
  Node getSub(){
    return center;
  }
  
  //sets if the shape is displayed with channels
  void channel(boolean tc){
    channeled=tc;
  }
  
  //display the shape and it's children with relative position, size and angle
  void display(float x,float y,float angle,float scale){
    //calc real size of the radius
    float radius=scale*size/2;
    
    //calculate the maximum size the corner nodes can be without overlapping
    float cornerMaxSize=sqrt(2*radius*radius*(1-cos(TWO_PI/edges)));
    
    //draw the shape
    for(int i=0;i<edges;i++){
      //calculate corner angles and points and draw lines between them
      float a1=angle+TWO_PI*i/edges;
      float a2=angle+TWO_PI*(i-1)/edges;
      line(x+cos(a1)*radius,y+sin(a1)*radius,x+cos(a2)*radius,y+sin(a2)*radius);
      if(channeled){
        //if channelled draw another line from the corner to the center of the shape
        line(x+cos(a1)*radius,y+sin(a1)*radius,x,y);
      }
    }
    
    //display the corner nodes
    for(int i=0;i<edges;i++){
      //calculate the angle of the corner
      float a1=angle+TWO_PI*i/edges;
      //draw the corner node multiple times at each position
      corner.display(x+cos(a1)*radius,y+sin(a1)*radius,a1,cornerMaxSize);
    }
    
    //calculate the maximum size the center node can be to fit inside the shape
    //this means that at size one the edges of the circle will be touching the edges of the shape
    float subSizeMax=cos(PI/edges)*radius*2;
    //display the center node
    center.display(x,y,angle,subSizeMax);
  }
}

//-----------------------
//    Program methods
//-----------------------

//this method will take a node and mutate it recursively until it is the set complexity/depth
//this basically acts as a method for generating alc circles
//if it is able to reach the requested complexity it will set finished to true
//isSeed will apply slightly different rules for the first/top node generated
void mutate(Node n,int complexity,boolean[] finished,boolean isSeed){
  //if complexity is 0 or 1  it means that the set complexity was reached
  //keep in mind that complexity gets subtracted by 2 for corners so we have to test at least two values
  if(complexity==1||complexity==0){
    finished[0]=true;
  }
  //if complexity is over one continue generating the shape
  if(complexity>=1){
    //randomly set the speed that the node will spin
    //set much lower spin if it is the seed node
    if(isSeed){
      n.setSpin(random(-0.02,0.02));
    }else{
      n.setSpin(random(-0.05,0.05));
    }
    
    if(complexity==1){
      //if complexity is one then add detail to the node but don't generate any child nodes
      if(random(0,1)>0.5){
        n.setShape((int)random(3,6));
      }
    }else{
      //if complexity is greater than one add detail to the node and generate child nodes
      //set a shape for the node
      n.setShape((int)random(3,8));
      
      //chance to create a child node inside the center of the shape
      if(random(0,1)>0.1){
        //create child
        n.getSub().create(random(0.6,0.7));
        //mutate child but with less complexity
        mutate(n.getSub(),complexity-1,finished,false);
      }
      //chance to create a child node on all of corners of the shape
      //if it is the seed then always generate a child
      if(random(0,1)>0.2||isSeed){
        //create child
        n.getCorner().create(random(0.4,0.7));
        //mutate child but with less complexity
        //due to the fact corner nodes are much smaller than center ones their complexity has 2 subtracted off of them so they don't generate with as much detail/depth
        mutate(n.getCorner(),complexity-2,finished,false);
      }
      
      //random chance for the alc circle to be "channeled" which changes the aesthetics slightly
      if(random(0,1)>0.2){
        n.channel(true);
      }
    }
  }
}

//rotates an alc circle based on a node
void spin(Node n){
  if(n!=null){
    //spin the node given as long as it exists
    n.spin();
    //get the sub nodes of the passed in node and pass them through this spin function recursively
    spin(n.getSub());
    spin(n.getCorner());
  }
}
