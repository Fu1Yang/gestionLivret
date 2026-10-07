#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT

cobc -x -Wall "$repo_dir/livret-epargne.cob" -o "$test_dir/livret-epargne"

assert_contains() {
    local output="$1" expected="$2"
    if [[ "$output" != *"$expected"* ]]; then
        printf 'Résultat attendu absent : %s\n' "$expected" >&2
        printf '%s\n' "$output" >&2
        exit 1
    fi
}

cp "$repo_dir/LIVRET" "$test_dir/LIVRET"
sample_output="$(cd "$test_dir" && ./livret-epargne)"
assert_contains "$sample_output" 'Operations acceptees    : 000010'
assert_contains "$sample_output" 'Total des depots        : 2125.00 EUR'
assert_contains "$sample_output" 'Total des retraits      : 380.00 EUR'
assert_contains "$sample_output" 'Solde apres interets    : 1797.35 EUR'

cat > "$test_dir/LIVRET" <<'EOF'
D001000.00
R000500.00
R000600.00
X000001.00
D000000.00
EOF
custom_output="$(cd "$test_dir" && ./livret-epargne 2.5)"
assert_contains "$custom_output" 'Operations acceptees    : 000002'
assert_contains "$custom_output" 'Operations rejetees     : 000003'
assert_contains "$custom_output" 'Interets (2.500%)         : 12.50 EUR'
assert_contains "$custom_output" 'Solde apres interets    : 512.50 EUR'

: > "$test_dir/LIVRET"
empty_output="$(cd "$test_dir" && ./livret-epargne)"
assert_contains "$empty_output" 'Solde apres interets    : 0.00 EUR'

if (cd "$test_dir" && ./livret-epargne invalid) >/dev/null 2>&1; then
    printf 'Un taux invalide a été accepté.\n' >&2
    exit 1
fi

rm "$test_dir/LIVRET"
if (cd "$test_dir" && ./livret-epargne) >/dev/null 2>&1; then
    printf 'Un fichier LIVRET absent a été accepté.\n' >&2
    exit 1
fi

printf 'Tous les scénarios du traitement batch sont validés.\n'
