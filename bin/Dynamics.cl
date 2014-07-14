/******************************************************************************\
 *
 * OpenCL kernel definitions for BCIM
 *
 * Dan Kolbman 2014
 *
\******************************************************************************/

#include "threefry.h"

/*****
__kernel void brownian( const int Mdim, const int Ndim, const float diffus,
      __global float* vel)
{
  int i = get_global_id(0);
  if(i+2 < Mdim) {
    const unsigned int MAXINT = 4294967294;
    threefry4x32_key_t k = {{i, 0xdecafbad, 0xfacebead, 0x12345678}};
    threefry4x32_ctr_t c = {{0, 0xf00dcafe, 0xdeadbeef, 0xbeeff00d}};
    union {
        threefry4x32_ctr_t c;
        int4 i;
    } u;
    c.v[0]++;
    u.c = threefry4x32(c, k);
    long x1 = u.i.x, y1 = u.i.y;
    long x2 = u.i.z, y2 = u.i.w;
    vel[i*Ndim] = diffus*(2.0*(float)x1/MAXINT-1.0);
    vel[i*Ndim+1] = diffus*(2.0*(float)y1/MAXINT-1.0);
    vel[i*Ndim+2] = diffus*(2.0*(float)x2/MAXINT-1.0);
    // Ndim = 3 at most
    //vel[i*Ndim+3] = diffus*(2.0*(float)y2/MAXINT-1.0);
  }
}

__kernel void move( const int Mdim, const int Ndim,
  __global float* pos, __global float* vel, const float dt, const float diffus)
{
  unsigned int i = get_global_id(0);
  unsigned int j = get_global_id(1);
  if(i < Mdim && j < Ndim) {
    //vel[i*Ndim+j] = diff*2.0*randoms[i*Ndim+j]-0.5;
    const unsigned int MAXINT = 4294967294;
    //threefry4x32_key_t k = {{i, 0xdecafbad, 0xfacebead, 0x12345678}};
    //threefry4x32_ctr_t c = {{0, 0xf00dcafe, 0xdeadbeef, 0xbeeff00d}};
    threefry4x32_key_t k = {{i*j, 0xdecafbad, 0xfacebead, 0x12345678}};
    threefry4x32_ctr_t c = {{0, 0xf00dcafe, 0xdeadbeef, 0xbeeff00d}};
    union {
        threefry4x32_ctr_t c;
        int4 i;
    } u;
    c.v[0]++;
    u.c = threefry4x32(c, k);
    float x1 = (2.0*(float)(u.i.x)/MAXINT-1.0);
    float x2 = (2.0*(float)(u.i.y)/MAXINT-1.0);
    //float y1 = (2.0*(float)(u.i.z)/MAXINT-1.0);
    //float y2 = (2.0*(float)(u.i.w)/MAXINT-1.0);
    float y1 = sqrt(-2.0*log(x1))*cos(2.0*M_PI_F*x2);
    float y2 = sqrt(-2.0*log(x1))*sin(2.0*M_PI_F*x2);
    vel[i*Ndim+j] = diffus*x1;

    pos[i*Ndim+j] += vel[i*Ndim+j]*dt;
  }
}

*****/

