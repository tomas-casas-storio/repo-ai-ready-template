import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  {
    ignores: ["dist/**", "coverage/**", "node_modules/**", ".ai-resources/**"],
  },
  js.configs.recommended,
  ...tseslint.configs.strict,
  {
    rules: {
      // Focused/skipped tests are a classic way to "pass" the gate. Also caught by scripts/guard-tests.sh.
      "no-restricted-properties": [
        "error",
        { object: "it", property: "only" },
        { object: "describe", property: "only" },
        { object: "test", property: "only" },
        { object: "it", property: "skip" },
        { object: "describe", property: "skip" },
        { object: "test", property: "skip" },
      ],
    },
  },
);
