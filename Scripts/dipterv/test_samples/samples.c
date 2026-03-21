#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

int main(void)
{
  FILE *file;
  file = fopen("test_samples.mem", "w");

  if (file == NULL)
  {
    printf("Could not open file\n");
    return 1;
  }
  srand((unsigned) time(NULL));

  for (int i = 0; i < 512; i++)
  {
    fprintf(file, "%04X\n", ((uint16_t)rand()));
  }

  fclose(file);


  return 0;
}
