#include <stdio.h>
#include <math.h>
#include <stdlib.h>


int main(void)
{
  long long matrix[32][64] = {};
  double coeff = 0;

  for (int i = 0; i<32; i++)
  {
    for (int k = 0; k<64; k++)
    {
      coeff = cos((2*i + 1) * (k - 16) * M_PI/64.0);
      matrix[i][k] = llround(coeff * (2L << 31));
    }
  }

//first lets implement this as 32 bit binary numbers, so i should shift this by 2^31-st, so s.31
  //


  FILE *file;
  file = fopen("matrix_coeffs.mem", "w");
  if (file != NULL)
  {
    for (int i = 0; i<32; i++)
    {
      for (int k = 0; k<64; k++)
      {
        fprintf(file, "%08X\n", (unsigned int)matrix[i][k]);
      }
    }
  }

  fclose(file);

  return 0;
}
