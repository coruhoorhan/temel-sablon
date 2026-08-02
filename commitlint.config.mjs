// commitlint — conventional commit zorlaması (yalnız mesaj sözdizimi).
// Dikkat: `plan: <id>` trailer'ı commitlint İLE DEĞİL, verify-commit-msg kapısı
// tarafından zorlanır — iki kapı çakışmasın diye burada kural tanımlanmaz.
// Uzun body/footer satırları allowed: plan/trailer blokları uzun olabilir.

export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'body-max-line-length': [0],
    'footer-max-line-length': [0],
  },
};
