// - Integer data types: int
// - Statements for arithmetic computation. (e.g., a=b+2*(100-1);)
// - Comparison expression. (e.g., a > b)，comparison operation: >、>=、<、<=、==、!=
// - if-then / if-then-else program constructs.
// - printf() function with one/two parameters. (support types: %d)
int main() {
    int x = 20;
    int y = 15;
    int z = 0;

    z = x + 2 * (100 - y);

    if (z > 150) {
        printf("z = %d is greater than 150\n", z);
    } else if (z == 150) {
        printf("z = %d is equal to 150\n", z);
    } else {
        printf("z = %d is less than 150\n", z);
    }

    return 0;
}
