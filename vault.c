/* Level 10 — tiny offline "vault" for a brute-force demo.
 * Takes exactly one 3-letter lowercase guess and checks it against a
 * fixed 3-character secret. Installed execute-only (no read) so the
 * secret can't just be `cat`-ed out of the binary — they have to guess.
 * Keyspace: 26^3 = 17,576 possible passwords.
 */
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    const char *secret = "cat";
    const char *flag   = "FLAG{3_chars_17576_tries}";

    if (argc != 2 || strlen(argv[1]) != 3) {
        printf("Usage: vault-level10 <3-letter-guess>\n");
        return 1;
    }
    if (strcmp(argv[1], secret) == 0) {
        printf("%s\n", flag);
    } else {
        printf("Access denied\n");
    }
    return 0;
}
