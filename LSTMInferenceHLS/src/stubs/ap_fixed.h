#pragma once
#include <cmath>

template<int W, int I, int Q=0, int O=0, int N=0>
class ap_fixed {
public:
    double val;
    ap_fixed() : val(0.0) {}
    ap_fixed(double v) : val(v) {}
    ap_fixed(float v)  : val((double)v) {}
    ap_fixed(int v)    : val((double)v) {}
    ap_fixed(long int v) : val((double)v) {}

    // Cross-type copy constructor — fixes the ambiguous cast errors
    template<int W2, int I2, int Q2, int O2, int N2>
    ap_fixed(const ap_fixed<W2,I2,Q2,O2,N2> &o) : val(o.val) {}

    operator double()   const { return val; }
    operator float()    const { return (float)val; }
    operator int()      const { return (int)val; }

    ap_fixed operator+(const ap_fixed &o)  const { return ap_fixed(val + o.val); }
    ap_fixed operator-(const ap_fixed &o)  const { return ap_fixed(val - o.val); }
    ap_fixed operator*(const ap_fixed &o)  const { return ap_fixed(val * o.val); }
    ap_fixed operator/(const ap_fixed &o)  const { return ap_fixed(val / o.val); }
    ap_fixed operator-()                   const { return ap_fixed(-val); }
    ap_fixed& operator+=(const ap_fixed &o) { val += o.val; return *this; }
    ap_fixed& operator-=(const ap_fixed &o) { val -= o.val; return *this; }
    ap_fixed& operator*=(const ap_fixed &o) { val *= o.val; return *this; }
    bool operator>(const ap_fixed &o)  const { return val > o.val; }
    bool operator<(const ap_fixed &o)  const { return val < o.val; }
    bool operator>=(const ap_fixed &o) const { return val >= o.val; }
    bool operator<=(const ap_fixed &o) const { return val <= o.val; }
    bool operator==(const ap_fixed &o) const { return val == o.val; }
};