/**
 * Calculate forces on a particle in 2d
 * First assigns a brownian, white noise velocity
 * Add self propulsion velocity
 * Add repulsion force
 * Add adhesion force
 * @param Mdim number of rows in the pos and vel vectors
 * @param Ndim number of cols in the pos and vel vectors
 * @param s the current step
 * @param dia the particle diameter
 * @param contact the contact distance for adhesion
 * @param pretrad the translational diffusion coefficient
 * @param prerotd the rotational diffusion coefficient
 * @param prop the propulsion coefficients array
 * @param rep the repulsion coefficients
 * @param adh the adhesion coefficients
 * @param sp the species of the particle
 * @param pos a vectorized Mdim by Ndim matrix holding position data
 * @param vel a vectorized Mdim by Ndim matrix holding velocity data
 * @param ang an array with orientation data
**/
__kernel void dynamics2D( const int Mdim, const int Ndim,
  const int s,
  const float pretrad,
  const float prerotd,
  const float dia,
  const float contact,
  __global float* prop,       // This is the most ridiculous function sig ever
  __global float* rep,
  __global float* adh,
  __global int* sp,
  __global float* pos,
  __global float* vel,
  __global float* ang)
{
  unsigned int i = get_global_id(0);
  if(i < Mdim) {
    // Used to create floats
    const unsigned int MAXINT = 4294967294;
    // The species of the current particle
    int isp = sp[i]-1;
    // Seed the rng for a 4x32 3fry
    //threefry4x32_key_t k = {{(s+1)*(i+1), 0xdecafbad, 0xfacebead, 0x12345678}};
    //threefry4x32_ctr_t c = {{0, 0xf00dcafe, 0xdeadbeef, 0xbeeff00d}};
    // Seed the rng
    threefry2x32_key_t k = {{(s+2)*(s+5)*(i+8), 0xdecafbad}};
    threefry2x32_ctr_t c = {{0xdeadbeef, 0xf00dcafe}};

    float w, x1, x2, newx, newy; 
    union {
        threefry2x32_ctr_t c;
        int4 i;
    } u;
    // Do brownian stuff
    do {
      c.v[0]++;
      u.c = threefry2x32(c, k);
      x1 = (float)(u.i.x)/MAXINT*2.0;
      x2 = (float)(u.i.y)/MAXINT*2.0;
      w = x1 * x1 + x2 * x2;
    } while ( w >= 1.0 );
    // Box Muller
    w = sqrt( (-2.0 * log( w ) ) / w );
    // Initialize velocities
    vel[i*Ndim]   = x1*w*pretrad;
    vel[i*Ndim+1] = x2*w*pretrad;

    // Do propulsion stuff
    do {
      c.v[0]++;
      u.c = threefry2x32(c, k);
      x1 = (float)(u.i.x)/MAXINT*2.0;
      x2 = (float)(u.i.y)/MAXINT*2.0;
      w = x1 * x1 + x2 * x2;
    } while ( w >= 1.0 );
    // B-M
    w = sqrt( (-2.0 * log( w ) ) / w );
    // Update angle
    ang[i] += prerotd*x1*w;
    // Update velocities
    vel[i*Ndim]  += prop[isp]*cos(ang[i]);
    vel[i*Ndim+1]+= prop[isp]*sin(ang[i]);

    // Repulsive forces
    int j;
    float dx,dy,d,angle,f;
    // Iterate all previous particles
    for(j=i-1;j>=0; j--) {
      dx = pos[i*Ndim] - pos[j*Ndim];
      dy = pos[i*Ndim+1] - pos[j*Ndim+1];
      d = sqrt(dx*dx + dy*dy);
      // Cutoff
      if(d <= dia*2) {
        // Repulsion
        f = (1.0-dia/d);
        f = (fabs(f) - f)/2.0;
        if( isp == sp[j-1] ) {
          float a1, a2;
          // Adhesion
          a1 = d-dia-contact;
          a2 = a1-contact;
          a1 = adh[isp]*0.5*((fabs(a1)/a1)-((fabs(a2)-a2)/a2));
          f = f*rep[isp] + a1;
        }
        else {      // No adhesion, repulsion between two species
          f *= rep[2];
        }
         
        angle = atan2(dy,dx);
        vel[i*Ndim]   +=  f*cos(angle);
        vel[i*Ndim+1] +=  f*sin(angle);
        vel[j*Ndim]   += -f*cos(angle);
        vel[j*Ndim+1] += -f*sin(angle);
      }
    } 
  }
}

/**
 * Update a particle position in 2D and account for bounds
 * @param Mdim number of rows in the pos and vel vectors
 * @param Ndim number of cols in the pos and vel vectors
 * @param dt the time step size
 * @param dia the particle diameter
 * @param size the size of the boudary (radius)
 * @param pos a vectorized Mdim by Ndim matrix holding position data
 * @param vel a vectorized Mdim by Ndim matrix holding velocity data
**/
__kernel void move2D( const int Mdim, const int Ndim,
  const float dt,
  const float dia,
  const float size,
  __global float* pos,
  __global float* vel)
{
  unsigned int i = get_global_id(0);
  if(i < Mdim) {
    float newx,newy;
    // Update position and check boundaries
    newx = pos[i*Ndim]   + vel[i*Ndim]*dt;
    newy = pos[i*Ndim+1] + vel[i*Ndim+1]*dt;

    if( sqrt(newx*newx + newy*newy) <= (size-dia/2.0) ) {
      pos[i*Ndim]   = newx;
      pos[i*Ndim+1] = newy;
    } else {
      float angle = atan2(newy, newx);
      pos[i*Ndim]   = (size-dia/2.0)*cos(angle);
      pos[i*Ndim+1] = (size-dia/2.0)*sin(angle);
    }
  }
}

