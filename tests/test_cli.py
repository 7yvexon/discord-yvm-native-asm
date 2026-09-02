import io
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

from vending_machine.cli import main


class CliTests(unittest.TestCase):
    def test_create_order_output_does_not_include_bank_account(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "vending.ini"
            config.write_text(
                "\n".join(
                    (
                        "DATABASE_PATH=" + str(root / "vending.db"),
                        "BANK_NAME=테스트은행",
                        "BANK_ACCOUNT_NUMBER=private-account-value",
                        "BANK_ACCOUNT_HOLDER=테스트예금주",
                    )
                ),
                encoding="utf-8",
            )
            output = io.StringIO()
            errors = io.StringIO()
            with redirect_stdout(output), redirect_stderr(errors):
                result = main(["--config", str(config), "create-order", "user", "홍길동", "10000", "--now", "100"])
            self.assertEqual(result, 0, errors.getvalue())
            self.assertIn("order-created:", output.getvalue())
            self.assertNotIn("private-account-value", output.getvalue())
            self.assertNotIn("테스트예금주", output.getvalue())


if __name__ == "__main__":
    unittest.main()
