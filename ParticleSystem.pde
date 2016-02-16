class ParticleSystem {
  //FloatBuffer posArray;
  //FloatBuffer colArray;

  final static int maxParticles = 200;
  int curIndex;
  float speed = 0;

  Particle[] particles;

  ParticleSystem() {
    particles = new Particle[maxParticles];
    for(int i=0; i<maxParticles; i++) particles[i] = new Particle();
    curIndex = 0;

    //posArray = BufferUtil.newFloatBuffer(maxParticles * 2 * 2);// 2 coordinates per point, 2 points per particle (current and previous)
    //colArray = BufferUtil.newFloatBuffer(maxParticles * 3 * 2);
  }


  void updateAndDraw(){
    for(int i=0; i<maxParticles; i++) {
      if(particles[i].alpha > 0) {
        particles[i].update();
        particles[i].drawOldSchool(speed);    // use oldschool renderng
      }
    }
  }


  void addParticles(float x, float y, int count, float speed){
    this.speed = speed;
    for(int i=0; i<count; i++) {
      addParticle(x + random(-(float)count + speed*30, count - speed*30), y + random(-(float)count + speed*30, count - speed*30));
    }
  }


  void addParticle(float x, float y) {
    particles[curIndex].init(x, y);
    curIndex++;
    if(curIndex >= maxParticles) curIndex = 0;
  }

}
