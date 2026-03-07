#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(void)
{
  FILE *file;
  double input [512];
  long long input_processed [512];

  file = fopen("C_coeffs_pre_processing", "r");
  if (file == NULL) 
  {
    printf("Error: Could not open file.\n");
    return 1;
  }

  for (int i = 0; i<512; i++)
  {
    fscanf(file, "%lf", &input[i]);
  }

  fclose(file);

  for (int i = 0; i<512; i++)
  {
    input_processed[i] = llround(input[i] * 2147483648); //2^31
  }

  file = fopen("window_coeffs.mem", "w");
  if (file == NULL) 
  {
    printf("Error: Could not open file.\n");
    return 1;
  }
  for (int i = 0; i<512; i++)
  {
    fprintf(file, "%08llX\n", (input_processed[i] & 0xFFFFFFFF));
  }
  
  fclose(file);


  return 0;
}
