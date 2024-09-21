// - Integer data types: int
// - Comparison expression. (e.g., a > b)，comparison operation: >、>=、<、<=、==、!=
// - if-then / if-then-else program constructs.
// - Nested if construct
// - printf() function with one/two parameters. (support types: %d)
int main() {
    int score = 85;
    int highestGrade = 96;

    if (score >= 80) {
        printf("Great.\n");
    } else if (score >= 60) {
        printf("Good.\n");
    } else {
        printf("Fail.\n");
    }

    int lowestGrade = 50;
    int difference = 1;

    if(highestGrade > score) {
        difference = highestGrade - score;
        printf("You are %d points away from the highest grade.\n", difference);
        if(score > lowestGrade) {
            difference = score - lowestGrade;
            printf("You are %d points away from the lowest grade.\n", difference);
        } else {
            printf("You are the lowest grade.\n");
        }
    }

    return 0;
}