/*******************************************************************************
 * 2D Functions
 *  These are modularized but also slower (By nearly two times!?)
 *  Memory overhead is the main bottleneck, thus 2x as long for 2x the overhead
 ******************************************************************************/

/**
 * Give a particle a brownian velocity
 * @param Mdim number of rows in the pos and vel vectors
 * @param Ndim number of cols in the pos and vel vectors
 * @param s the current step
 * @param dt the time step size
 * @param diffus the diffusion prefactor
 * @param vel a vectorized MdimxNdim matrix holding velocity data
**/
/*
__kernel void brownian2D( const int Mdim, const int Ndim, 
  const int s, const float diffus, __global float* vel)
{
  unsigned int i = get_global_id(0);
  if(i+1 < Mdim) {
    // Used to create floats
    const unsigned int MAXINT = 4294967294;
    // Seed the rng
    threefry2x32_key_t k = {{(s+2)*(s+5)*(i+8), 0xdecafbad}};
    threefry2x32_ctr_t c = {{0xdeadbeef, 0xf00dcafe}};
    float w, x1, x2; 
    do {
      union {
          threefry2x32_ctr_t c;
          int4 i;
      } u;
      c.v[0]++;
      u.c = threefry2x32(c, k);
      // Make floats from rng [-1.0,1.0]
      x1 = (float)(u.i.x)/MAXINT*2.0;
      x2 = (float)(u.i.y)/MAXINT*2.0;
      w = x1 * x1 + x2 * x2;
    } while ( w >= 1.0 );
    // Box Muller
    w = sqrt( (-2.0 * log( w ) ) / w );
    vel[i*Ndim] = x1*w*diffus;
    vel[i*Ndim+1] = x2*w*diffus;
  }
}
*/

/**
 * Update a particle's position based on its velocity
 * @param Mdim number of rows in the pos and vel vectors
 * @param Ndim number of cols in the pos and vel vectors
 * @param dt the time step size
 * @param pos a vectorized MdimxNdim matrix holding position data
 * @param vel a vectorized MdimxNdim matrix holding velocity data
**/
/*
__kernel void movePos2D( const int Mdim, const int Ndim,
    const float dt,  __global float* pos, __global float* vel)
{
  unsigned int i = get_global_id(0);
  unsigned int j = get_global_id(1);
  if(i < Mdim && j < Ndim) {
    pos[i*Ndim+j] += vel[i*Ndim+j]*dt;
  }
}
*/

/*******************************************************************************
__kernel void ranTest( const int Mdim, __global float* mat ) {
  unsigned int i = get_global_id(0);
  if(i*4+3 < Mdim) {
    const unsigned int MAXINT = 4294967294;
    threefry4x32_key_t k = {{i, 0xdecafbad, 0xfacebead, 0x12345678}};
    threefry4x32_ctr_t c = {{0, 0xf00dcafe, 0xdeadbeef, 0xbeeff00d}};
    union {
        threefry4x32_ctr_t c;
        int4 i;
    } u;
    c.v[0]++;
    u.c = threefry4x32(c, k);
    long x1 = u.i.x, y1 = u.i.y;
    long x2 = u.i.z, y2 = u.i.w;
    mat[i*4] = (float)x1/MAXINT;
    mat[i*4+1] = (float)x2/MAXINT;
    mat[i*4+2] = (float)y1/MAXINT;
    mat[i*4+3] = (float)y2/MAXINT;
    float tmp_bm = sqrt(fmax(pow(-2.0,log(mat[i*4])), 0.0));
    mat[i*4]  = tmp_bm*cos(2.0*M_PI_F*mat[i*4+1]);
    mat[i*4+1] = tmp_bm*sin(2.0*M_PI_F*mat[i*4+1]);
    tmp_bm = sqrt(fmax(pow(-2.0,log(mat[i*4+2])), 0.0));
    mat[i*4+2]  = tmp_bm*cos(2.0*M_PI_F*mat[i*4+3]);
    mat[i*4+3] = tmp_bm*sin(2.0*M_PI_F*mat[i*4+3]);
  }
}
*/
