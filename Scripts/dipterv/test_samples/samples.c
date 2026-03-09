#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(void)
{
  FILE *file;
  file = fopen("test_samples.mem", "w");

  if (file == NULL)
  {
    printf("Could not open file\n");
    return 1;
  }
  srand

  for (int i = 0; i < 512; i++)
  {
    fprintf(file, "%08X\n", 
  }
  
  



  return 0;
}
