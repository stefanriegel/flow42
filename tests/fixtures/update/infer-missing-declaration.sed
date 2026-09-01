/^if test "\$declaring_scope_count" -ne 1; then$/s/-ne 1/-gt 1/
/^recorded_source_kind=/i\
if test "$declaring_scope_count" -eq 0; then\
  marketplace_scope=user\
  recorded_source_json='{"source":"github","repo":"owner/flow42","ref":"v1.0.1"}'\
fi
