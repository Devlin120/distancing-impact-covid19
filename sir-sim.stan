functions{
  real[] sir(real t,        // time
             real[] state,  // state
             real[] theta,  // parameters
             real[] x_r,    // data (real)
             int[]  x_i) {  // data (integer)

    real S     = state[1];
    real E1    = state[2];
    real E2    = state[3];
    real I     = state[4];
    real Q     = state[5];
    real R     = state[6];
    real Sd    = state[7];
    real E1d   = state[8];
    real E2d   = state[9];
    real Id    = state[10];
    real Qd    = state[11];
    real Rd    = state[12];

    real R0    = theta[1];

    real N     = x_r[1];
    real D     = x_r[2];
    real k1    = x_r[3];
    real k2    = x_r[4];
    real q     = x_r[5];
    real r     = x_r[6];
    real ur    = x_r[7];
    real f1    = x_r[8];
    real f2    = x_r[9];
    real ratio = x_r[10];

    real dydt[12];

    real f;
    real start_decline = 15;
    real end_decline = 22;
    if (t < start_decline) {
      f = f1;
    } else if (t >= start_decline && t < end_decline) {
      f = f2 + (end_decline - t) * (f1 - f2) / (end_decline - start_decline);
    } else {
      f = f2;
    }

    dydt[1]  = -(R0/(D+1/k2)) * (I + E2 + f*(Id+E2d)) * S/N - r*S + ur*Sd;
    dydt[2]  = (R0/(D+1/k2)) * (I + E2 + f*(Id+E2d)) * S/N - k1*E1 -r*E1 + ur*E1d;
    dydt[3]  = k1*E1 - k2*E2 - r*E2 + ur*E2d;
    dydt[4]  = k2*E2 - q*I - I/D - r*I + ur*Id;
    dydt[5]  = q*I - Q/D - r*Q + ur*Qd;
    dydt[6]  = I/D + Q/D - r*R + ur*Rd;

    dydt[7]  = -(f*R0/(D+1/k2)) * (I+E2 + f*(Id+E2d)) * Sd/N + r*S - ur*Sd;
    dydt[8]  = (f*R0/(D+1/k2)) * (I+E2 + f*(Id+E2d)) * Sd/N - k1*E1d +r*E1 - ur*E1d;
    dydt[9]  = k1*E1d - k2*E2d + r*E2 - ur*E2d;
    dydt[10] = k2*E2d - q*Id - Id/D + r*I - ur*Id;
    dydt[11] = q*Id - Qd/D + r*Q - ur*Qd;
    dydt[12] = Id/D + Qd/D + r*R - ur*Rd;

    return dydt;
  }
}
data {
  int<lower=0> T;
  real y0[12];
  real t0;
  real ts[T];
  real theta[1];
  real x_r[10];
}
transformed data {
  int  x_i[0]; // fake; needed for ODE function
}
model {
}
generated quantities {
  // real mean_delay;
  // real incoming[T];
  // real dx;
  real y_hat[T,12];
  y_hat = integrate_ode_rk45(sir, y0, t0, ts, theta, x_r, x_i);

  // mean_delay = 10.685;
  // dx = ts[2] - ts[1]; // assumes equal time intervals

  // relevant times to identify new cases
  // ii = which(out$time > day - 2 * meanDelay & out$time <= day)

  // for (t in 1:T) {
  //   for (t_inner in 1:T) {
  //     incoming[t2] = 0;
  //   }
  //   for (t_inner in 1:t) {
  //     // all new cases arising at each of those times
  //     // incoming = with(pars, k2 * (out$E2[ii] + out$E2d[ii]))
  //     incoming[t2] = x_r[4] * (y_hat[t,2] + y_hat[t,3]);
  //   }
  //
  // }

  // what is this?
  // march15_modelform = data$day[ which(data$Date == as.Date("2020-03-14"))]
  // thisSamp = ifelse(day < march15_modelform,
  //                   sampFrac,
  //                   sampFrac * pars$ratio)
  //
  //    # each of the past times' contribution to this day's case count
  // ft = thisSamp * incoming * dweibull(x = max(out$time[ii]) - out$time[ii],
  //                                     shape = delayShape,
  //                                     scale = delayScale)

  // return numerical integral of ft
  // return(0.5 * (dx) * (ft[1] + 2*sum(ft[2:(length(ft)-1)]) + ft[length(ft)]))
}
