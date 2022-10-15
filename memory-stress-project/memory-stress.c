#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void main()
{
    int i = 0;
    while (i++ < 200) {
       char * cp = (char *)calloc(1, 100 * 1024 * 1024);
       printf("%d\n", i);
       sleep(1);
    }
}
